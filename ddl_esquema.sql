USE tienda_ba;

-- ========== BASE ==========
CREATE TABLE IF NOT EXISTS sucursal (
  id_sucursal BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  direccion   VARCHAR(150),
  ciudad      VARCHAR(80),
  telefono    VARCHAR(30),
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Empleados (cada empleado pertenece a 1 sucursal)
CREATE TABLE IF NOT EXISTS empleado (
  id_empleado BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(120) NOT NULL,
  cargo       ENUM('CAJERO','BODEGA','GERENTE','ADMIN') NOT NULL DEFAULT 'CAJERO',
  id_sucursal BIGINT UNSIGNED NOT NULL,
  email       VARCHAR(120) UNIQUE,
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_emp_sucursal
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
) ENGINE=InnoDB;

-- Productos (sin stock y sin sucursal aquí)
CREATE TABLE IF NOT EXISTS producto (
  id_producto BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(120) NOT NULL,
  precio      DECIMAL(10,2) NOT NULL,
  sku         VARCHAR(50) UNIQUE,
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_producto_nombre (nombre)
) ENGINE=InnoDB;

-- Inventario (stock por sucursal y producto)
CREATE TABLE IF NOT EXISTS inventario (
  id_sucursal BIGINT UNSIGNED NOT NULL,
  id_producto BIGINT UNSIGNED NOT NULL,
  stock       INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id_sucursal, id_producto),
  CONSTRAINT fk_inv_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_inv_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
  INDEX idx_inv_producto (id_producto)   -- para consultar stock de un producto en todas las sucursales
) ENGINE=InnoDB;

-- Clientes (simple)
CREATE TABLE IF NOT EXISTS cliente (
  id_cliente BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(120) NOT NULL,
  telefono   VARCHAR(30)
) ENGINE=InnoDB;

-- Ventas (ocurren en una sucursal; opcionalmente cliente y empleado)
CREATE TABLE IF NOT EXISTS venta (
  id_venta    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_sucursal BIGINT UNSIGNED NOT NULL,
  id_cliente  BIGINT UNSIGNED NULL,
  id_empleado BIGINT UNSIGNED NULL,  -- quién atendió
  total       DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_venta_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_venta_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente(id_cliente),
  CONSTRAINT fk_venta_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  INDEX idx_venta_fecha (fecha)
) ENGINE=InnoDB;

