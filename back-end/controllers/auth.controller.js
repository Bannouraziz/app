const User = require('../models/user.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Enregistrement (Inscription)
exports.register = async (req, res) => {
  try {
    const { nomComplet, email, motDePasse } = req.body;

    // Vérifier si l'utilisateur existe déjà
    const userExist = await User.findOne({ nomComplet });
    if (userExist) {
      return res.status(400).json({ message: 'Nom d’utilisateur déjà pris' });
    }

    // Hasher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(motDePasse, salt);

    // Créer le nouvel utilisateur
    const newUser = new User({
      nomComplet,
      email,
      motDePasse: hashedPassword
    });

    await newUser.save();

    res.status(201).json({ message: 'Utilisateur créé avec succès' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Connexion (login)
exports.login = async (req, res) => {
  try {
    const { nomComplet, motDePasse } = req.body;

    const user = await User.findOne({ nomComplet });
    if (!user) {
      return res.status(404).json({ message: "Nom d'utilisateur incorrect" });
    }

    const isMatch = await bcrypt.compare(motDePasse, user.motDePasse);
    if (!isMatch) {
      return res.status(401).json({ message: "Mot de passe incorrect" });
    }

    const token = jwt.sign(
      { id: user._id, nomComplet: user.nomComplet },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      message: "Connexion réussie",
      token,
      utilisateur: {
        id: user._id,
        nomComplet: user.nomComplet
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
