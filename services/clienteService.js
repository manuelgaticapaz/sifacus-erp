const ClienteRepository = require('../repositories/clienteRepository');
const ClienteService = {
    async listar() { return await ClienteRepository.getAll(); },
    async crear(data) { return await ClienteRepository.create(data); },
    async actualizar(id, data) { return await ClienteRepository.update(id, data); },
    async eliminar(id) { return await ClienteRepository.delete(id); }
};
module.exports = ClienteService;