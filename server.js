require('dotenv').config();
const express = require('express');
const path = require('path');
const routes = require('./routes/index'); 

// Inicializa la conexión a la Base de Datos
require('./config/database');

const app = express();

// Middlewares globales
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Rutas principales
app.use('/', routes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`\n=================================================================`);
    console.log(`Servidor de Sifacus-ERP corriendo exitosamente en el puerto ${PORT}`);
    console.log(`Arquitectura: Node.js + Express + Pool MySQL2/Promise (3FN)`);
    console.log(`=================================================================\n`);
});