const mongoose = require('mongoose');

const reponseSchema = new mongoose.Schema({
  eleveId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  questionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Question', required: true },
  reponseDonnee: { type: String, required: true },
  estCorrecte: { type: Boolean, required: true },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Reponse', reponseSchema);
