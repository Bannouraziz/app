const mongoose = require('mongoose');
require('dotenv').config({ path: '../.env' });

const Question = require('../models/question.model');

const questions = [
    {
        age: 7,
        niveau: "CE1",
        question: "Combien font 5 + 3 ?",
        choix: ["6", "7", "8", "9"],
        bonneReponse: "8"
    },
    {
        age: 7,
        niveau: "CE1",
        question: "Quel est le premier mois de l'année ?",
        choix: ["Février", "Janvier", "Mars", "Décembre"],
        bonneReponse: "Janvier"
    },
    {
        age: 8,
        niveau: "CE2",
        question: "Combien font 7 × 6 ?",
        choix: ["40", "42", "46", "48"],
        bonneReponse: "42"
    }
];

async function seedDatabase() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Clear existing questions
        await Question.deleteMany({});
        console.log('Cleared existing questions');

        // Insert new questions
        await Question.insertMany(questions);
        console.log('Added sample questions');

        mongoose.connection.close();
    } catch (error) {
        console.error('Error seeding database:', error);
        process.exit(1);
    }
}

seedDatabase();
