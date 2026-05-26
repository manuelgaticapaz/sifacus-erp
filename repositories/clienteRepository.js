const pool = require('../config/database');
const ClienteRepository = {
    async getAll() {
        const [rows] = await pool.query('SELECT * FROM clientes');
        return rows;
    },
    async create(c) {
        const query = `INSERT INTO clientes (rut_dni, nombre, email, telefono, clasificacion) VALUES (?, ?, ?, ?, ?)`;
        const [result] = await pool.query(query, [c.rut_dni, c.nombre, c.email, c.telefono, c.clasificacion || 'BRONCE']);
        return result.insertId;
    },
    async update(id, c) {
        const query = `UPDATE clientes SET rut_dni=?, nombre=?, email=?, telefono=?, clasificacion=? WHERE id=?`;
        await pool.query(query, [c.rut_dni, c.nombre, c.email, c.telefono, c.clasificacion, id]);
        return true;
    },
    async delete(id) {
        await pool.query('DELETE FROM clientes WHERE id=?', [id]);
        return true;
    }
};
module.exports = ClienteRepository;