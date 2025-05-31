const mongoose = require('mongoose');
const Eleve = require('../models/eleve.model');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/educatif', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB:', err));

async function addStudent() {
    try {
        const student = new Eleve({
            email: 'aziz@example.com',
            password: 'password123',
            nom: 'Aziz',
            prenom: 'Student',
            age: 15,
            niveau: 1
        });

        await student.save();
        console.log('Student added successfully:', student);
    } catch (error) {
        console.error('Error adding student:', error);
    } finally {
        mongoose.connection.close();
    }
}

addStudent(); 