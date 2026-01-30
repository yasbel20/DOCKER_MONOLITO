# 🐳 Guía Simple - Dockerizar tu Aplicación Clientes

## ¿Qué es Docker?

Docker es una herramienta que te permite **encapsular tu aplicación y su base de datos en contenedores**. En lugar de instalar MySQL en tu PC, Docker lo ejecuta en un contenedor aislado. ¡Así tu PC se mantiene limpio!

---

## 📋 Requisitos

Tienes que tener instalado:
- **Docker Desktop** (descárgalo desde [docker.com](https://www.docker.com/products/docker-desktop))

Comprueba que está instalado:
```bash
docker --version
docker-compose --version
```

---

## 🚀 Primer Inicio (Limpio)

**Si es la primera vez o clonas el proyecto desde GitHub:**

```bash
# Elimina cualquier contenedor o volumen previo
docker compose down -v

# Levanta el proyecto completamente nuevo
docker compose up -d
```

⚠️ **Nota:** La opción `-v` elimina volúmenes. Solo úsalo si quieres empezar con una base de datos limpia.

---

## 🚀 Levantar el Servidor

### En Windows 11 y Linux/Mac

1. Abre PowerShell (Windows) o Terminal (Linux/Mac) en la carpeta del proyecto
2. Ejecuta:
```bash
docker compose up -d
```

Espera 5-10 segundos a que todo se inicie (la primera vez tarda más).

---

## ✅ Verificar que Funciona

Abre tu navegador y ve a:
```
http://localhost:8000
```

¿Ves la aplicación? ¡Perfecto! Ya está funcionando.

Para ver la documentación de la API:
```
http://localhost:8000/docs
```

---

## 📊 Acceso a Base de Datos

### Credenciales de la Base de Datos

- **Host:** `localhost`
- **Puerto:** `3307` (el puerto 3306 está en uso por MySQL local)
- **Usuario:** `usuario`
- **Contraseña:** `usuario123`
- **Base de datos:** `clientes_db`

### Con MySQL Workbench (Visual)

Los estudiantes pueden acceder a la BD desde **MySQL Workbench** para ver las tablas y datos:

1. Abre **MySQL Workbench**
2. Haz clic en **"+"** para crear una nueva conexión
3. Completa los datos:
   - **Connection Name:** `clientes-docker` (o el nombre que quieras)
   - **Hostname:** `localhost`
   - **Port:** `3307`
   - **Username:** `usuario`
   - **Password:** Haz clic en "Store in Vault..." e ingresa `usuario123`
4. Haz clic en **"Test Connection"** → Debe aparecer "Successfully made the MySQL connection"
5. Haz clic en **OK**
6. Abre la conexión y verás la BD `clientes_db` con sus tablas

---

### Opción 1: Ver estado de los contenedores
```bash
docker compose ps
```

Deberías ver:
- `clientes-mysql` en estado `(healthy)`
- `clientes-app` en estado `(Up)`

### Opción 2: Abrir en navegador

Abre tu navegador y ve a:
```
http://localhost:8000
```

---

## 🛑 Cerrar el Servidor

### En Windows 11, Linux y Mac

En la misma terminal donde ejecutaste `docker compose up`, presiona:
```
Ctrl + C
```

O en otra terminal ejecuta:
```bash
docker compose down
```

---

## 📁 Estructura del Proyecto

```
proyecto/
├── Dockerfile              ← Imagen de la aplicación
├── docker-compose.yml      ← Configuración de servicios
├── README.md               ← Este archivo
├── ENTENDIENDO-DOCKER.md   ← Explicación de la configuración
├── requirements.txt        ← Dependencias Python
├── init_db.sql            ← Inicialización de BD
├── app/
│   ├── main.py
│   ├── database.py
│   └── templates/
└── ... (resto de archivos)
```

---

## 💡 Conceptos Clave

### Contenedor
Un contenedor es como una "caja" que contiene tu aplicación. Si cierras el contenedor, la aplicación se detiene, pero los datos se guardan.

### Volumen
Un volumen es como una carpeta compartida. Los datos de la BD se guardan en un volumen para que no se pierdan.

### Red
Docker crea una red interna para que los contenedores se comuniquen. Así la app puede hablar con MySQL sin problema.

---

## 🔧 Comandos Útiles

```bash
# Ver estado de los contenedores
docker-compose ps

# Ver logs (mensajes)
docker-compose logs -f

# Entrar en la aplicación
docker-compose exec app bash

# Reiniciar todo
docker-compose restart

# Limpiar todo (CUIDADO: elimina los datos)
docker-compose down -v
```

---

## ⚠️ Problemas Comunes

### "No puedo conectar a la base de datos"
```bash
docker-compose logs mysql
```
Espera unos segundos. MySQL tarda en iniciar.

### "El puerto 8000 ya está en uso"
Ya hay otra aplicación usando ese puerto. Cierra lo que esté usando puerto 8000 o cambia el puerto en `docker-compose.yml`.

### "Docker no está instalado"
Descarga Docker Desktop desde [docker.com](https://www.docker.com/products/docker-desktop) e instálalo.

### "No puedo conectar a MySQL con Workbench"
Asegúrate de que:
- `docker compose ps` muestra `clientes-mysql` con estado `(healthy)`
- Estás usando `localhost` como hostname
- El puerto es `3306`
- Las credenciales son correctas: usuario=`usuario`, contraseña=`usuario123`

---

## 🎯 Flujo de Trabajo

1. **Levantar servidor**
   ```bash
   docker compose up -d
   ```

2. **Ver estado**
   ```bash
   docker compose ps
   ```

3. **Desarrollar**
   - Edita tu código normalmente
   - Los cambios se aplican automáticamente (hot reload)

4. **Probar**
   - Abre `http://localhost:8000`

5. **Cerrar servidor**
   ```bash
   docker compose down
   ```
   O presiona `Ctrl + C` en la terminal

---

## 📞 Resumen Rápido de Comandos

| Acción | Comando |
|--------|---------|
| Levantar | `docker compose up -d` |
| Ver estado | `docker compose ps` |
| Ver logs | `docker compose logs -f` |
| Ver logs solo app | `docker compose logs -f app` |
| Entrar a bash | `docker compose exec app bash` |
| Cerrar (otra terminal) | `docker compose down` |
| Cerrar (misma terminal) | `Ctrl + C` |
| Abrir app | http://localhost:8000 |
| Conectar BD con Workbench | `localhost:3306` usuario/usuario123 |

---

**¡Listo para trabajar!** 🚀
