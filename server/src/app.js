const bcrypt = require('bcryptjs');
const cors = require('cors');
const express = require('express');
const jwt = require('jsonwebtoken');

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const diets = new Set(['Standard', 'Vegan', 'Sans gluten']);
const menuTypes = new Set(['Menu du jour', 'Menu semaine']);
const publicUserFields = 'id, nom, email, role';

function isValidDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(date.valueOf()) && date.toISOString().slice(0, 10) === value;
}

function createApp({ pool, jwtSecret, corsOrigins = [] }) {
  if (!pool || typeof pool.query !== 'function') {
    throw new TypeError('A PostgreSQL pool is required.');
  }
  if (typeof jwtSecret !== 'string' || jwtSecret.length < 32) {
    throw new TypeError('JWT_SECRET must contain at least 32 characters.');
  }

  const app = express();
  const allowedOrigins = new Set(corsOrigins);
  app.disable('x-powered-by');
  app.use(cors({
    origin(origin, callback) {
      const localOrigin = origin && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
      callback(null, !origin || localOrigin || allowedOrigins.has(origin));
    },
  }));
  app.use(express.json({ limit: '16kb' }));

  app.get('/health', async (_request, response, next) => {
    try {
      await pool.query('SELECT 1');
      response.json({ status: 'ok' });
    } catch (error) {
      next(error);
    }
  });

  app.post('/auth/signup', async (request, response, next) => {
    try {
      const { nom, email, motDePasse } = request.body ?? {};
      if (
        typeof nom !== 'string' || nom.trim().length < 2 || nom.trim().length > 120 ||
        typeof email !== 'string' || !emailPattern.test(email) || email.length > 254 ||
        typeof motDePasse !== 'string' || motDePasse.length < 8 || motDePasse.length > 128
      ) {
        return response.status(400).json({
          error: 'Nom, adresse e-mail ou mot de passe invalide. Le mot de passe doit contenir au moins 8 caractères.',
        });
      }

      const normalizedEmail = email.trim().toLowerCase();
      const passwordHash = await bcrypt.hash(motDePasse, 12);
      const result = await pool.query(
        `INSERT INTO app_users (nom, email, password_hash, role)
         VALUES ($1, $2, $3, 'etudiant')
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [nom.trim(), normalizedEmail, passwordHash],
      );
      if (result.rowCount === 0) {
        return response.status(409).json({ error: 'Cette adresse e-mail est déjà utilisée.' });
      }
      return response.status(201).json({ id: result.rows[0].id });
    } catch (error) {
      return next(error);
    }
  });

  app.post('/auth/login', async (request, response, next) => {
    try {
      const { email, motDePasse } = request.body ?? {};
      if (typeof email !== 'string' || typeof motDePasse !== 'string') {
        return response.status(400).json({ error: 'Adresse e-mail et mot de passe requis.' });
      }
      const result = await pool.query(
        `SELECT ${publicUserFields}, password_hash
         FROM app_users
         WHERE LOWER(email) = LOWER($1)
         LIMIT 1`,
        [email.trim()],
      );
      const user = result.rows[0];
      if (!user || !(await bcrypt.compare(motDePasse, user.password_hash))) {
        return response.status(401).json({ error: 'Adresse e-mail ou mot de passe incorrect.' });
      }
      const accessToken = jwt.sign(
        { sub: user.id },
        jwtSecret,
        { expiresIn: '1h', issuer: 'smart-restou-api', audience: 'smart-restou-app' },
      );
      return response.status(200).json({
        id: user.id,
        nom: user.nom,
        email: user.email,
        role: user.role,
        accessToken,
      });
    } catch (error) {
      return next(error);
    }
  });

  async function requireUser(request, response, next) {
    const authorization = request.get('authorization') ?? '';
    const match = authorization.match(/^Bearer\s+(.+)$/i);
    if (!match) {
      return response.status(401).json({ error: 'Authentification requise.' });
    }
    try {
      const payload = jwt.verify(match[1], jwtSecret, {
        issuer: 'smart-restou-api',
        audience: 'smart-restou-app',
      });
      if (!payload || typeof payload === 'string' || typeof payload.sub !== 'string') {
        return response.status(401).json({ error: 'Session invalide ou expirée.' });
      }
      const result = await pool.query(
        `SELECT ${publicUserFields} FROM app_users WHERE id = $1`,
        [payload.sub],
      );
      if (result.rowCount === 0) {
        return response.status(401).json({ error: 'Session invalide ou expirée.' });
      }
      request.user = result.rows[0];
      return next();
    } catch (error) {
      if (error instanceof jwt.JsonWebTokenError || error instanceof jwt.TokenExpiredError) {
        return response.status(401).json({ error: 'Session invalide ou expirée.' });
      }
      return next(error);
    }
  }

  function requireAdmin(request, response, next) {
    if (request.user.role !== 'admin') {
      return response.status(403).json({ error: 'Accès réservé aux administrateurs.' });
    }
    return next();
  }

  app.get('/utilisateurs/:id', requireUser, (request, response) => {
    if (request.user.id !== request.params.id) {
      return response.status(403).json({ error: 'Accès refusé.' });
    }
    return response.json(request.user);
  });

  app.get('/menus', async (request, response, next) => {
    try {
      const filters = [];
      const values = [];
      if (request.query.regime !== undefined) {
        if (!diets.has(request.query.regime)) {
          return response.status(400).json({ error: 'Régime invalide.' });
        }
        values.push(request.query.regime);
        filters.push(`regime = $${values.length}`);
      }
      if (request.query.type !== undefined) {
        if (!menuTypes.has(request.query.type)) {
          return response.status(400).json({ error: 'Type de menu invalide.' });
        }
        values.push(request.query.type);
        filters.push(`type = $${values.length}`);
      }
      const where = filters.length > 0 ? `WHERE ${filters.join(' AND ')}` : '';
      const result = await pool.query(
        `SELECT id, nom, description, regime, type,
                TO_CHAR(date, 'YYYY-MM-DD') AS date, disponible, image
         FROM menus ${where}
         ORDER BY date, nom`,
        values,
      );
      return response.json(result.rows);
    } catch (error) {
      return next(error);
    }
  });

  app.post('/menus', requireUser, requireAdmin, async (request, response, next) => {
    try {
      const { nom, description, regime, type, date, disponible, image } = request.body ?? {};
      if (
        typeof nom !== 'string' || nom.trim().length === 0 || nom.length > 160 ||
        typeof description !== 'string' || description.trim().length === 0 || description.length > 2000 ||
        !diets.has(regime) || !menuTypes.has(type) || !isValidDate(date) ||
        (disponible !== undefined && typeof disponible !== 'boolean') ||
        (image !== undefined && image !== null && (typeof image !== 'string' || image.length > 2048))
      ) {
        return response.status(400).json({ error: 'Les informations du menu sont invalides.' });
      }
      const result = await pool.query(
        `INSERT INTO menus (nom, description, regime, type, date, disponible, image)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING id`,
        [
          nom.trim(),
          description.trim(),
          regime,
          type,
          date,
          disponible ?? true,
          image ?? null,
        ],
      );
      return response.status(201).json({ id: result.rows[0].id });
    } catch (error) {
      return next(error);
    }
  });

  app.delete('/menus/:id', requireUser, requireAdmin, async (request, response, next) => {
    try {
      const result = await pool.query('DELETE FROM menus WHERE id = $1 RETURNING id', [
        request.params.id,
      ]);
      if (result.rowCount === 0) {
        return response.status(404).json({ error: 'Ce menu n’existe plus.' });
      }
      return response.status(200).json({ id: result.rows[0].id });
    } catch (error) {
      return next(error);
    }
  });

  app.use((error, _request, response, _next) => {
    if (error?.type === 'entity.parse.failed') {
      return response.status(400).json({ error: 'Corps JSON invalide.' });
    }
    if (error?.code === '23505') {
      return response.status(409).json({ error: 'Cette adresse e-mail est déjà utilisée.' });
    }
    console.error('Unhandled API error:', error);
    return response.status(500).json({ error: 'Erreur interne du serveur.' });
  });

  return app;
}

module.exports = { createApp };
