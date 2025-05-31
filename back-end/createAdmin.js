const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Admin = require('./models/admin.model');

// Connecte-toi à ta base MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/backend-educatif', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

async function create() {
  const hashed = await bcrypt.hash('admin123', 10); // mot de passe = admin123
  await Admin.create({ email: 'admin@example.com', motDePasse: hashed }); //adresse=admin@example.com
  console.log("✅ Admin créé avec succès !");
  process.exit();
}

create();
