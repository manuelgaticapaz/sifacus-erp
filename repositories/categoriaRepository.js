const pool = require('../config/database');

const CategoriaRepository = {
    async getAll() {
        const [rows] = await pool.query('SELECT * FROM categorias');
        return rows;
    },
    async create(c) {
        const query = `INSERT INTO categorias (nombre, descripcion) VALUES (?, ?)`;
        const [result] = await pool.query(query, [c.nombre, c.descripcion]);
        return result.insertId;
    },
    async update(id, c) {
        const query = `UPDATE categorias SET nombre=?, descripcion=? WHERE id=?`;
        await pool.query(query, [c.nombre, c.descripcion, id]);
        return true;
    },
    async delete(id) {
        await pool.query('DELETE FROM categorias WHERE id=?', [id]);
        return true;
    }
};
module.exports = CategoriaRepository;