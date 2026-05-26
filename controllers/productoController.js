const ProductoService = require('../services/productoService');

const productoController = {
    async getAll(req, res) {
        try {
            const productos = await ProductoService.listarProductos();
            res.status(200).json({ success: true, data: productos });
        } catch (err) {
            res.status(500).json({ success: false, error: err.message });
        }
    },

    async create(req, res) {
        try {
            const nuevoId = await ProductoService.registrarProducto(req.body);
            res.status(201).json({ success: true, message: 'Producto creado exitosamente.', productId: nuevoId });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async updatePrecio(req, res) {
        try {
            const { id } = req.params;
            const { nuevo_precio, usuario_id } = req.body;
            if (!usuario_id) return res.status(400).json({ success: false, error: 'Debe especificar el usuario_id para fines de auditoría.' });
            await ProductoService.actualizarPrecioVenta(id, nuevo_precio, usuario_id);
            res.status(200).json({ success: true, message: 'Precio de producto actualizado exitosamente.' });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async reabastecer(req, res) {
        try {
            const { id } = req.params;
            const { cantidad, usuario_id } = req.body;
            await ProductoService.reabastecerProducto(id, cantidad, usuario_id);
            res.status(200).json({ success: true, message: 'Inventario reabastecido exitosamente.' });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async update(req, res) {
        try {
            await ProductoService.actualizarProducto(req.params.id, req.body);
            res.status(200).json({ success: true, message: 'Producto actualizado exitosamente.' });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async delete(req, res) {
        try {
            await ProductoService.eliminarProducto(req.params.id);
            res.status(200).json({ success: true, message: 'Producto eliminado (inactivado) exitosamente.' });
        } catch (err) {
            res.status(400).json({ success: false, error: err.message });
        }
    },

    async getAlertasStock(req, res) {
        try {
            const alertas = await ProductoService.obtenerAlertasStock();
            res.status(200).json({ success: true, data: alertas });
        } catch (err) {
            res.status(500).json({ success: false, error: err.message });
        }
    }
};
module.exports = productoController;