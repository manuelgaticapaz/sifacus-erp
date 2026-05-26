const CategoriaService = require('../services/categoriaService');
const categoriaController = {
    async getAll(req, res) {
        try { res.status(200).json({ success: true, data: await CategoriaService.listar() }); }
        catch (err) { res.status(500).json({ success: false, error: err.message }); }
    },
    async create(req, res) {
        try { res.status(201).json({ success: true, message: 'Categoría creada exitosamente.', id: await CategoriaService.crear(req.body) }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    },
    async update(req, res) {
        try { await CategoriaService.actualizar(req.params.id, req.body); res.status(200).json({ success: true, message: 'Categoría actualizada.' }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    },
    async delete(req, res) {
        try { await CategoriaService.eliminar(req.params.id); res.status(200).json({ success: true, message: 'Categoría eliminada.' }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    }
};
module.exports = categoriaController;