require('dotenv').config();
const mongoose = require('mongoose');
const Question = require('../models/question.model');

// Connection to MongoDB
mongoose
    .connect(process.env.MONGODB_URI)
    .then(() => console.log('Connected to MongoDB'))
    .catch((err) => console.error('Could not connect to MongoDB', err));

// Sample questions for various age groups and levels
const questions = [
    // Age 5-7 (Level 1)
    {
        age: 5,
        niveau: "1",
        question: "Combien font 2 + 3 ?",
        choix: ["4", "5", "6", "7"],
        bonneReponse: "5"
    },
    {
        age: 6,
        niveau: "1",
        question: "Quelle lettre vient après A ?",
        choix: ["B", "C", "D", "E"],
        bonneReponse: "B"
    },

    // Age 8-10 (Level 2)
    {
        age: 8,
        niveau: "2",
        question: "Combien font 7 × 8 ?",
        choix: ["48", "54", "56", "64"],
        bonneReponse: "56"
    },
    {
        age: 9,
        niveau: "2",
        question: "Quel est le plus grand océan du monde ?",
        choix: ["Océan Atlantique", "Océan Indien", "Océan Pacifique", "Océan Arctique"],
        bonneReponse: "Océan Pacifique"
    },

    // Age 11-13 (Level 3)
    {
        age: 11,
        niveau: "3",
        question: "Quelle est la capitale de l'Australie ?",
        choix: ["Sydney", "Melbourne", "Canberra", "Brisbane"],
        bonneReponse: "Canberra"
    },
    {
        age: 12,
        niveau: "3",
        question: "Quel est le résultat de 3² + 4² ?",
        choix: ["9", "16", "25", "32"],
        bonneReponse: "25"
    },

    // Age 14 (Level 1) - Added for teenagers
    {
        age: 14,
        niveau: "1",
        question: "Quel est le résultat de √144 ?",
        choix: ["10", "12", "14", "16"],
        bonneReponse: "12"
    },
    {
        age: 14,
        niveau: "1",
        question: "Quelle est la formule chimique de l'eau ?",
        choix: ["H₂O", "CO₂", "O₂", "N₂"],
        bonneReponse: "H₂O"
    },
    {
        age: 14,
        niveau: "1",
        question: "Qui a écrit 'Les Misérables' ?",
        choix: ["Victor Hugo", "Émile Zola", "Alexandre Dumas", "Albert Camus"],
        bonneReponse: "Victor Hugo"
    }
];

// Function to add questions to the database
async function addQuestions() {
    try {
        // Check if questions already exist
        const count = await Question.countDocuments();
        if (count > 0) {
            console.log(`${count} questions already exist in the database.`);
            const answer = await askQuestion('Do you want to add more sample questions? (y/n): ');
            if (answer.toLowerCase() !== 'y') {
                console.log('No questions were added.');
                return;
            }
        }

        // Add questions
        const result = await Question.insertMany(questions);
        console.log(`${result.length} questions added successfully!`);
    } catch (error) {
        console.error('Error adding questions:', error);
    } finally {
        mongoose.connection.close();
    }
}

// Helper function to ask questions in console
function askQuestion(question) {
    const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout
    });

    return new Promise(resolve => {
        readline.question(question, answer => {
            readline.close();
            resolve(answer);
        });
    });
}

// Run the function
addQuestions(); 