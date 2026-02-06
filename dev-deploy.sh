#!/bin/bash

################################################################################
#                   SCRIPT DE DESPLIEGUE AUTOMATIZADO                          #
#                                                                              #
# Automatiza todo el flujo: dev → deploy → main → servidor                    #
# Sin GitHub Actions. 100% manual pero ejecutado por script.                  #
#                                                                              #
# Uso: ./dev-deploy.sh                                                        #
################################################################################

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
SSH_USER="sulbaranjc"
SSH_HOST="docker.sulbaranjc.com"
PROJECT_PATH="~/apps/clientes-monolito-docker"
LOCAL_PROJECT="$(pwd)"

################################################################################
# FUNCIONES
################################################################################

print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          🤖 DESPLIEGUE AUTOMATIZADO v1.0                   ║"
    echo "║                                                            ║"
    echo "║  dev → deploy → main → servidor → docker → verificación    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    local step=$1
    local total=$2
    local message=$3
    echo -e "\n${BLUE}[$step/$total]${NC} ${message}..."
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}⚠ Advertencia: $1${NC}"
}

################################################################################
# VALIDACIONES PREVIAS
################################################################################

validate_environment() {
    print_step "0" "5" "Validando entorno"
    
    # Verificar git
    if ! command -v git &> /dev/null; then
        print_error "Git no está instalado"
    fi
    print_success "Git encontrado"
    
    # Verificar ssh
    if ! command -v ssh &> /dev/null; then
        print_error "SSH no está instalado"
    fi
    print_success "SSH encontrado"
    
    # Verificar que estamos en un repo git
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "No estamos en un repositorio Git"
    fi
    print_success "Repositorio Git detectado"
    
    # Verificar rama actual
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_success "Rama actual: $CURRENT_BRANCH"
}

################################################################################
# OBTENER ENTRADA DEL USUARIO
################################################################################

get_user_input() {
    print_header
    
    echo -e "${YELLOW}Por favor, ingresa los datos requeridos:${NC}\n"
    
    # Mensaje de commit
    while [ -z "$COMMIT_MSG" ]; do
        read -p "$(echo -e ${BLUE})? Mensaje de commit:${NC} " COMMIT_MSG
        if [ -z "$COMMIT_MSG" ]; then
            print_warning "El mensaje no puede estar vacío"
        fi
    done
    
    # Contraseña SSH (sin mostrar)
    while [ -z "$SSH_PASSWORD" ]; do
        read -sp "$(echo -e ${BLUE})? Contraseña SSH para $SSH_USER@$SSH_HOST:${NC} " SSH_PASSWORD
        echo ""
        if [ -z "$SSH_PASSWORD" ]; then
            print_warning "La contraseña no puede estar vacía"
        fi
    done
    
    # Exportar para usar en el script
    export SSHPASS="$SSH_PASSWORD"
}

################################################################################
# FASE 1: CAMBIOS LOCALES
################################################################################

push_to_dev() {
    print_step "1" "7" "Agregando cambios a dev"
    
    git add .
    print_success "Cambios agregados"
    
    git commit -m "$COMMIT_MSG"
    print_success "Commit realizado: $COMMIT_MSG"
    
    git push origin dev
    print_success "Push a origin/dev completado"
}

merge_to_deploy() {
    print_step "2" "7" "Merging dev → deploy"
    
    git checkout deploy > /dev/null 2>&1
    print_success "Cambiado a rama deploy"
    
    git pull origin deploy > /dev/null 2>&1
    print_success "Actualizado desde origin/deploy"
    
    git merge dev > /dev/null 2>&1
    print_success "Merge desde dev completado"
    
    git push origin deploy > /dev/null 2>&1
    print_success "Push a origin/deploy completado"
}

merge_to_main() {
    print_step "3" "7" "Merging deploy → main"
    
    git checkout main > /dev/null 2>&1
    print_success "Cambiado a rama main"
    
    git pull origin main > /dev/null 2>&1
    print_success "Actualizado desde origin/main"
    
    git merge deploy > /dev/null 2>&1
    print_success "Merge desde deploy completado"
    
    git push origin main > /dev/null 2>&1
    print_success "Push a origin/main completado"
}

################################################################################
# FASE 2: DESPLIEGUE EN SERVIDOR
################################################################################

deploy_on_server() {
    print_step "4" "7" "Conectando al servidor..."
    
    # Crear comando para ejecutar en servidor
    local server_commands="
    set -e
    cd $PROJECT_PATH
    
    echo '📥 Trayendo cambios desde main...'
    git pull origin main
    
    echo '🔨 Reconstruyendo imagen Docker...'
    docker compose -f docker-compose.prod.yml build > /dev/null
    
    echo '⏹️  Deteniendo contenedores...'
    docker compose -f docker-compose.prod.yml down > /dev/null
    
    echo '🚀 Iniciando nuevos contenedores...'
    docker compose -f docker-compose.prod.yml up -d > /dev/null
    
    echo '⏳ Esperando que inicie completamente...'
    sleep 15
    "
    
    # Ejecutar en servidor con contraseña
    if command -v sshpass &> /dev/null; then
        sshpass -e ssh "$SSH_USER@$SSH_HOST" "$server_commands" || print_error "Error en despliegue del servidor"
    else
        # Fallback: intentar sin sshpass
        ssh "$SSH_USER@$SSH_HOST" "$server_commands" || print_error "Error en despliegue del servidor"
    fi
    
    print_success "Despliegue en servidor completado"
}

################################################################################
# FASE 3: VERIFICACIÓN
################################################################################

verify_deployment() {
    print_step "5" "7" "Verificando contenedores..."
    
    # Verificar que contenedores están corriendo
    local verify_cmd="docker ps | grep clientes-monolito-docker | wc -l"
    
    if command -v sshpass &> /dev/null; then
        CONTAINER_COUNT=$(sshpass -e ssh "$SSH_USER@$SSH_HOST" "$verify_cmd" 2>/dev/null || echo "0")
    else
        CONTAINER_COUNT=$(ssh "$SSH_USER@$SSH_HOST" "$verify_cmd" 2>/dev/null || echo "0")
    fi
    
    if [ "$CONTAINER_COUNT" -ge 2 ]; then
        print_success "Contenedores corriendo correctamente ($CONTAINER_COUNT encontrados)"
    else
        print_warning "Posible problema con contenedores (encontrados: $CONTAINER_COUNT)"
    fi
    
    print_step "6" "7" "Probando HTTP..."
    
    # Probar endpoint
    local http_test="curl -s -o /dev/null -w '%{http_code}' http://localhost:8000"
    
    if command -v sshpass &> /dev/null; then
        HTTP_CODE=$(sshpass -e ssh "$SSH_USER@$SSH_HOST" "$http_test" 2>/dev/null || echo "000")
    else
        HTTP_CODE=$(ssh "$SSH_USER@$SSH_HOST" "$http_test" 2>/dev/null || echo "000")
    fi
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "HTTP 200 OK - Aplicación respondiendo correctamente"
    elif [ "$HTTP_CODE" = "000" ]; then
        print_warning "No se pudo conectar - Verifica conexión SSH"
    else
        print_warning "HTTP $HTTP_CODE - Verifica aplicación"
    fi
}

################################################################################
# RESUMEN FINAL
################################################################################

print_summary() {
    print_step "7" "7" "Generando resumen"
    
    # Obtener información de ramas
    local dev_commit=$(git rev-parse --short dev 2>/dev/null || echo "N/A")
    local deploy_commit=$(git rev-parse --short deploy 2>/dev/null || echo "N/A")
    local main_commit=$(git rev-parse --short main 2>/dev/null || echo "N/A")
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            ✅ DESPLIEGUE COMPLETADO EXITOSAMENTE            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${CYAN}Información del despliegue:${NC}"
    echo -e "  ${BLUE}Rama dev:${NC}     $dev_commit"
    echo -e "  ${BLUE}Rama deploy:${NC}  $deploy_commit"
    echo -e "  ${BLUE}Rama main:${NC}    $main_commit"
    echo -e "  ${BLUE}Mensaje:${NC}      $COMMIT_MSG"
    echo -e "  ${BLUE}Servidor:${NC}     $SSH_USER@$SSH_HOST"
    echo -e "  ${BLUE}Aplicación:${NC}   https://clientes-monolito-docker.docker.sulbaranjc.com\n"
    
    echo -e "${YELLOW}⚠️  Notas:${NC}"
    echo -e "  • Los cambios están en ${GREEN}main${NC} (producción)"
    echo -e "  • Los contenedores se han reconstruido con la nueva imagen"
    echo -e "  • Verifica que todo funcione correctamente en el servidor\n"
    
    git checkout dev > /dev/null 2>&1
    print_success "Script finalizado correctamente (volviendo a rama dev)"
}

################################################################################
# MANEJO DE ERRORES
################################################################################

on_error() {
    local line_number=$1
    echo ""
    print_error "Error en línea $line_number del script"
    echo "Revisa los logs arriba para más detalles"
    exit 1
}

trap 'on_error ${LINENO}' ERR

################################################################################
# FLUJO PRINCIPAL
################################################################################

main() {
    print_header
    
    validate_environment
    get_user_input
    
    echo ""
    echo -e "${YELLOW}Iniciando despliegue automático...${NC}\n"
    
    # FASE 1: Local
    push_to_dev
    merge_to_deploy
    merge_to_main
    
    # FASE 2: Servidor
    deploy_on_server
    
    # FASE 3: Verificación
    verify_deployment
    
    # Resumen
    print_summary
}

# Ejecutar
main "$@"
