const VentaRepository = require('../repositories/ventaRepository');

const VentaService = {
    async procesarVenta(ventaData) {
        const { cliente_id, usuario_id, detalles } = ventaData;
        if (!cliente_id || !usuario_id || !detalles || detalles.length === 0) {
            throw new Error('Faltan datos requeridos de venta o el detalle está vacío.');
        }
        return await VentaRepository.registrarVentaTransaccional(cliente_id, usuario_id, detalles);
    },

    async obtenerReporteVentas(fechaInicio, fechaFin) {
        if (!fechaInicio || !fechaFin) {
            throw new Error('Debe proporcionar un rango válido de fechas (fecha_inicio, fecha_fin).');
        }
        return await VentaRepository.getReportePeriodo(fechaInicio, fechaFin);
    },

    async obtenerClientesMasActivos() {
        return await VentaRepository.getClientesMasActivos();
    },

    async obtenerVenta(referencia) {
        return await VentaRepository.getVentaCompleta(referencia);
    }
};

module.exports = VentaService;