-- =========================================================
-- SCRIPT INICIALIZADOR DE BASE DE DATOS PARA EL PROYECTO CLIENTES
-- Autor: Juan Carlos Sulbarán González
-- Fecha: 2025-11-12
-- Descripción:
--   Este script elimina la base de datos si ya existe,
--   la vuelve a crear desde cero y define la tabla 'clientes'.
-- =========================================================

-- 1️⃣ Borrar la base de datos si ya existe
DROP DATABASE IF EXISTS clientes_db;

-- 2️⃣ Crear una nueva base de datos
CREATE DATABASE clientes_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 3️⃣ Seleccionar la base de datos recién creada
USE clientes_db;

-- 4️⃣ Crear tabla 'clientes'
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    direccion VARCHAR(255)
);

-- 5️⃣ Insertar algunos registros de ejemplo
INSERT INTO clientes (nombre, apellido, email, telefono, direccion) VALUES
('Juan', 'Pérez', 'juan.perez@example.com', '555-0101', 'Calle 123, Ciudad'),
('María', 'García', 'maria.garcia@example.com', '555-0102', 'Avenida 456, Ciudad'),
('Carlos', 'Rodríguez', 'carlos.rodriguez@example.com', '555-0103', 'Plaza 789, Ciudad'),
('Ana', 'Martínez', 'ana.martinez@example.com', '555-0104', 'Paseo 321, Ciudad'),
('Luis', 'López', 'luis.lopez@example.com', '555-0105', 'Boulevard 654, Ciudad');

-- 6️⃣ Confirmar
SELECT * FROM clientes;
