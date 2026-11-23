# SmartRestoU

SmartRestoU est une application Flutter de restauration universitaire. Elle
permettra aux étudiants de consulter les menus, réserver un repas et suivre
leurs réservations. Un espace d'administration est prévu pour la gestion des
menus et des statistiques.

## API locale (Neon + Flutter)

The Flutter app needs the Node API in `server/`; a Neon `/rest/v1` URL is a
database REST endpoint and does not implement the app's `/auth/login` routes.
The Node server connects to Neon directly and keeps its database URL on the
server, not in the Flutter bundle.

1. Rotate the Neon database password if it has been shared, then put the new
   connection URL in `server/.env` as `DATABASE_URL`. Start from
   `server/.env.example` and set `JWT_SECRET` to a random secret of at least 32
   characters. `.env` is ignored by git.
2. From a terminal in `server/`, run:

   ```powershell
   npm install
   Copy-Item .env.example .env
   # Edit .env and set DATABASE_URL and JWT_SECRET before continuing.
   npm run db:migrate
   npm run dev
   ```

3. In another terminal at the project root, run:

   ```powershell
   flutter pub get
   flutter run -d chrome
   ```

   Flutter uses `http://localhost:3000` by default. Check
   `http://localhost:3000/health` to verify the API and database connection.
   For Android emulator, pass
   `--dart-define=API_BASE_URL=http://10.0.2.2:3000`; for a physical device use
   the computer's LAN IP and allow the origin in `CORS_ORIGINS`.

The API provides signup, login, session restore, menu listing and admin-only
menu creation/deletion. New accounts are students. To promote an account,
update its role in Neon SQL Editor:

```sql
UPDATE app_users SET role = 'admin' WHERE email = 'admin@example.com';
```

Admin operations require a signed bearer token and the API checks the user's
current database role. Keep `DATABASE_URL` and `JWT_SECRET` only in server
environment variables; never pass them to Flutter with `--dart-define`.

# Les Captures d'ecrans 

<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 24 PM (1)" src="https://github.com/user-attachments/assets/c9ab0d3f-6b87-49af-a958-37fb5842bbc4" />


<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 24 PM (2)" src="https://github.com/user-attachments/assets/79be7207-aba3-4cec-b300-4cc3a47800e5" />


<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 24 PM (3)" src="https://github.com/user-attachments/assets/cb339759-2792-4cc8-bd96-0064a5628101" />


<img width="720" height="1640" alt="WhatsApp Image 2026-11-16 at 9 18 23 PM (4)" src="https://github.com/user-attachments/assets/ec6b98d4-fa3a-4898-86e3-7203720eeba0" />


<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 23 PM (5)" src="https://github.com/user-attachments/assets/0a96ddf4-ed5f-464f-acd4-0e321d02fd9e" />


<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 23 PM (6)" src="https://github.com/user-attachments/assets/608e76bd-14f9-43a1-ac86-48275903251e" />


<img width="702" height="1600" alt="WhatsApp Image 2026-11-16 at 9 18 24 PM" src="https://github.com/user-attachments/assets/b1c64e81-ee7e-4791-987a-59c8faf10072" />

# Le schéma de navigation 
  Menus → Filtrer par régime ou type → Liste des menus
  Menus → Détails d’un menu → Réserver une table
  Menus → Réserver → Formulaire de réservation
  Formulaire de réservation → Annuler → Menus
  Formulaire de réservation → Choisir date, heure et convives → Récapitulatif → Confirmer → Tableau de bord
  Tableau de bord → Réserver une table → Formulaire de réservation
  Tableau de bord → Voir tout → Historique
  Historique → Retour au tableau de bord → Tableau de bord

# Repartion du travail 

Mohamed Rayen cherni : Preparer Structure du projet ; filtres et détails des menus ; ajout de six menus de démonstration.

Dhaker ben Lamine : Écran de réservation ; tableau de bord ; écran d’historique et synchronisation avec les autres écrans.


# Journal IA 

Dhaker ben lamine : https://claude.ai/share/98009013-8343-4ed5-b38c-d5bfd608265a

Mohamed Rayen Cherni : https://chatgpt.com/share/6afb81aa-3bac-83ea-a320-e1af30979d49
