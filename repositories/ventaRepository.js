const pool = require('../config/database');

const VentaRepository = {
    async registrarVentaTransaccional(clienteId, usuarioId, detallesArray) {
        const detallesJSON = JSON.stringify(detallesArray);
        
        const query = 'CALL sp_registrar_venta(?, ?, ?, @v_id, @v_correlativo)';
        await pool.query(query, [clienteId, usuarioId, detallesJSON]);
        
        const [outParams] = await pool.query('SELECT @v_id AS venta_id, @v_correlativo AS correlativo');
        return outParams[0];
    },

    async getReportePeriodo(fechaInicio, fechaFin) {
        const [rows] = await pool.query('CALL sp_reporte_ventas_periodo(?, ?)', [fechaInicio, fechaFin]);
        return rows[0]; 
    },

    async getClientesMasActivos() {
        const [rows] = await pool.query('SELECT * FROM vw_clientes_mas_activos');
        return rows;
    },

    async getVentaCompleta(referencia) {
        const [cabecera] = await pool.query(`
            SELECT v.*, c.rut_dni AS cliente_rut, c.nombre AS cliente_nombre, c.clasificacion AS cliente_clasificacion
            FROM ventas_cabecera v
            LEFT JOIN clientes c ON v.cliente_id = c.id
            WHERE v.id = ? OR v.correlativo = ?`, [referencia, referencia]);
        if (!cabecera.length) return null;
        const [detalles] = await pool.query(`
            SELECT vd.*, p.nombre, p.sku 
            FROM ventas_detalle vd 
            INNER JOIN productos p ON vd.producto_id = p.id 
            WHERE vd.venta_id = ?`, [cabecera[0].id]);
        return { cabecera: cabecera[0], detalles };
    }
};

module.exports = VentaRepository;