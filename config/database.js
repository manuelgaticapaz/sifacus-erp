const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'erp_ventas',
    port: parseInt(process.env.DB_PORT || '3306'),
    waitForConnections: true,
    connectionLimit: 15,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

pool.getConnection()
    .then(conn => {
        console.log(`Conexión establecida exitosamente con el Pool de MySQL en '${dbConfig.database}'.`);
        conn.release();
    })
    .catch(err => {
        console.error('Error crítico al conectar a la Base de Datos:', err.message);
    });

module.exports = pool;