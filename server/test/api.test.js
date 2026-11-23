const assert = require('node:assert/strict');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const request = require('supertest');
const { test } = require('node:test');
const { createApp } = require('../src/app');

const jwtSecret = 'test-secret-with-more-than-thirty-two-characters';

function makePool(users = [], menus = []) {
  return {
    users,
    menus,
    async query(sql, values = []) {
      if (sql.includes('LOWER(email) = LOWER($1)')) {
        const user = this.users.find((item) => item.email === values[0].toLowerCase());
        return { rows: user ? [{ ...user }] : [], rowCount: user ? 1 : 0 };
      }
      if (sql.includes('INSERT INTO app_users')) {
        if (this.users.some((item) => item.email === values[1])) {
          return { rows: [], rowCount: 0 };
        }
        const user = {
          id: 'student-1',
          nom: values[0],
          email: values[1],
          password_hash: values[2],
          role: 'etudiant',
        };
        this.users.push(user);
        return { rows: [{ id: user.id }], rowCount: 1 };
      }
      if (sql.includes('FROM app_users WHERE id = $1')) {
        const user = this.users.find((item) => item.id === values[0]);
        if (!user) return { rows: [], rowCount: 0 };
        const { id, nom, email, role } = user;
        return { rows: [{ id, nom, email, role }], rowCount: 1 };
      }
      if (sql.includes('SELECT 1')) return { rows: [{ '?column?': 1 }], rowCount: 1 };
      if (sql.includes('FROM menus')) return { rows: this.menus, rowCount: this.menus.length };
      if (sql.includes('INSERT INTO menus')) {
        this.menus.push({
          id: 'menu-1',
          nom: values[0],
          description: values[1],
          regime: values[2],
          type: values[3],
          date: values[4],
          disponible: values[5],
          image: values[6],
        });
        return { rows: [{ id: 'menu-1' }], rowCount: 1 };
      }
      if (sql.includes('DELETE FROM menus')) {
        const found = this.menus.findIndex((menu) => menu.id === values[0]);
        if (found < 0) return { rows: [], rowCount: 0 };
        const [menu] = this.menus.splice(found, 1);
        return { rows: [{ id: menu.id }], rowCount: 1 };
      }
      throw new Error(`Unexpected SQL in test: ${sql}`);
    },
  };
}

async function makeApp(users = [], menus = []) {
  const pool = makePool(users, menus);
  const app = createApp({ pool, jwtSecret });
  return { app, pool };
}

test('signup creates a student with a hashed password and login returns a token', async () => {
  const { app, pool } = await makeApp();
  const signup = await request(app).post('/auth/signup').send({
    nom: 'Étudiant',
    email: 'STUDENT@example.com',
    motDePasse: 'secret123',
  });
  assert.equal(signup.status, 201);
  assert.equal(signup.body.id, 'student-1');
  assert.equal(pool.users[0].role, 'etudiant');
  assert.notEqual(pool.users[0].password_hash, 'secret123');
  assert.equal(await bcrypt.compare('secret123', pool.users[0].password_hash), true);

  const login = await request(app).post('/auth/login').send({
    email: 'student@example.com',
    motDePasse: 'secret123',
  });
  assert.equal(login.status, 200);
  assert.equal(login.body.role, 'etudiant');
  assert.equal(typeof login.body.accessToken, 'string');
});

test('login returns a useful unauthorized response for invalid credentials', async () => {
  const passwordHash = await bcrypt.hash('secret123', 4);
  const { app } = await makeApp([{
    id: 'student-1',
    nom: 'Étudiant',
    email: 'student@example.com',
    role: 'etudiant',
    password_hash: passwordHash,
  }]);
  const response = await request(app).post('/auth/login').send({
    email: 'student@example.com',
    motDePasse: 'wrong-password',
  });
  assert.equal(response.status, 401);
  assert.match(response.body.error, /incorrect/i);
});

test('admin menu writes require a valid admin token', async () => {
  const studentHash = await bcrypt.hash('secret123', 4);
  const adminHash = await bcrypt.hash('secret123', 4);
  const { app, pool } = await makeApp([
    {
      id: 'student-1',
      nom: 'Étudiant',
      email: 'student@example.com',
      role: 'etudiant',
      password_hash: studentHash,
    },
    {
      id: 'admin-1',
      nom: 'Admin',
      email: 'admin@example.com',
      role: 'admin',
      password_hash: adminHash,
    },
  ]);
  const menu = {
    nom: 'Riz aux légumes',
    description: 'Un plat végétal.',
    regime: 'Vegan',
    type: 'Menu du jour',
    date: '2026-11-23',
    disponible: true,
    image: null,
  };
  const studentToken = jwt.sign({ sub: 'student-1' }, jwtSecret, {
    expiresIn: '1h',
    issuer: 'smart-restou-api',
    audience: 'smart-restou-app',
  });
  const rejected = await request(app)
    .post('/menus')
    .set('Authorization', `Bearer ${studentToken}`)
    .send(menu);
  assert.equal(rejected.status, 403);
  assert.equal(pool.menus.length, 0);

  const adminToken = jwt.sign({ sub: 'admin-1' }, jwtSecret, {
    expiresIn: '1h',
    issuer: 'smart-restou-api',
    audience: 'smart-restou-app',
  });
  const created = await request(app)
    .post('/menus')
    .set('Authorization', `Bearer ${adminToken}`)
    .send(menu);
  assert.equal(created.status, 201);
  assert.equal(created.body.id, 'menu-1');
});
