-- =========================================================
-- SCRIPT DE INICIALIZACIÓN / MIGRACIÓN SEGURA
-- Proyecto: Clientes
-- Autor: Juan Carlos Sulbarán González
-- Fecha: 2025-11-12
-- =========================================================

-- 1️⃣ Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS clientes_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

-- 2️⃣ Seleccionar la base de datos
USE clientes_db;

-- 3️⃣ Crear la tabla 'clientes' si no existe
CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    direccion VARCHAR(255)
);

-- 4️⃣ Insertar datos de ejemplo SOLO si no existen
INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
SELECT * FROM (
    SELECT 'Juan', 'Pérez', 'juan.perez@example.com', '555-0101', 'Calle 123, Ciudad'
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM clientes WHERE email = 'juan.perez@example.com'
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
SELECT * FROM (
    SELECT 'María', 'García', 'maria.garcia@example.com', '555-0102', 'Avenida 456, Ciudad'
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM clientes WHERE email = 'maria.garcia@example.com'
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
SELECT * FROM (
    SELECT 'Carlos', 'Rodríguez', 'carlos.rodriguez@example.com', '555-0103', 'Plaza 789, Ciudad'
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM clientes WHERE email = 'carlos.rodriguez@example.com'
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
SELECT * FROM (
    SELECT 'Ana', 'Martínez', 'ana.martinez@example.com', '555-0104', 'Paseo 321, Ciudad'
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM clientes WHERE email = 'ana.martinez@example.com'
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion)
SELECT * FROM (
    SELECT 'Luis', 'López', 'luis.lopez@example.com', '555-0105', 'Boulevard 654, Ciudad'
) AS tmp
WHERE NOT EXISTS (
    SELECT 1 FROM clientes WHERE email = 'luis.lopez@example.com'
);

-- 5️⃣ Verificación opcional
SELECT * FROM clientes;
