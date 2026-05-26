const CategoriaRepository = require('../repositories/categoriaRepository');
const CategoriaService = {
    async listar() { return await CategoriaRepository.getAll(); },
    async crear(data) { return await CategoriaRepository.create(data); },
    async actualizar(id, data) { return await CategoriaRepository.update(id, data); },
    async eliminar(id) { return await CategoriaRepository.delete(id); }
};
module.exports = CategoriaService;
