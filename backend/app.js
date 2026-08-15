const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const apiRoutes = require('./routes/apiRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('API is running...');
});

app.use('/api', authRoutes); // /api/login, /api/register
app.use('/api', apiRoutes); // Protected endpoints

module.exports = app;
