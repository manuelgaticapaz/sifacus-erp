const ClienteService = require('../services/clienteService');
const clienteController = {
    async getAll(req, res) {
        try { res.status(200).json({ success: true, data: await ClienteService.listar() }); }
        catch (err) { res.status(500).json({ success: false, error: err.message }); }
    },
    async create(req, res) {
        try { res.status(201).json({ success: true, message: 'Cliente registrado exitosamente.', id: await ClienteService.crear(req.body) }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    },
    async update(req, res) {
        try { await ClienteService.actualizar(req.params.id, req.body); res.status(200).json({ success: true, message: 'Cliente actualizado.' }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    },
    async delete(req, res) {
        try { await ClienteService.eliminar(req.params.id); res.status(200).json({ success: true, message: 'Cliente eliminado.' }); }
        catch (err) { res.status(400).json({ success: false, error: err.message }); }
    }
};
module.exports = clienteController;