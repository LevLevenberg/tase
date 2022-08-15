
const express = require('express');
const router = express.Router();
const counterCtrl = require('../controllers/counterController');
const { v4: uuid } = require('uuid');

//increment counter
router
.route('/inc')
.post(counterCtrl.increment);

module.exports = router;