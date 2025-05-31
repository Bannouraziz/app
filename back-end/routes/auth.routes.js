const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const Eleve = require('../models/eleve.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

router.post('/register', async (req, res) => {
    try {
        const { nom, prenom, email, password, age } = req.body;

        // Validate required fields
        if (!nom || !prenom || !email || !password || !age) {
            return res.status(400).json({
                message: 'Tous les champs sont requis',
                missing: {
                    nom: !nom,
                    prenom: !prenom,
                    email: !email,
                    password: !password,
                    age: !age
                }
            });
        }

        // Check if email already exists
        const existingEleve = await Eleve.findOne({ email });
        if (existingEleve) {
            return res.status(400).json({ message: 'Cet email est déjà utilisé' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create new student
        const eleve = new Eleve({
            nom,
            prenom,
            email,
            password: hashedPassword,
            age: parseInt(age),
            niveau: 1,
            niveauxCompletes: []
        });

        await eleve.save();

        // Generate token
        const token = jwt.sign(
            { id: eleve._id },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '24h' }
        );

        res.status(201).json({
            message: 'Inscription réussie',
            token,
            userId: eleve._id,
            utilisateur: {
                id: eleve._id,
                nomComplet: `${eleve.nom} ${eleve.prenom}`,
                email: eleve.email,
                age: eleve.age,
                niveau: eleve.niveau
            }
        });
    } catch (error) {
        console.error('Erreur lors de l\'inscription:', error);
        res.status(500).json({
            message: 'Erreur lors de l\'inscription',
            error: error.message
        });
    }
});

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate required fields
        if (!email || !password) {
            return res.status(400).json({
                message: 'Email et mot de passe requis',
                missing: {
                    email: !email,
                    password: !password
                }
            });
        }

        // Find student
        const eleve = await Eleve.findOne({ email });
        if (!eleve) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Check password
        const validPassword = await bcrypt.compare(password, eleve.password);
        if (!validPassword) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Generate token
        const token = jwt.sign(
            { id: eleve._id },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '24h' }
        );

        res.json({
            token,
            userId: eleve._id,
            message: 'Connexion réussie'
        });
    } catch (error) {
        console.error('Erreur lors de la connexion:', error);
        res.status(500).json({
            message: 'Erreur lors de la connexion',
            error: error.message
        });
    }
});

module.exports = router;
