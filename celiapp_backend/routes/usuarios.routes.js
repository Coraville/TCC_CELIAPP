const express = require('express');
const router = express.Router();
const { pool } = require('../database/database');
const { body, validationResult, param } = require('express-validator');


// Busca todos os usuários na tabela Usuarios
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Usuarios');
        res.json(result.rows);
    } catch (err) {
        console.error('Erro ao buscar usuários', err);
        res.status(500).json({ error: 'Erro ao buscar usuários.' });
    }
});

// Busca um usuário específico pelo ID
// Verifica se o ID é um número válido antes de fazer a consulta
router.get(
    '/:id',
    [
        param('id').isInt({ min: 1 }).withMessage('O ID do usuário deve ser um inteiro positivo.'),
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const id = parseInt(req.params.id);
        try {
            const result = await pool.query('SELECT * FROM Usuarios WHERE id_usuario = $1', [id]);
            if (result.rows.length > 0) {
                res.json(result.rows[0]);
            } else {
                res.status(404).json({ message: 'Usuário não encontrado.' });
            }
        } catch (err) {
            console.error('Erro ao buscar usuário por ID', err);
            res.status(500).json({ error: 'Erro ao buscar usuário.' });
        }
    }
);

// Adiciona um novo usuário à tabela Usuarios
router.post(
    '/',
    [
        body('nm_nome').notEmpty().withMessage('O nome é obrigatório.').trim(),
        body('ds_email').isEmail().withMessage('O email deve ser válido.').normalizeEmail(),
        body('ds_senha').isLength({ min: 6 }).withMessage('A senha deve ter pelo menos 6 caracteres.'),
        body('dt_nascimento').isISO8601().withMessage('A data de nascimento deve ser válida (ISO 8601).'),
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const { nm_nome, ds_email, ds_senha, dt_nascimento } = req.body;
        try {
            const result = await pool.query(
                'INSERT INTO Usuarios (nm_nome, ds_email, ds_senha, dt_nascimento) VALUES ($1, $2, $3, $4) RETURNING *',
                [nm_nome, ds_email, ds_senha, dt_nascimento]
            );
            res.status(201).json(result.rows[0]);
        } catch (err) {
            console.error('Erro ao criar usuário', err);
            res.status(500).json({ error: 'Erro ao criar usuário.' });
        }
    }
);

// Atualiza um usuário existente
router.put(
    '/:id',
    [
        param('id').isInt({ min: 1 }).withMessage('O ID do usuário deve ser um inteiro positivo.'),
        body('nm_nome').optional().notEmpty().withMessage('O nome não pode ser vazio.').trim(),
        body('ds_email').optional().isEmail().withMessage('O email deve ser válido.').normalizeEmail(),
        body('ds_senha').optional().isLength({ min: 6 }).withMessage('A senha deve ter pelo menos 6 caracteres.'),
        body('dt_nascimento').optional().isISO8601().withMessage('A data de nascimento deve ser válida (ISO 8601).'),
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const id = parseInt(req.params.id);
        const { nm_nome, ds_email, ds_senha, dt_nascimento } = req.body;
        try {
            const result = await pool.query(
                'UPDATE Usuarios SET nm_nome = $1, ds_email = $2, ds_senha = $3, dt_nascimento = $4 WHERE id_usuario = $5 RETURNING *',
                [nm_nome, ds_email, ds_senha, dt_nascimento, id]
            );
            if (result.rows.length > 0) {
                res.json(result.rows[0]);
            } else {
                res.status(404).json({ message: 'Usuário não encontrado.' });
            }
        } catch (err) {
            console.error('Erro ao atualizar usuário', err);
            res.status(500).json({ error: 'Erro ao atualizar usuário.' });
        }
    });

// Excluir usuário
router.delete(
    '/:id',
    [
        param('id').isInt({ min: 1 }).withMessage('O ID do usuário deve ser um inteiro positivo.'),
    ],
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        const id = parseInt(req.params.id);
        try {
            const result = await pool.query('DELETE FROM Usuarios WHERE id_usuario = $1 RETURNING *', [id]);
            if (result.rows.length > 0) {
                res.status(204).send(); // 204 No Content (exclusão bem-sucedida)
            } else {
                res.status(404).json({ message: 'Usuário não encontrado.' });
            }
        } catch (err) {
            console.error('Erro ao excluir usuário', err);
            res.status(500).json({ error: 'Erro ao excluir usuário.' });
        }
    }
);


module.exports = router;