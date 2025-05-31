const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

const eleveRoutes = require('./routes/eleve.routes');
app.use('/api/eleves', eleveRoutes);

app.get('/', (req, res) => {
  res.send('API backend éducatif opérationnelle 🎉');
});
const authRoutes = require('./routes/auth.routes');
app.use('/api/auth', authRoutes);

const questionRoutes = require('./routes/question.routes');
app.use('/api/questions', questionRoutes);

const reponseRoutes = require('./routes/reponse.routes');
app.use('/api/reponses', reponseRoutes);

const progressionRoutes = require('./routes/progression.routes');
app.use('/api/progression', progressionRoutes);

const authAdminRoutes = require('./routes/authAdmin.routes');
app.use('/api/admin', authAdminRoutes);


module.exports = app;
