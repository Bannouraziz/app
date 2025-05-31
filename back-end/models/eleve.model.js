const mongoose = require('mongoose');

const eleveSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  nom: {
    type: String,
    required: true,
    trim: true,
  },
  prenom: {
    type: String,
    required: true,
    trim: true,
  },
  age: {
    type: Number,
    required: true,
    min: 5,
    max: 18,
  },
  niveau: {
    type: Number,
    default: 0,
  },
  niveauxCompletes: {
    type: [Number],
    default: []
  },
  accessibleLevels: {
    type: [Boolean],
    default: function () {
      // By default, only level 0 is accessible
      return [true, false, false, false, false, false, false, false, false, false, false, false, false, false];
    }
  },
  completedLevels: {
    type: [Boolean],
    default: function () {
      // By default, no levels are completed
      return [false, false, false, false, false, false, false, false, false, false, false, false, false, false];
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
});

module.exports = mongoose.model('Eleve', eleveSchema);
