-- =========================================
--  RESET Y CREACIÓN DE BASE DE DATOS
-- =========================================
DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE tienda;

-- Por si ejecutas el script parcialmente en sesiones distintas
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================
--  TABLA: sucursal
--  (clave PK UNSIGNED, acorde a las FKs)
-- =========================================
DROP TABLE IF EXISTS sucursal;
CREATE TABLE sucursal (
  id_sucursal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  activo      TINYINT(1)      NOT NULL DEFAULT 1,        -- booleano
  ciudad      VARCHAR(80),
  created_at  DATETIME(6),
  direccion   VARCHAR(150),
  nombre      VARCHAR(100)    NOT NULL,
  telefono    VARCHAR(30),
  PRIMARY KEY (id_sucursal),
  KEY idx_suc_activo (activo),
  KEY idx_suc_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: empleado
-- =========================================
DROP TABLE IF EXISTS empleado;
CREATE TABLE empleado (
  id_empleado BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(120) NOT NULL,
  cargo       ENUM('CAJERO','BODEGA','GERENTE','ADMIN') NOT NULL DEFAULT 'CAJERO',
  id_sucursal BIGINT UNSIGNED NOT NULL,
  email       VARCHAR(120) UNIQUE,
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_empleado),
  KEY idx_emp_sucursal (id_sucursal),
  CONSTRAINT fk_emp_sucursal
    FOREIGN KEY (id_sucursal)
    REFERENCES sucursal(id_sucursal)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: producto
-- =========================================
DROP TABLE IF EXISTS producto;
CREATE TABLE producto (
  id_producto BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(120) NOT NULL,
  precio      DECIMAL(10,2) NOT NULL,
  sku         VARCHAR(50) UNIQUE,
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_producto),
  INDEX idx_producto_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: inventario  (stock por sucursal y producto)
-- =========================================
DROP TABLE IF EXISTS inventario;
CREATE TABLE inventario (
  id_sucursal BIGINT UNSIGNED NOT NULL,
  id_producto BIGINT UNSIGNED NOT NULL,
  stock       INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id_sucursal, id_producto),
  KEY idx_inv_producto (id_producto),
  CONSTRAINT fk_inv_sucursal
    FOREIGN KEY (id_sucursal)
    REFERENCES sucursal(id_sucursal)
    ON UPDATE CASCADE
    ON DELETE CASCADE,    -- al borrar sucursal, borra su stock
  CONSTRAINT fk_inv_producto
    FOREIGN KEY (id_producto)
    REFERENCES producto(id_producto)
    ON UPDATE CASCADE
    ON DELETE CASCADE     -- al borrar producto, borra su stock
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: cliente
-- =========================================
DROP TABLE IF EXISTS cliente;
CREATE TABLE cliente (
  id_cliente BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(120) NOT NULL,
  telefono   VARCHAR(30),
  PRIMARY KEY (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: venta
-- =========================================
DROP TABLE IF EXISTS venta;
CREATE TABLE venta (
  id_venta    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_sucursal BIGINT UNSIGNED NOT NULL,
  id_cliente  BIGINT UNSIGNED NULL,
  id_empleado BIGINT UNSIGNED NULL,   -- quién atendió
  total       DECIMAL(12,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_venta),
  KEY idx_venta_fecha (fecha),
  KEY idx_venta_sucursal (id_sucursal),
  CONSTRAINT fk_venta_sucursal
    FOREIGN KEY (id_sucursal)
    REFERENCES sucursal(id_sucursal)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,   -- evita borrar sucursal con ventas
  CONSTRAINT fk_venta_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente)
    ON UPDATE CASCADE
    ON DELETE SET NULL,   -- conserva venta si se borra el cliente
  CONSTRAINT fk_venta_empleado
    FOREIGN KEY (id_empleado)
    REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE
    ON DELETE SET NULL    -- conserva venta si se borra el empleado
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================================
--  TABLA: detalle_venta
-- =========================================
DROP TABLE IF EXISTS detalle_venta;
CREATE TABLE detalle_venta (
  id_venta    BIGINT UNSIGNED NOT NULL,
  id_producto BIGINT UNSIGNED NOT NULL,
  cantidad    INT NOT NULL,
  precio_unit DECIMAL(10,2) NOT NULL,
  subtotal    DECIMAL(12,2) AS (cantidad * precio_unit) STORED,
  PRIMARY KEY (id_venta, id_producto),
  KEY idx_det_producto (id_producto),
  CONSTRAINT fk_det_venta
    FOREIGN KEY (id_venta)
    REFERENCES venta(id_venta)
    ON UPDATE CASCADE
    ON DELETE CASCADE,    -- al borrar venta, borra sus detalles
  CONSTRAINT fk_det_producto
    FOREIGN KEY (id_producto)
    REFERENCES producto(id_producto)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;


