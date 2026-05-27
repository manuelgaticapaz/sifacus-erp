const VentaService = require('../services/ventaService');

const ventaController = {
    async procesarVenta(req, res) {
        try {
            const comprobante = await VentaService.procesarVenta(req.body);
            res.status(201).json({ success: true, message: 'Venta procesada con éxito y stock descontado.', data: comprobante });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async getReporte(req, res) {
        try {
            const { fecha_inicio, fecha_fin } = req.query;
            const reporte = await VentaService.obtenerReporteVentas(fecha_inicio, fecha_fin);
            res.status(200).json({ success: true, data: reporte });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async getTopClientes(req, res) {
        try {
            const topClientes = await VentaService.obtenerClientesMasActivos();
            res.status(200).json({ success: true, data: topClientes });
        } catch (err) {
            res.status(500).json({ success: false, error: err.message });
        }
    },

    async getRecientes(req, res) {
        try {
            const facturas = await VentaService.obtenerUltimasFacturas();
            res.status(200).json({ success: true, data: facturas });
        } catch (err) {
            res.status(500).json({ success: false, error: err.message });
        }
    },

    async getVenta(req, res) {
        try {
            const venta = await VentaService.obtenerVenta(req.params.id);
            if (!venta) return res.status(404).json({ success: false, error: 'Venta/Factura no encontrada en la BD.' });
            res.status(200).json({ success: true, data: venta });
        } catch (err) {
            res.status(500).json({ success: false, error: err.message });
        }
    }
};
module.exports = ventaController;