const ProductoRepository = require('../repositories/productoRepository');

const ProductoService = {
    async listarProductos() {
        return await ProductoRepository.getAll();
    },

    async registrarProducto(data) {
        if (data.precio_venta < data.precio_compra) {
            throw new Error('El precio de venta no puede ser menor al costo de adquisición (precio de compra).');
        }
        return await ProductoRepository.create(data);
    },

    async actualizarPrecioVenta(id, nuevoPrecio, usuarioId) {
        if (nuevoPrecio <= 0) {
            throw new Error('El precio de venta debe ser un número positivo.');
        }
        return await ProductoRepository.updatePrecio(id, nuevoPrecio, usuarioId);
    },

    async reabastecerProducto(id, cantidad, usuarioId) {
        if (cantidad <= 0) throw new Error('La cantidad a reabastecer debe ser un número positivo.');
        return await ProductoRepository.reabastecer(id, cantidad, usuarioId);
    },

    async actualizarProducto(id, data) {
        return await ProductoRepository.update(id, data);
    },

    async eliminarProducto(id) {
        return await ProductoRepository.delete(id);
    },

    async obtenerAlertasStock() {
        return await ProductoRepository.getAlertasStock();
    }
};

module.exports = ProductoService;