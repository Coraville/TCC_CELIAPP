require('dotenv').config(); // Carrega as variáveis de ambiente do .env

const express = require('express');
const { pool } = require('./database/database');
const cors = require('cors');

const usuariosRoutes = require('./routes/usuarios.routes');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cors());

app.use('/api/usuarios', usuariosRoutes);

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
