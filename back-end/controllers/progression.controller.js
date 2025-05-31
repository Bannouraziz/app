const Reponse = require('../models/reponse.model');

exports.getProgression = async (req, res) => {
  try {
    const { eleveId } = req.params;

    const reponses = await Reponse.find({ eleveId });

    if (reponses.length === 0) {
      return res.status(200).json({
        message: "Aucune réponse trouvée",
        total: 0,
        bonnes: 0,
        pourcentage: 0
      });
    }

    const bonnes = reponses.filter(r => r.estCorrecte).length;
    const total = reponses.length;
    const pourcentage = Math.round((bonnes / total) * 100);

    res.status(200).json({
      total,
      bonnes,
      pourcentage,
      message: `Progression : ${bonnes}/${total} (${pourcentage}%)`
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
