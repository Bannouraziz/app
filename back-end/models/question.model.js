const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
  age: {
    type: Number,
    required: true
  },
  niveau: {
    type: String,
    required: true
  },
  question: {
    type: String,
    required: true
  },
  choix: [{
    type: String,
    required: true
  }],
  bonneReponse: {
    type: String,
    required: true
  },
  explication: {
    type: String,
    default: ''
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Question', questionSchema);
