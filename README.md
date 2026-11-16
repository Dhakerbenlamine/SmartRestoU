# SmartRestoU

SmartRestoU est une application Flutter de restauration universitaire. Elle
permettra aux étudiants de consulter les menus, réserver un repas et suivre
leurs réservations. Un espace d'administration est prévu pour la gestion des
menus et des statistiques.

## Démarrer l'application

```bash
flutter pub get
flutter run
```

Le jalon 1 pose la structure Flutter, le thème commun, la navigation principale
et un premier catalogue de menus de démonstration. L'écran de réservation
permet de choisir une date, une heure et jusqu'à 10 convives. Les données et la
confirmation restent en mode démonstration : aucun ticket QR ni e-mail n'est
réellement envoyé.
Le tableau de bord étudiant reprend les sections notifications et réservations
du prototype, sans nom ni données personnelles. Il affiche des états vides
jusqu'à l'intégration de l'authentification et du backend.
L'écran historique suit le même principe : les réservations passées et repas
consommés affichent un état vide jusqu'à ce que ces données soient disponibles.
Après confirmation, une réservation est partagée entre le tableau de bord et
l'historique pendant la session courante. Elle est conservée en mémoire locale
uniquement et disparaît au redémarrage de l'application ; aucun backend ni
service de notification n'est encore connecté.

## Vérification

```bash
flutter analyze
flutter test
```

## Suite du projet

Les étapes suivantes couvriront le parcours de réservation, l'espace étudiant,
l'historique et les avis, puis les écrans d'administration et les statistiques.
Les intégrations d'authentification et de backend restent à définir.
