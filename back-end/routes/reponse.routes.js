const express = require('express');
const router = express.Router();
const reponseController = require('../controllers/reponse.controller');

router.post('/', reponseController.soumettreReponse);

module.exports = router;
