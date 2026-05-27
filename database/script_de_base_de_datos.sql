-- =====================================================================
-- PROYECTO ACADÉMICO PARA LA MATERIA: BASE DE DATOS II
-- TEMA: SISTEMA ERP DE INVENTARIO, VENTAS Y FACTURACIÓN (SIFACUS-ERP)
-- MOTOR: MySQL v8.0+
-- AUTOR: Diseñador Senior de Base de Datos
-- =====================================================================

-- 1. CREACIÓN DE LA BASE DE DATOS Y SELECCIÓN DE CONTEXTO
DROP DATABASE IF EXISTS erp_ventas;
CREATE DATABASE erp_ventas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE erp_ventas;

-- =====================================================================
-- 2. DDL - CREACIÓN DE TABLAS (INTEGRIDAD REFERENCIAL Y RESTRICCIONES)
-- =====================================================================

-- TABLA: CATEGORÍAS
CREATE TABLE categorias (
    id INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_categorias PRIMARY KEY (id),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- TABLA: PRODUCTOS (Mantiene precio y existencias del inventario)
CREATE TABLE productos (
    id INT AUTO_INCREMENT,
    sku VARCHAR(50) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    precio_compra DECIMAL(12, 2) NOT NULL,
    precio_venta DECIMAL(12, 2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5,
    categoria_id INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_productos PRIMARY KEY (id),
    CONSTRAINT uq_producto_sku UNIQUE (sku),
    CONSTRAINT fk_productos_categorias FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_producto_precios CHECK (precio_venta >= precio_compra AND precio_compra >= 0),
    CONSTRAINT chk_producto_stock CHECK (stock_actual >= 0 AND stock_minimo >= 0)
) ENGINE=InnoDB;

-- TABLA: CLIENTES
CREATE TABLE clientes (
    id INT AUTO_INCREMENT,
    rut_dni VARCHAR(20) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(100) NULL,
    telefono VARCHAR(30) NULL,
    clasificacion VARCHAR(20) NOT NULL DEFAULT 'BRONCE', -- BRONCE, PLATA, ORO (Fidelidad)
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_clientes PRIMARY KEY (id),
    CONSTRAINT uq_cliente_rut_dni UNIQUE (rut_dni),
    CONSTRAINT chk_cliente_clasificacion CHECK (clasificacion IN ('BRONCE', 'PLATA', 'ORO'))
) ENGINE=InnoDB;

-- TABLA: USUARIOS (Personal de la empresa)
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    rol VARCHAR(30) NOT NULL DEFAULT 'CAJERO', -- CAJERO, ADMINISTRADOR
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios PRIMARY KEY (id),
    CONSTRAINT uq_usuario_username UNIQUE (username),
    CONSTRAINT uq_usuario_email UNIQUE (email),
    CONSTRAINT chk_usuario_rol CHECK (rol IN ('CAJERO', 'ADMINISTRADOR'))
) ENGINE=InnoDB;

-- TABLA: VENTAS_CABECERA (Encabezado de facturas)
CREATE TABLE ventas_cabecera (
    id INT AUTO_INCREMENT,
    correlativo VARCHAR(30) NOT NULL,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    impuesto_iva DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'COMPLETADO', -- COMPLETADO, ANULADO
    CONSTRAINT pk_ventas_cabecera PRIMARY KEY (id),
    CONSTRAINT uq_venta_correlativo UNIQUE (correlativo),
    CONSTRAINT fk_ventas_clientes FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_ventas_usuarios FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT chk_venta_estado CHECK (estado IN ('COMPLETADO', 'ANULADO')),
    CONSTRAINT chk_venta_montos CHECK (total >= 0 AND subtotal >= 0)
) ENGINE=InnoDB;

-- TABLA: VENTAS_DETALLE (Detalle inmutable de cada transacción)
CREATE TABLE ventas_detalle (
    id INT AUTO_INCREMENT,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12, 2) NOT NULL,
    subtotal_linea DECIMAL(12, 2) NOT NULL,
    CONSTRAINT pk_ventas_detalle PRIMARY KEY (id),
    CONSTRAINT fk_detalle_cabecera FOREIGN KEY (venta_id) 
        REFERENCES ventas_cabecera(id) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_productos FOREIGN KEY (producto_id) 
        REFERENCES productos(id) ON DELETE RESTRICT,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario >= 0)
) ENGINE=InnoDB;

-- TABLA: AUDITORÍA DE PRECIOS (Registrada automáticamente vía Trigger)
CREATE TABLE auditoria_precios (
    id INT AUTO_INCREMENT,
    producto_id INT NOT NULL,
    precio_anterior DECIMAL(12, 2) NOT NULL,
    precio_nuevo DECIMAL(12, 2) NOT NULL,
    usuario_id INT NULL, -- ID del usuario que autorizó el cambio en la aplicación
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_auditoria_precios PRIMARY KEY (id),
    CONSTRAINT fk_audit_precios_productos FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- TABLA: AUDITORÍA DE MOVIMIENTOS DE INVENTARIO (Registrada automáticamente vía Trigger o SP)
CREATE TABLE auditoria_inventario (
    id INT AUTO_INCREMENT,
    producto_id INT NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    tipo_movimiento VARCHAR(50) NOT NULL, -- VENTA, INGRESO_MANUAL, REABASTECIMIENTO, AJUSTE
    referencia_id INT NULL, -- ID de venta o documento asociado
    fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_auditoria_inventario PRIMARY KEY (id),
    CONSTRAINT fk_audit_inv_productos FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- =====================================================================
-- 3. DML - INSERCIÓN DE DATOS DE PRUEBA (SEMILLAS)
-- =====================================================================

-- Semillas: Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Tecnología', 'Equipos de cómputo, componentes de hardware y accesorios'),
('Consolas y Videojuegos', 'Sistemas de entretenimiento para TV, consolas y juegos físicos'),
('Línea Blanca', 'Electrodomésticos principales para cocina y hogar');

-- Semillas: Productos
INSERT INTO productos (sku, nombre, descripcion, precio_compra, precio_venta, stock_actual, stock_minimo, categoria_id) VALUES
('PROD-LAP-001', 'Laptop Lenovo ThinkPad T14', 'Procesador Intel i7, 16GB RAM, 512GB SSD', 850.00, 1200.00, 15, 3, 1),
('PROD-LAP-002', 'Laptop Asus Zenbook Pro', 'Procesador AMD Ryzen 9, 32GB RAM, OLED Screen', 1200.00, 1750.00, 2, 5, 1),
('PROD-CON-003', 'PlayStation 5 Slim 1TB', 'Consola con lector de discos, edición Slim', 400.00, 580.00, 10, 2, 2),
('PROD-CON-004', 'Nintendo Switch OLED', 'Consola portátil con pantalla OLED de 7 pulgadas', 250.00, 360.00, 8, 3, 2),
('PROD-REF-001', 'Refrigeradora Samsung 400L', 'Tecnología No Frost, color cromado', 450.00, 699.00, 6, 2, 3);

-- Semillas: Clientes (Con diferentes tiers de fidelización)
INSERT INTO clientes (rut_dni, nombre, email, telefono, clasificacion) VALUES
('11111111-1', 'Juan Pérez Gómez', 'juan.perez@email.com', '+56911112222', 'BRONCE'),
('22222222-2', 'María Rodríguez Solís', 'maria.rodriguez@email.com', '+56922223333', 'PLATA'),
('33333333-3', 'Corporación Retail S.A.', 'compras@corporacionretail.com', '+56933334444', 'ORO');

-- Semillas: Usuarios
INSERT INTO usuarios (username, password_hash, email, rol) VALUES
('admin01', '$2b$10$U8fBgh5e9z6H76v7r2S8Ou1kE1H5rJEq0qK6qK3YvBvLg/oNf999S', 'admin@sifacus.com', 'ADMINISTRADOR'),
('cajero01', '$2b$10$T8dBgh5e9z6H76v7r2S8Ou1kE1H5rJEq0qK6qK3YvBvLg/oNf111S', 'caja1@sifacus.com', 'CAJERO');


-- =====================================================================
-- 4. FUNCIONES SQL (Lógica de Negocio Reutilizable)
-- =====================================================================

DELIMITER //

-- FUNCIÓN 1: Calcular IVA (19% según estándar aplicable)
CREATE FUNCTION fn_calcular_iva(monto DECIMAL(12, 2))
RETURNS DECIMAL(12, 2)
DETERMINISTIC
BEGIN
    DECLARE tasa_iva DECIMAL(4, 2);
    SET tasa_iva = 0.19; -- Representa el 19%
    RETURN ROUND(monto * tasa_iva, 2);
END //

-- FUNCIÓN 2: Obtener porcentaje de descuento aplicable por fidelidad y volumen
CREATE FUNCTION fn_obtener_descuento_cliente(p_cliente_id INT, p_subtotal DECIMAL(12, 2))
RETURNS DECIMAL(12, 2)
READS SQL DATA
BEGIN
    DECLARE v_clasificacion VARCHAR(20);
    DECLARE v_porcentaje_descuento DECIMAL(5, 4) DEFAULT 0.0000;
    
    -- Recuperar nivel de fidelidad del cliente
    SELECT clasificacion INTO v_clasificacion 
    FROM clientes 
    WHERE id = p_cliente_id;
    
    -- Aplicar reglas de descuento cruzadas (fidelidad + volumen de compra)
    IF v_clasificacion = 'ORO' THEN
        SET v_porcentaje_descuento = 0.10; -- 10% base
    ELSEIF v_clasificacion = 'PLATA' THEN
        SET v_porcentaje_descuento = 0.05; -- 5% base
    ELSE
        SET v_porcentaje_descuento = 0.00; -- 0% base
    END IF;
    
    -- Estímulo extra si compra más de 2000 USD
    IF p_subtotal > 2000.00 THEN
        SET v_porcentaje_descuento = v_porcentaje_descuento + 0.03; -- +3% adicional
    END IF;
    
    RETURN ROUND(p_subtotal * v_porcentaje_descuento, 2);
END //

DELIMITER ;


-- =====================================================================
-- 5. DISPARADORES (TRIGGERS - Automatización y Auditoría Inmutable)
-- =====================================================================

DELIMITER //

-- TRIGGER 1: Auditoría Inmutable ante cambios de precio en el catálogo de productos
CREATE TRIGGER tr_auditar_cambio_precio
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Solo auditar si efectivamente el precio de venta cambió
    IF OLD.precio_venta <> NEW.precio_venta THEN
        INSERT INTO auditoria_precios (producto_id, precio_anterior, precio_nuevo, usuario_id)
        VALUES (OLD.id, OLD.precio_venta, NEW.precio_venta, @usuario_ejecutor_id); 
        -- @usuario_ejecutor_id es una variable de sesión MySQL seteada por el backend en cada conexión
    END IF;
END //

-- TRIGGER 2: Registro de historial detallado de movimientos físicos de stock (Auditoría de Inventario)
CREATE TRIGGER tr_audit_inventario_despues_modificacion
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    DECLARE v_diferencia INT;
    SET v_diferencia = NEW.stock_actual - OLD.stock_actual;
    
    -- Solo gatillar auditoría si el inventario físico varió
    IF v_diferencia <> 0 THEN
        INSERT INTO auditoria_inventario (producto_id, stock_anterior, stock_nuevo, tipo_movimiento, referencia_id)
        VALUES (
            OLD.id, 
            OLD.stock_actual, 
            NEW.stock_actual, 
            COALESCE(@tipo_movimiento_actual, 'AJUSTE_MANUAL'), -- Se extrae de variable de sesión o cae a default
            @referencia_documento_id
        );
    END IF;
END //

DELIMITER ;


-- =====================================================================
-- 6. PROCEDIMIENTOS ALMACENADOS (Stored Procedures - Transacciones Fuertes)
-- =====================================================================

DELIMITER //

-- PROCEDIMIENTO 1: Registro Transaccional Completo de Venta (Manejo de JSON para detalles)
-- Este procedimiento es atómico: descuenta stock, calcula impuestos, aplica descuentos,
-- escribe cabecera, escribe detalle y escribe auditoría de inventario.
CREATE PROCEDURE sp_registrar_venta(
    IN p_cliente_id INT,
    IN p_usuario_id INT,
    IN p_detalles_json JSON, -- Estructura: [{"producto_id": 1, "cantidad": 2}, ...]
    OUT p_venta_id_creada INT,
    OUT p_correlativo_generado VARCHAR(30)
)
proc_label:BEGIN
    -- Declarar variables de control y cálculo
    DECLARE v_subtotal DECIMAL(12, 2) DEFAULT 0.00;
    DECLARE v_descuento DECIMAL(12, 2) DEFAULT 0.00;
    DECLARE v_iva DECIMAL(12, 2) DEFAULT 0.00;
    DECLARE v_total DECIMAL(12, 2) DEFAULT 0.00;
    
    -- Variables para el bucle de validación de ítems
    DECLARE v_index INT DEFAULT 0;
    DECLARE v_total_items INT;
    DECLARE v_prod_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_stock_actual INT;
    DECLARE v_precio_unitario DECIMAL(12,2);
    DECLARE v_subtotal_item DECIMAL(12,2);
    
    -- Manejador de excepciones SQL (Rollback en caso de error de concurrencia o de base)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error Transaccional: Falló el registro de venta. Se aplicó Rollback.';
    END;

    -- Configurar variables de sesión para que el disparador registre el tipo de movimiento
    SET @tipo_movimiento_actual = 'VENTA';

    -- Iniciar Transacción Atómica
    START TRANSACTION;

    -- 1. Validar la existencia de cliente y usuario
    IF NOT EXISTS(SELECT 1 FROM clientes WHERE id = p_cliente_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no registrado.';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM usuarios WHERE id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario/Cajero no existe.';
    END IF;

    -- 2. Calcular cuántos items componen el arreglo JSON
    SET v_total_items = JSON_LENGTH(p_detalles_json);
    IF v_total_items = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no contiene ningún ítem.';
    END IF;

    -- Generar un número de documento secuencial ficticio (Correlativo único)
    SELECT CONCAT('FAC-', LPAD(COALESCE(MAX(id), 0) + 1, 8, '0')) INTO p_correlativo_generado 
    FROM ventas_cabecera;

    -- 3. Crear cabecera vacía temporal para obtener el ID de venta incremental
    INSERT INTO ventas_cabecera (correlativo, cliente_id, usuario_id, subtotal, impuesto_iva, descuento, total, estado)
    VALUES (p_correlativo_generado, p_cliente_id, p_usuario_id, 0, 0, 0, 0, 'COMPLETADO');
    
    SET p_venta_id_creada = LAST_INSERT_ID();
    SET @referencia_documento_id = p_venta_id_creada; -- Seteo para el trigger de inventario

    -- 4. Bucle para recorrer el JSON, validar stock, calcular totales y poblar detalles
    WHILE v_index < v_total_items DO
        -- Extraer parámetros del ítem JSON actual
        SET v_prod_id = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_detalles_json, CONCAT('$[', v_index, '].producto_id'))) AS SIGNED);
        SET v_cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_detalles_json, CONCAT('$[', v_index, '].cantidad'))) AS SIGNED);
        
        -- Obtener stock y precio actual del producto (con bloqueo de fila FOR UPDATE para prevenir condiciones de carrera)
        SELECT stock_actual, precio_venta INTO v_stock_actual, v_precio_unitario
        FROM productos 
        WHERE id = v_prod_id 
        FOR UPDATE;
        
        -- Validar disponibilidad física real
        IF v_stock_actual < v_cantidad THEN
            -- Desencadenar un error controlado de negocio que anula todo lo avanzado en la transacción
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para uno de los productos solicitados.';
        END IF;
        
        -- Descontar el stock (Gatilla trigger: `tr_audit_inventario_despues_modificacion`)
        UPDATE productos 
        SET stock_actual = stock_actual - v_cantidad 
        WHERE id = v_prod_id;
        
        -- Calcular montos de la línea de detalle
        SET v_subtotal_item = v_precio_unitario * v_cantidad;
        SET v_subtotal = v_subtotal + v_subtotal_item;
        
        -- Insertar el ítem en la tabla de detalles
        INSERT INTO ventas_detalle (venta_id, producto_id, cantidad, precio_unitario, subtotal_linea)
        VALUES (p_venta_id_creada, v_prod_id, v_cantidad, v_precio_unitario, v_subtotal_item);
        
        -- Incrementar índice para evaluar la siguiente fila del arreglo JSON
        SET v_index = v_index + 1;
    END WHILE;

    -- 5. Ejecutar la lógica de negocio mediante las funciones integradas
    SET v_descuento = fn_obtener_descuento_cliente(p_cliente_id, v_subtotal);
    SET v_iva = fn_calcular_iva(v_subtotal - v_descuento);
    SET v_total = (v_subtotal - v_descuento) + v_iva;

    -- 6. Actualizar la cabecera de la venta con los totales consolidados finales
    UPDATE ventas_cabecera 
    SET subtotal = v_subtotal,
        impuesto_iva = v_iva,
        descuento = v_descuento,
        total = v_total
    WHERE id = p_venta_id_creada;

    -- Confirmar y consolidar la transacción en disco duro
    COMMIT;
    
    -- Limpieza de variables de sesión
    SET @tipo_movimiento_actual = NULL;
    SET @referencia_documento_id = NULL;
END //

-- PROCEDIMIENTO 2: Reporte Analítico de Ventas por Período
CREATE PROCEDURE sp_reporte_ventas_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        DATE(fecha_venta) AS fecha,
        COUNT(id) AS cantidad_transacciones,
        SUM(subtotal) AS subtotal_acumulado,
        SUM(impuesto_iva) AS impuestos_acumulados,
        SUM(descuento) AS descuentos_aplicados,
        SUM(total) AS total_recaudado
    FROM ventas_cabecera
    WHERE DATE(fecha_venta) BETWEEN p_fecha_inicio AND p_fecha_fin
      AND estado = 'COMPLETADO'
    GROUP BY DATE(fecha_venta)
    ORDER BY fecha DESC;
END //

-- PROCEDIMIENTO 3: Reabastecimiento manual controlado de inventarios
CREATE PROCEDURE sp_reabastecer_producto(
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_usuario_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el reabastecimiento.';
    END;

    -- Seteo de auditoría para el Trigger
    SET @tipo_movimiento_actual = 'REABASTECIMIENTO';
    SET @usuario_ejecutor_id = p_usuario_id;

    START TRANSACTION;
        -- Actualizar el inventario físico
        UPDATE productos 
        SET stock_actual = stock_actual + p_cantidad 
        WHERE id = p_producto_id;
    COMMIT;

    SET @tipo_movimiento_actual = NULL;
    SET @usuario_ejecutor_id = NULL;
END //

DELIMITER ;


-- =====================================================================
-- 7. VISTAS (Views - Abstracción y Capas de Seguridad)
-- =====================================================================

-- VISTA 1: Alerta Temprana de Stock Crítico (Productos por debajo de su stock mínimo)
CREATE VIEW vw_productos_bajo_stock_minimo AS
SELECT 
    p.id AS producto_id,
    p.sku,
    p.nombre,
    c.nombre AS categoria,
    p.stock_actual,
    p.stock_minimo,
    (p.stock_actual - p.stock_minimo) AS diferencia
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock_actual <= p.stock_minimo AND p.activo = TRUE
ORDER BY diferencia ASC;

-- VISTA 2: Clientes más activos y con mayor volumen de aportación de capital (Top 10)
CREATE VIEW vw_clientes_mas_activos AS
SELECT 
    cl.id AS cliente_id,
    cl.rut_dni,
    cl.nombre AS cliente_nombre,
    cl.clasificacion,
    COUNT(vc.id) AS total_compras,
    SUM(vc.total) AS monto_total_gastado
FROM clientes cl
LEFT JOIN ventas_cabecera vc ON cl.id = vc.cliente_id AND vc.estado = 'COMPLETADO'
GROUP BY cl.id, cl.rut_dni, cl.nombre, cl.clasificacion
ORDER BY monto_total_gastado DESC;

-- VISTA 3: Últimas facturas emitidas (Para el visor de facturas rápido)
CREATE VIEW vw_ultimas_facturas AS
SELECT 
    vc.correlativo,
    vc.fecha_venta,
    COALESCE(cl.nombre, 'Consumidor Final') AS cliente_nombre,
    (SELECT SUM(cantidad) FROM ventas_detalle WHERE venta_id = vc.id) AS cantidad_productos,
    vc.total AS total_venta
FROM ventas_cabecera vc
LEFT JOIN clientes cl ON vc.cliente_id = cl.id
WHERE vc.estado = 'COMPLETADO'
ORDER BY vc.fecha_venta DESC
LIMIT 30;

-- VISTA 4: Dashboard de Resumen (Indicadores Clave de Rendimiento)
CREATE VIEW vw_dashboard_resumen AS
SELECT 
    (SELECT COALESCE(SUM(total), 0) FROM ventas_cabecera WHERE DATE(fecha_venta) = CURDATE() AND estado = 'COMPLETADO') AS ventas_hoy,
    (SELECT COALESCE(SUM(total), 0) FROM ventas_cabecera WHERE MONTH(fecha_venta) = MONTH(CURDATE()) AND YEAR(fecha_venta) = YEAR(CURDATE()) AND estado = 'COMPLETADO') AS ventas_mes,
    (SELECT COUNT(*) FROM vw_productos_bajo_stock_minimo) AS productos_alerta_stock,
    (SELECT COUNT(*) FROM clientes) AS total_clientes;


-- =====================================================================
-- 8. ÍNDICES DE RENDIMIENTO (Performance Tuning)
-- =====================================================================

-- El índice sobre clave primaria e identificadores foráneos se genera implícitamente.
-- A continuación se configuran índices clave para optimizar búsquedas frecuentes:

-- 1. Búsqueda exacta y ultrarrápida de productos por código SKU comercial
CREATE UNIQUE INDEX idx_productos_sku ON productos(sku);

-- 2. Optimización para la vista analítica de stock crítico y categorización de artículos
CREATE INDEX idx_productos_categoria_stock ON productos(categoria_id, stock_actual);

-- 3. Índice compuesto optimizando la consulta de historial de compras de un cliente en un rango temporal
CREATE INDEX idx_ventas_cliente_fecha ON ventas_cabecera(cliente_id, fecha_venta);

-- 4. Optimización de la indexación temporal para el cierre de caja y reportes analíticos diarios
CREATE INDEX idx_ventas_fecha_venta ON ventas_cabecera(fecha_venta);

-- 5. Optimización del cruzamiento de líneas de pedido por producto (Rotación de Inventario)
CREATE INDEX idx_ventas_detalle_producto ON ventas_detalle(producto_id);

-- =====================================================================
-- FIN DEL ESQUEMA DDL Y DML DE INSTALACIÓN
-- =====================================================================