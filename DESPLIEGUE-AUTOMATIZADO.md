# 🤖 Despliegue Automatizado - Script Deploy

> **Fase 2 del despliegue**
> 
> Después de aprender el proceso manual paso a paso, automatizamos todo con un script.
> Sin GitHub Actions. 100% manual pero ejecutado por script.

---

## 📋 Tabla de Contenidos

1. [¿Qué es este script?](#qué-es-este-script)
2. [Prerequisitos](#prerequisitos)
3. [Instalación](#instalación)
4. [Uso](#uso)
5. [Paso a paso del script](#paso-a-paso-del-script)
6. [Solución de problemas](#solución-de-problemas)

---

## ¿Qué es este script?

Es un archivo `deploy.sh` que **automatiza TODO el flujo de despliegue en una sola ejecución:**

```
dev → deploy → main → servidor → docker rebuild → verificación
```

### Ventajas:
- ✅ Un comando en lugar de 14
- ✅ Pide password SSH UNA sola vez
- ✅ Menos errores manuales
- ✅ Más rápido (~3 minutos)
- ✅ Perfecto para despliegues frecuentes

### Desventajas:
- ❌ Menos control detallado
- ❌ Si algo falla, debes revisar logs

---

## Prerequisitos

### En tu máquina (LOCAL)

```bash
# Asegurate de tener git
git --version

# Debes estar en el proyecto
cd ~/proyectos/python/App_con_docker/clientes-monolito-docker

# El archivo dev-deploy.sh debe estar en el root del proyecto
ls -la dev-deploy.sh
```

### Permisos

```bash
# Dar permisos de ejecución al script
chmod +x dev-deploy.sh
```

---

## Instalación

### 1. El script ya existe en el proyecto

```bash
# Verificar que está
cat dev-deploy.sh
```

### 2. Dar permisos

```bash
chmod +x dev-deploy.sh
```

### 3. Listo para usar

---

## Uso

### Ejecución básica

```bash
./dev-deploy.sh
```

El script te pedirá:

```
╔════════════════════════════════════╗
║   DESPLIEGUE AUTOMATIZADO v1.0      ║
╚════════════════════════════════════╝

? Mensaje de commit (describe tu cambio):
```

Ingresa un mensaje descriptivo:

```
feat: agregar nueva sección en inicio
```

Luego pedirá:

```
? Contraseña SSH para sulbaranjc@docker.sulbaranjc.com:
```

Ingresa tu contraseña SSH.

**¡Eso es todo!** El script hace el resto automáticamente.

---

## Paso a paso del script

### Fase 1: LOCAL (tu máquina)

```bash
✓ git add .
✓ git commit -m "tu mensaje"
✓ git push origin dev
```

→ Cambios en rama dev

```bash
✓ git checkout deploy
✓ git pull origin deploy
✓ git merge dev
✓ git push origin deploy
```

→ Cambios en rama deploy (testing)

```bash
✓ git checkout main
✓ git pull origin main
✓ git merge deploy
✓ git push origin main
```

→ Cambios en rama main (producción)

### Fase 2: SERVIDOR (remoto vía SSH)

```bash
✓ git pull origin main
✓ docker compose build
✓ docker compose down
✓ docker compose up -d
✓ sleep 15
✓ docker ps (verificación)
✓ curl localhost:8000 (test HTTP)
```

→ Cambios en vivo en producción

---

## Ejemplo de uso completo

### Paso 1: Modificar código localmente

```bash
# Editar archivo
nano app/templates/pages/index.html

# Cambiar algo
```

### Paso 2: Ejecutar script

```bash
./deploy.sh
```

### Paso 3: Ingresar datos

```
Mensaje de commit: feat: cambios en interfaz principal
Contraseña SSH: ••••••••••
```

### Paso 4: Esperar (~3 minutos)

El script va mostrando progreso:

```
[1/7] 🔄 Agregando cambios a git...
[2/7] 📝 Haciendo commit...
[3/7] 🚀 Subiendo a dev...
[4/7] 🔀 Merging a deploy...
[5/7] 📦 Merging a main...
[6/7] 🖥️  Desplegando en servidor...
[7/7] ✅ Verificando... HTTP 200 OK
```

### Paso 5: Ver cambios en vivo

```
https://clientes-monolito-docker.docker.sulbaranjc.com/
```

---

## Solución de problemas

### Error: "Permission denied"

```bash
chmod +x dev-deploy.sh
./dev-deploy.sh
```

### Error: "Contraseña incorrecta"

```
Verifica tu contraseña SSH
```

### Error: "Merge conflict"

El script se detiene. Resuelve manualmente:

```bash
git merge --abort
# Luego intenta de nuevo
```

### El servidor no actualiza

```bash
# SSH al servidor y verifica
ssh sulbaranjc@docker.sulbaranjc.com
cd ~/apps/clientes-monolito-docker
git log --oneline -1
docker ps
```

---

## 🎓 Resumen

| Método | Pasos | Tiempo | Para |
|--------|-------|--------|------|
| **Manual** | 14 pasos | 10 min | Aprender |
| **Script** | 1 comando | 3 min | Producción |

**Recomendación:**
1. Primero aprende MANUAL
2. Luego usa SCRIPT para agilizar

---

**Versión:** 1.0  
**Fecha:** 6 de febrero de 2026  
**Estado:** Listo para usar
