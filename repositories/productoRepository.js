const pool = require('../config/database');

const ProductoRepository = {
    async getAll() {
        const [rows] = await pool.query('SELECT * FROM productos WHERE activo = TRUE');
        return rows;
    },

    async create(producto) {
        const query = `INSERT INTO productos 
            (sku, nombre, descripcion, precio_compra, precio_venta, stock_actual, stock_minimo, categoria_id) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
        const values = [
            producto.sku, producto.nombre, producto.descripcion,
            producto.precio_compra, producto.precio_venta,
            producto.stock_actual, producto.stock_minimo, producto.categoria_id
        ];
        const [result] = await pool.query(query, values);
        return result.insertId;
    },

    async updatePrecio(id, nuevoPrecio, usuarioId) {
        const conn = await pool.getConnection();
        try {
            await conn.beginTransaction();
            await conn.query('SET @usuario_ejecutor_id = ?', [usuarioId]);
            
            await conn.query('UPDATE productos SET precio_venta = ? WHERE id = ?', [nuevoPrecio, id]);
            
            await conn.commit();
            return true;
        } catch (error) {
            await conn.rollback();
            throw error;
        } finally {
            await conn.query('SET @usuario_ejecutor_id = NULL');
            conn.release();
        }
    },

    async reabastecer(id, cantidad, usuarioId) {
        const query = 'CALL sp_reabastecer_producto(?, ?, ?)';
        await pool.query(query, [id, cantidad, usuarioId]);
        return true;
    },

    async update(id, p) {
        const query = `UPDATE productos SET nombre=?, descripcion=?, precio_compra=?, precio_venta=?, stock_minimo=?, categoria_id=? WHERE id=?`;
        await pool.query(query, [p.nombre, p.descripcion, p.precio_compra, p.precio_venta, p.stock_minimo, p.categoria_id, id]);
        return true;
    },

    async delete(id) {
        await pool.query('UPDATE productos SET activo = FALSE WHERE id = ?', [id]);
        return true;
    },

    async getAlertasStock() {
        const [rows] = await pool.query('SELECT * FROM vw_productos_bajo_stock_minimo');
        return rows;
    }
};

module.exports = ProductoRepository;