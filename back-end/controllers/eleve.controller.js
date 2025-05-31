const Eleve = require('../models/eleve.model');

exports.creerEleve = async (req, res) => {
  try {
    const nouvelEleve = new Eleve(req.body);
    const eleveEnregistre = await nouvelEleve.save();
    res.status(201).json(eleveEnregistre);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getEleves = async (req, res) => {
  try {
    const eleves = await Eleve.find();
    res.status(200).json(eleves);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
exports.supprimerEleve = async (req, res) => {
  try {
    const { id } = req.params;
    const eleve = await Eleve.findByIdAndDelete(id);
    if (!eleve) {
      return res.status(404).json({ message: "Élève non trouvé" });
    }
    res.status(200).json({ message: "Élève supprimé avec succès" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

