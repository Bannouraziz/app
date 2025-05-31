const Question = require('../models/question.model');

// Get questions by age range and level
exports.getQuestionsParAgeEtNiveau = async (req, res) => {
  try {
    const { age, niveau } = req.params;
    const userAge = Number(age);
    console.log(`Searching questions for age=${userAge}, niveau=${niveau}`);

    // Start with a simple query that matches the level
    let query = { niveau: niveau.toString() };

    // If age is valid, add it to the query
    if (!isNaN(userAge) && userAge > 0) {
      // Use exact age match first
      query.age = userAge;
    }

    // Find questions that match both the age and niveau
    let questions = await Question.find(query);

    // If no questions found with exact age, try age ranges
    if (questions.length === 0 && !isNaN(userAge)) {
      console.log(`No exact age match found. Trying age ranges for age=${userAge}`);

      let ageQuery;
      if (userAge >= 5 && userAge <= 7) {
        query = { niveau: niveau.toString(), age: { $gte: 5, $lte: 7 } };
      } else if (userAge >= 8 && userAge <= 10) {
        query = { niveau: niveau.toString(), age: { $gte: 8, $lte: 10 } };
      } else if (userAge >= 11 && userAge <= 13) {
        query = { niveau: niveau.toString(), age: { $gte: 11, $lte: 13 } };
      } else if (userAge >= 14 && userAge <= 18) {
        query = { niveau: niveau.toString(), age: { $gte: 14, $lte: 18 } };
      }

      questions = await Question.find(query);
    }

    // If still no questions, try with just the level
    if (questions.length === 0) {
      console.log(`No age-specific questions found. Trying niveau=${niveau} only`);
      questions = await Question.find({ niveau: niveau.toString() });
    }

    // If still no questions, return fallback questions
    if (questions.length === 0) {
      console.log(`No questions found for niveau=${niveau}. Returning fallback questions`);
      const fallbackQuestions = generateFallbackQuestions(niveau, userAge);
      return res.status(200).json(fallbackQuestions);
    }

    console.log(`Found ${questions.length} questions for age=${age}, niveau=${niveau}`);
    res.status(200).json(questions);
  } catch (error) {
    console.error('Error getting questions:', error);
    res.status(500).json({ message: error.message });
  }
};

// Generate fallback questions when none are found in the database
function generateFallbackQuestions(niveau, age) {
  return [
    {
      _id: `fallback_${niveau}_1`,
      age: age,
      niveau: niveau.toString(),
      question: `Question 1 du niveau ${niveau} (générée automatiquement)`,
      choix: ['Option A', 'Option B', 'Option C', 'Option D'],
      bonneReponse: 'Option A',
      explication: 'Cette question a été générée automatiquement car aucune question n\'a été trouvée en base de données.'
    },
    {
      _id: `fallback_${niveau}_2`,
      age: age,
      niveau: niveau.toString(),
      question: `Question 2 du niveau ${niveau} (générée automatiquement)`,
      choix: ['Option A', 'Option B', 'Option C', 'Option D'],
      bonneReponse: 'Option A',
      explication: 'Cette question a été générée automatiquement car aucune question n\'a été trouvée en base de données.'
    },
    {
      _id: `fallback_${niveau}_3`,
      age: age,
      niveau: niveau.toString(),
      question: `Question 3 du niveau ${niveau} (générée automatiquement)`,
      choix: ['Option A', 'Option B', 'Option C', 'Option D'],
      bonneReponse: 'Option A',
      explication: 'Cette question a été générée automatiquement car aucune question n\'a été trouvée en base de données.'
    }
  ];
}

// Get questions by level only
exports.getQuestionsParNiveau = async (req, res) => {
  try {
    const { niveau } = req.params;
    const questions = await Question.find({ niveau: niveau.toString() });

    if (questions.length === 0) {
      const fallbackQuestions = generateFallbackQuestions(niveau, 10);
      return res.status(200).json(fallbackQuestions);
    }

    res.status(200).json(questions);
  } catch (error) {
    console.error('Error getting questions by level:', error);
    res.status(500).json({ message: error.message });
  }
};

// Add a new question
exports.ajouterQuestion = async (req, res) => {
  try {
    const { age, niveau, question, choix, bonneReponse, explication } = req.body;
    const nouvelleQuestion = new Question({
      age,
      niveau: niveau.toString(),
      question,
      choix,
      bonneReponse,
      explication
    });
    await nouvelleQuestion.save();
    res.status(201).json({ message: 'Question ajoutée avec succès', question: nouvelleQuestion });
  } catch (error) {
    console.error('Error adding question:', error);
    res.status(500).json({ message: error.message });
  }
};

// Get all questions
exports.getToutesLesQuestions = async (req, res) => {
  try {
    const questions = await Question.find();
    res.status(200).json(questions);
  } catch (error) {
    console.error('Error getting all questions:', error);
    res.status(500).json({ message: error.message });
  }
};

// Get question by ID
exports.getQuestionParId = async (req, res) => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) {
      return res.status(404).json({ message: 'Question non trouvée' });
    }
    res.status(200).json(question);
  } catch (error) {
    console.error('Error getting question by ID:', error);
    res.status(500).json({ message: error.message });
  }
};

// Update question
exports.modifierQuestion = async (req, res) => {
  try {
    const { age, niveau, question, choix, bonneReponse, explication } = req.body;
    const questionModifiee = await Question.findByIdAndUpdate(
      req.params.id,
      {
        age,
        niveau: niveau.toString(),
        question,
        choix,
        bonneReponse,
        explication
      },
      { new: true }
    );
    if (!questionModifiee) {
      return res.status(404).json({ message: 'Question non trouvée' });
    }
    res.status(200).json({ message: 'Question mise à jour avec succès', question: questionModifiee });
  } catch (error) {
    console.error('Error updating question:', error);
    res.status(500).json({ message: error.message });
  }
};

// Delete question
exports.supprimerQuestion = async (req, res) => {
  try {
    const deleted = await Question.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Question non trouvée' });
    }
    res.status(200).json({ message: 'Question supprimée avec succès' });
  } catch (error) {
    console.error('Error deleting question:', error);
    res.status(500).json({ message: error.message });
  }
};
