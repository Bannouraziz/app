const express = require('express');
const router = express.Router();
const authAdminController = require('../controllers/authAdmin.controller');

router.post('/login', authAdminController.loginAdmin);

module.exports = router;
