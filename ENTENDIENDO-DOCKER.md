# 🐳 Entendiendo Docker Compose - Configuración Explicada

## ¿Qué es docker-compose.yml?

Es un archivo que define **todos los servicios que necesita tu aplicación**. En nuestro caso:
1. La **aplicación Python** (FastAPI)
2. La **base de datos** (MySQL)

Sin Docker Compose tendrías que ejecutar muchos comandos. Con este archivo, uno solo: `docker-compose up -d`

---

## 📋 Servicios Definidos

### 1️⃣ Servicio MySQL

```yaml
services:
  mysql:
    image: mysql:8.0
    container_name: clientes-mysql
    ...
```

**¿Qué significa?**
- **image: mysql:8.0** → Usa la imagen oficial de MySQL versión 8.0 (de Docker Hub)
- **container_name: clientes-mysql** → El contenedor se llamará "clientes-mysql"
- El nombre del servicio es **mysql** (importante para conexiones internas)

### 2️⃣ Servicio App

```yaml
services:
  app:
    build: .
    container_name: clientes-app
    ...
```

**¿Qué significa?**
- **build: .** → Construye una imagen usando el Dockerfile en la carpeta actual
- **container_name: clientes-app** → El contenedor se llamará "clientes-app"

---

## 🌐 La Red (IMPORTANTE)

```yaml
networks:
  clientes-network:
    driver: bridge
```

### ¿Por qué existe la red?

La red permite que los contenedores se comuniquen entre sí. En nuestro caso:
- La **app** necesita conectarse a **mysql**
- Usa el nombre del servicio: `DB_HOST: mysql` (no localhost)

### ⚠️ ¿Qué pasa si la red ya existe?

Si ejecutas el proyecto y la red `clientes-network` **ya existe** de otro proyecto, Docker reutilizará esa red. Esto **PODRÍA causar problemas** si:

1. Otro proyecto también usa `clientes-network`
2. Hay conflictos de nombres de servicios
3. Los puertos están ocupados

---

## 🔍 Verificar si Hay Conflictos

### En Windows (PowerShell o CMD):

```bash
docker network ls
```

Busca si existe `clientes-network`. Si ves algo como:

```
NETWORK ID     NAME                 DRIVER    SCOPE
a1b2c3d4       clientes-network     bridge    local
```

**La red ya existe.**

### Ver detalles de la red:

```bash
docker network inspect clientes-network
```

Te mostrará qué contenedores están usando esa red.

---

## 🎯 Nombres Importantes en la Configuración

### Nombres que NO pueden repetirse (crearán conflicto):

| Nombre | Ubicación | Qué es |
|--------|-----------|--------|
| `clientes-mysql` | `container_name` | Nombre único del contenedor MySQL |
| `clientes-app` | `container_name` | Nombre único del contenedor app |
| `clientes-network` | `networks` | Nombre único de la red |
| `mysql_data` | `volumes` | Nombre único del volumen |

### Nombres que SÍ pueden repetirse (son internos):

| Nombre | Ubicación | Qué es |
|--------|-----------|--------|
| `mysql` | `services` | Nombre del servicio (solo usado internamente) |
| `app` | `services` | Nombre del servicio (solo usado internamente) |

---

## 🚨 Si Hay Conflicto de Red

Si ejecutas `docker-compose up -d` y ves error como:

```
Error response from daemon: network clientes-network is in use
```

**Solución 1: Cambiar el nombre de la red**

Edita `docker-compose.yml`:
```yaml
networks:
  clientes-network-v2:     # ← Cambiar nombre
    driver: bridge
```

Y actualiza las referencias:
```yaml
services:
  mysql:
    networks:
      - clientes-network-v2   # ← Actualizar aquí
  app:
    networks:
      - clientes-network-v2   # ← Y aquí
```

**Solución 2: Eliminar la red antigua**

```bash
docker network rm clientes-network
docker-compose up -d
```

⚠️ CUIDADO: Solo hazlo si nadie está usando esa red.

---

## 📊 Estructura Completa Explicada

```yaml
version: '3.8'
# ^ Versión del formato Docker Compose

services:
  mysql:                              # Servicio 1: Base de datos
    image: mysql:8.0                  # Imagen oficial de MySQL
    container_name: clientes-mysql    # Nombre único del contenedor
    environment:                      # Variables de entorno
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: clientes_db
      MYSQL_USER: usuario
      MYSQL_PASSWORD: usuario123
    ports:
      - "3306:3306"                   # Puerto: Host:Container
    volumes:
      - ./init_db.sql:/docker-entrypoint-initdb.d/init_db.sql  # Script de inicio
      - mysql_data:/var/lib/mysql     # Almacenar datos
    networks:
      - clientes-network              # Conectado a esta red
    healthcheck:                       # Verificar que está listo
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 10s
      retries: 5

  app:                                # Servicio 2: Aplicación
    build: .                           # Construir con Dockerfile
    container_name: clientes-app      # Nombre único del contenedor
    environment:                      # Variables de entorno
      DB_HOST: mysql                  # Conectarse a servicio "mysql"
      DB_PORT: 3306
      DB_USER: usuario
      DB_PASSWORD: usuario123
      DB_NAME: clientes_db
    ports:
      - "8000:8000"                   # Puerto web
    volumes:
      - .:/app                         # Código en sincronía
      - /app/__pycache__              # Excepto cache
    networks:
      - clientes-network              # Conectado a esta red
    depends_on:
      mysql:
        condition: service_healthy    # Esperar a que MySQL esté listo

volumes:                              # Volúmenes (almacenamiento)
  mysql_data:                         # Volumen para datos de MySQL

networks:                             # Redes
  clientes-network:                   # Red puente para comunicación
    driver: bridge
```

---

## 💡 Puntos Clave para Enseñar a los Alumnos

### 1. Los Nombres Importan

```yaml
container_name: clientes-mysql    # ← Este debe ser único
```

Si otro proyecto también usa `clientes-mysql`, habrá conflicto.

### 2. La Red es el "Cable Invisible"

```yaml
networks:
  - clientes-network              # ← App y MySQL están en esta red
```

Por eso la app puede conectarse a MySQL usando nombre:
```
DB_HOST: mysql   # ← Funciona porque están en la misma red
```

### 3. Los Puertos Deben Estar Libres

```yaml
ports:
  - "8000:8000"     # ← Si otro programa usa puerto 8000, error
  - "3306:3306"     # ← Si otra BD usa puerto 3306, error
```

### 4. Los Volúmenes Guardan Datos

```yaml
volumes:
  - mysql_data:/var/lib/mysql     # ← Datos persistentes
```

Aunque cierres Docker, los datos se guardan.

---

## ✅ Checklist Antes de Ejecutar

- [ ] ¿Tengo Docker Desktop instalado?
- [ ] ¿El puerto 8000 está disponible?
- [ ] ¿El puerto 3306 está disponible?
- [ ] ¿La red `clientes-network` no existe o es de este proyecto?
- [ ] ¿Los contenedores `clientes-mysql` y `clientes-app` no existen?

---

## 🔧 Comandos Útiles para Verificar

```bash
# Ver redes existentes
docker network ls

# Ver detalles de una red
docker network inspect clientes-network

# Ver contenedores
docker ps -a

# Ver volúmenes
docker volume ls

# Eliminar todo (CUIDADO)
docker-compose down -v
```

---

## 📚 Para Que los Alumnos Aprendan

### Ejercicio 1: Verificar la Configuración

Pide a tus alumnos que:
1. Ejecuten `docker-compose up -d`
2. Luego `docker network ls`
3. Encuentren `clientes-network`
4. Ejecuten `docker network inspect clientes-network`
5. Vean que aparecen `clientes-mysql` y `clientes-app`

### Ejercicio 2: Ver los Contenedores

```bash
docker ps
```

Deberían ver:
- `clientes-mysql` (Puerto 3306)
- `clientes-app` (Puerto 8000)

### Ejercicio 3: Conectar a MySQL

```bash
docker-compose exec mysql mysql -u usuario -p clientes_db
```

(Contraseña: usuario123)

Así ven que la BD está realmente funcionando.

---

**¡Esto ayudará a tus alumnos a entender Docker en profundidad!** 🎓
