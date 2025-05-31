const express = require('express');
const router = express.Router();
const questionController = require('../controllers/question.controller');
const Question = require('../models/question.model');
const Eleve = require('../models/eleve.model');
const auth = require('../middleware/auth');

// Get questions for a specific level and age range
router.get('/age/:age/niveau/:niveau', auth, questionController.getQuestionsParAgeEtNiveau);

// Get questions by level
router.get('/niveau/:niveau', auth, questionController.getQuestionsParNiveau);

// Get all questions
router.get('/', auth, questionController.getToutesLesQuestions);

// Get question by ID
router.get('/:id', auth, questionController.getQuestionParId);

// Add new question
router.post('/', auth, questionController.ajouterQuestion);

// Update question
router.put('/:id', auth, questionController.modifierQuestion);

// Delete question
router.delete('/:id', auth, questionController.supprimerQuestion);

// Get questions for a specific level based on age
router.get('/niveau/:niveau', auth, async (req, res) => {
    try {
        const student = await Eleve.findById(req.userId);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        const questions = await Question.find({
            niveau: req.params.niveau,
            ageMin: { $lte: student.age },
            ageMax: { $gte: student.age }
        });

        res.json(questions);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Submit answers for a level
router.post('/niveau/:niveau/submit', auth, async (req, res) => {
    try {
        const { answers } = req.body;
        const niveau = parseInt(req.params.niveau);

        console.log(`Processing answers for level ${niveau}: ${JSON.stringify(answers)}`);

        const student = await Eleve.findById(req.userId);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        // Get all questions for this level and age
        const questions = await Question.find({
            niveau: niveau.toString()
        });

        if (questions.length === 0) {
            return res.status(404).json({ message: 'No questions found for this level' });
        }

        console.log(`Found ${questions.length} questions for level ${niveau}`);

        // Check if all questions are answered
        if (!answers || answers.length !== questions.length) {
            return res.status(400).json({
                message: 'Please answer all questions',
                expectedQuestionCount: questions.length,
                receivedAnswerCount: answers?.length || 0
            });
        }

        // Check answers and track results for detailed feedback
        let correctAnswers = 0;
        const answerResults = [];

        for (let i = 0; i < questions.length; i++) {
            const isCorrect = answers[i] === questions[i].bonneReponse;
            if (isCorrect) {
                correctAnswers++;
            }

            answerResults.push({
                questionId: questions[i]._id,
                questionText: questions[i].question,
                userAnswer: answers[i],
                correctAnswer: questions[i].bonneReponse,
                isCorrect: isCorrect,
                explanation: questions[i].explication || ''
            });
        }

        const allCorrect = correctAnswers === questions.length;
        console.log(`User got ${correctAnswers}/${questions.length} correct. All correct: ${allCorrect}`);

        // Update student progress when all answers are correct
        if (allCorrect) {
            // Check if this level is already completed
            const levelAlreadyCompleted = student.niveauxCompletes.includes(niveau);

            if (!levelAlreadyCompleted) {
                console.log(`Marking level ${niveau} as completed for student ${student._id}`);

                // Add to completed levels
                student.niveauxCompletes.push(niveau);

                // Update accessible levels in Boolean array
                if (!student.accessibleLevels) {
                    student.accessibleLevels = Array(14).fill(false);
                    student.accessibleLevels[0] = true; // Level 0 is always accessible
                }

                if (!student.completedLevels) {
                    student.completedLevels = Array(14).fill(false);
                }

                // Mark current level as completed
                if (niveau < student.completedLevels.length) {
                    student.completedLevels[niveau] = true;
                }

                // Make next level accessible
                if (niveau + 1 < student.accessibleLevels.length) {
                    student.accessibleLevels[niveau + 1] = true;
                }

                // Increment student's level if this is the highest level completed
                student.niveau = Math.max(student.niveau, niveau + 1);

                await student.save();
                console.log(`Student progress updated. New level: ${student.niveau}`);
            } else {
                console.log(`Level ${niveau} was already completed by student ${student._id}`);
            }
        }

        // Return detailed results
        res.json({
            correctAnswers,
            totalQuestions: questions.length,
            score: Math.round((correctAnswers / questions.length) * 100),
            passing_score: 100, // Require 100% to pass
            passed: allCorrect,
            levelCompleted: allCorrect,
            nextLevel: allCorrect ? niveau + 1 : niveau,
            answerResults: answerResults
        });
    } catch (error) {
        console.error('Error processing answers:', error);
        res.status(500).json({ message: error.message });
    }
});

// Get available levels for student
router.get('/niveaux-disponibles', auth, async (req, res) => {
    try {
        const student = await Eleve.findById(req.userId);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        const levels = [];
        for (let i = 1; i <= 14; i++) {
            levels.push({
                niveau: i,
                accessible: i <= student.niveau,
                completed: student.niveauxCompletes.includes(i)
            });
        }

        res.json(levels);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
