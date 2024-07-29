const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/mydatabase', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB');
});

// Define a schema
const userSchema = new mongoose.Schema({
  firstName: String,
  secondName: String,
  email: String,
});

// Define a model
const User = mongoose.model('User', userSchema);

// Create a transporter for nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'madhushreeshetty2003@gmail.com', // Replace with your email
    pass: ''   // Replace with your email password
  }
});

// API endpoint to save user details
app.post('/api/save-details', (req, res) => {
  const { firstName, secondName, email } = req.body;

  const newUser = new User({
    firstName,
    secondName,
    email,
  });

  newUser.save((err) => {
    if (err) {
      return res.status(500).send('Error saving user details');
    }

    // Email options
    const mailOptions = {
      from: 'your-email@gmail.com', // Replace with your email
      to: email,
      subject: 'Welcome!',
      text: `Hello ${firstName},\n\nThank you for registering. Your details have been saved successfully.\n\nBest regards,\nYour Team`
    };

    // Send email
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).send('Error sending email');
      }
      res.status(200).send('User details saved and email sent successfully');
    });
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
