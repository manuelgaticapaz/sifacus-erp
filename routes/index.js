const express = require('express');
const router = express.Router();
const apiRoutes = require('./apiRoutes');

// Montar todas las rutas de la API bajo el prefijo /api
router.use('/api', apiRoutes);

module.exports = router;