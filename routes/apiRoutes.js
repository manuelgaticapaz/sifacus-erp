const express = require('express');
const router = express.Router();
const productoController = require('../controllers/productoController');
const ventaController = require('../controllers/ventaController');
const categoriaController = require('../controllers/categoriaController');
const clienteController = require('../controllers/clienteController');

// Rutas de Productos
router.get('/productos', productoController.getAll);
router.post('/productos', productoController.create);
router.get('/productos/alertas-stock', productoController.getAlertasStock); // Debe ir antes del :id
router.put('/productos/:id/precio', productoController.updatePrecio);
router.post('/productos/:id/reabastecer', productoController.reabastecer);
router.put('/productos/:id', productoController.update);
router.delete('/productos/:id', productoController.delete);

// Rutas de Ventas y Clientes
router.post('/ventas', ventaController.procesarVenta);
router.get('/ventas/reporte', ventaController.getReporte);
router.get('/clientes/top', ventaController.getTopClientes);

// ✅ CORRECTO: Las rutas fijas van primero
router.get('/ventas/recientes', ventaController.getRecientes);
router.get('/dashboard', ventaController.getDashboard);
// ✅ CORRECTO: Las rutas con parámetros dinámicos (:id) van al final
router.get('/ventas/:id', ventaController.getVenta);

// Rutas de Categorías
router.get('/categorias', categoriaController.getAll);
router.post('/categorias', categoriaController.create);
router.put('/categorias/:id', categoriaController.update);
router.delete('/categorias/:id', categoriaController.delete);

// Rutas de Clientes (Gestión)
router.get('/clientes', clienteController.getAll);
router.post('/clientes', clienteController.create);
router.put('/clientes/:id', clienteController.update);
router.delete('/clientes/:id', clienteController.delete);

module.exports = router;
