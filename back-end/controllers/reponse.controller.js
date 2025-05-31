const Reponse = require('../models/reponse.model');
const Question = require('../models/question.model');

exports.soumettreReponse = async (req, res) => {
  try {
    const { eleveId, questionId, reponseDonnee } = req.body;

    // Récupérer la question
    const question = await Question.findById(questionId);
    if (!question) {
      return res.status(404).json({ message: 'Question non trouvée' });
    }

    // Vérifier la réponse
    const estCorrecte = question.bonneReponse === reponseDonnee;

    // Enregistrer la réponse
    const nouvelleReponse = new Reponse({
      eleveId,
      questionId,
      reponseDonnee,
      estCorrecte
    });

    await nouvelleReponse.save();

    res.status(201).json({
      message: estCorrecte ? 'Bonne réponse !' : 'Mauvaise réponse.',
      reponse: nouvelleReponse
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
