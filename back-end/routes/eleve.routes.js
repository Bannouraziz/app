const express = require('express');
const router = express.Router();
const eleveController = require('../controllers/eleve.controller');
const auth = require('../middleware/auth');
const Eleve = require('../models/eleve.model');

// Add profile endpoint
router.get('/profile', auth, async (req, res) => {
  try {
    const student = await Eleve.findById(req.userId);
    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }
    res.json({
      email: student.email,
      nom: student.nom,
      prenom: student.prenom,
      nomComplet: `${student.prenom} ${student.nom}`,
      niveau: student.niveau,
      age: student.age,
      niveauxCompletes: student.niveauxCompletes,
      accessibleLevels: student.accessibleLevels || Array(14).fill(false).map((_, i) => i <= student.niveau),
      completedLevels: student.completedLevels || Array(14).fill(false).map((_, i) => student.niveauxCompletes.includes(i))
    });
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Update student level progress
router.post('/update-progress', auth, async (req, res) => {
  try {
    const { level, accessibleLevels, completedLevels } = req.body;
    const student = await Eleve.findById(req.userId);

    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    console.log(`Updating progress for student ${student._id}, level ${level}`);

    // Update current level if provided and valid
    if (level !== undefined && Number.isInteger(level) && level >= 0) {
      student.niveau = Math.max(student.niveau, level);
    }

    // Update accessible levels if provided
    if (accessibleLevels && Array.isArray(accessibleLevels)) {
      // Ensure array is at least 14 elements
      if (accessibleLevels.length < 14) {
        student.accessibleLevels = [...accessibleLevels, ...Array(14 - accessibleLevels.length).fill(false)];
      } else {
        student.accessibleLevels = accessibleLevels.slice(0, 14);
      }
    }

    // Update completed levels if provided
    if (completedLevels && Array.isArray(completedLevels)) {
      // Ensure array is at least 14 elements
      if (completedLevels.length < 14) {
        student.completedLevels = [...completedLevels, ...Array(14 - completedLevels.length).fill(false)];
      } else {
        student.completedLevels = completedLevels.slice(0, 14);
      }

      // Update niveauxCompletes based on completedLevels
      student.niveauxCompletes = [];
      for (let i = 0; i < student.completedLevels.length; i++) {
        if (student.completedLevels[i]) {
          student.niveauxCompletes.push(i);
        }
      }
    }

    await student.save();
    console.log(`Progress updated successfully for student ${student._id}`);

    res.json({
      success: true,
      message: 'Progress updated successfully',
      currentLevel: student.niveau,
      niveauxCompletes: student.niveauxCompletes
    });
  } catch (error) {
    console.error('Error updating progress:', error);
    res.status(500).json({ message: error.message });
  }
});

router.post('/', eleveController.creerEleve);
router.get('/', eleveController.getEleves);
router.delete('/:id', eleveController.supprimerEleve);

module.exports = router;
