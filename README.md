# AIR FLEET
Contributors: **Armand DE FARIA LEITE**, **Noé PIGEAU**, **Théo HERVE**, **Alexandre HARDY**

## LIST OF FEATURES
- Login / Register / Register Pilot / Layouting 

  **Noé PIGEAU**

- Mailing pour valider compte et envoyer  information

  **Noé PIGEAU**

- Setup Swagger

  **Noé PIGEAU**

- Création de vol (style Uber) (front / back)

  **Armand DE FARIA LEITE

- Création des véhicules (front / back)

  **Alexandre HARDY**

- affichage de la carte MapBox (position de l'utilisateur, tracking, etc..) (front)

  **Armand DE FARIA LEITE**

- Process Client permetant de suivre l'avancement de son vol (front / back)

  **Armand DE FARIA LEITE**

- Process Pilot permetant de suivre l'avancement de son vol (front)

  **Noé PIGEAU**

- Process Pilot permetant de suivre l'avancement de son vol (back)

  **Noé PIGEAU**, **Armand DE FARIA LEITE**

- En tant que pilot, je peux sélectionner un véhicule pour être prêt et faire une recherche de vol et faire une proposition au client

  **Noé PIGEAU**

- Paiement

  **Noé PIGEAU**

- Notifications

  **Armand DE FARIA LEITE**

- Chat

  **Armand DE FARIA LEITE**

- Note des pilotes

  **Armand DE FARIA LEITE**

- Création des proposition de vol (style BlablaCar) (front / back)

  **Alexandre HARDY**

- Page profil

  **Théo HERVE**

- Upload de photo de profil (front)

  **Théo HERVE**, **Noé PIGEAU**


- Upload de photo de profil (Back)

  **Théo HERVE**, **Noé PIGEAU**, **Alexandre HARDY**

- Page principal admin avec KPIs

  **Théo HERVE**

- Page de gestion des utilisateurs avec CRUD (admin)

  **Théo HERVE**

- Page de gestion des vols avec CRUD (admin)

  **Théo HERVE**

- Page de gestion des véhicules avec CRUD (admin)

  **Théo HERVE**

- Page monitoring logs (admin)

  **Noé PIGEAU**

- Page module features fliping (admin)

  **Armand DE FARIA LEITE**, **Théo HERVE**

- Mise en production

  **Alexandre HARDY**

- GitHub action pour déployer release apk

  **Noé PIGEAU**

### FLUTTER

last release here: https://github.com/AlexandreHardyy/AirFleet/releases/tag/v1.0.16

see all environment variables to add in ./frontend/.env.example


### BACKEND GOLANG

install dependencies
```
go mod tidy
```

run test
```
go test -v ./tests/...
```

update swagger here: http://localhost:3001/swagger/index.html
```
swag init
```

to start in local 

start postgres
```
docker compose up -d
```

see all environment variables to add in ./backend/.env.example

start application
```
go run application.go
```