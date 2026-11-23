require('dotenv').config();

const { Pool } = require('pg');
const { createApp } = require('./app');

const { DATABASE_URL, JWT_SECRET } = process.env;
if (!DATABASE_URL) {
  throw new Error('DATABASE_URL is required. Copy .env.example to .env and configure it.');
}
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  throw new Error('JWT_SECRET must be set to a random value of at least 32 characters.');
}

const pool = new Pool({ connectionString: DATABASE_URL });
const corsOrigins = (process.env.CORS_ORIGINS ?? '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
const app = createApp({ pool, jwtSecret: JWT_SECRET, corsOrigins });
const port = Number(process.env.PORT ?? 3000);

const server = app.listen(port, () => {
  console.log(`SmartRestoU API listening on http://localhost:${port}`);
});

async function shutdown(signal) {
  console.log(`${signal} received; closing API server.`);
  server.close(async (serverError) => {
    try {
      await pool.end();
    } catch (error) {
      console.error('Failed to close PostgreSQL pool:', error);
      process.exitCode = 1;
    }
    if (serverError) {
      console.error('Failed to close HTTP server:', serverError);
      process.exitCode = 1;
    }
  });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
