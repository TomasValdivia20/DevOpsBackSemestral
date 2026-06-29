-- ============================================================================
-- init.sql — Referencia de esquema para bases de datos RDS
-- Las tablas son creadas automáticamente por Hibernate (ddl-auto=update).
-- Este archivo es solo documentación y para inicialización manual si es necesario.
-- ============================================================================

-- Base de datos del servicio Ventas
CREATE DATABASE IF NOT EXISTS ventas_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ventas_db;

CREATE TABLE IF NOT EXISTS venta (
    id_venta         BIGINT AUTO_INCREMENT PRIMARY KEY,
    direccion_compra VARCHAR(255) NOT NULL,
    valor_compra     INT          NOT NULL,
    fecha_compra     DATE         NOT NULL,
    despacho_generado BOOLEAN     DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Base de datos del servicio Despachos
CREATE DATABASE IF NOT EXISTS despachos_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE despachos_db;

CREATE TABLE IF NOT EXISTS despacho (
    id_despacho       BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha_despacho    DATE,
    patente_camion    VARCHAR(255),
    intento           INT,
    id_compra         BIGINT,
    direccion_compra  VARCHAR(255),
    valor_compra      BIGINT,
    despachado        BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
