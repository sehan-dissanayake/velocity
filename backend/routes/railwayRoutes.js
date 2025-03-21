const express = require('express');
const router = express.Router();
const railwayController = require('../controllers/railwayController');

router.get('/', railwayController.getAllStations);

module.exports = router;