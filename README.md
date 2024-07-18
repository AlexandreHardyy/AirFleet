# AIR FLEET
Contributors: Armand DE FARIA LEITE, Noé PIGEAU, Théo HERVE, Alexandre HARDY

## LIST OF FEATURES
- Login / Register / Register Pilot
  Noé PIGEAU

- Création de vol (style Uber) (front / back)
  Armand DE FARIA LEITE

- Création des véhicules (front / back)
  Alexandre HARDY

- affichage de la carte MapBox (position de l'utilisateur, tracking, etc..) (front)
  Armand DE FARIA LEITE

- Process Client permetant de suivre l'avancement de son vol (front / back)
  Armand DE FARIA LEITE

- Process Pilot permetant de suivre l'avancement de son vol (front)
  Noé PIGEAU

- Process Pilot permetant de suivre l'avancement de son vol (back)
  Noé PIGEAU, Armad DE FARIA LEITE

- Payement
  Noé PIGEAU

- Notifications
  Armad DE FARIA LEITE

- Chat
  Armad DE FARIA LEITE

- Note des pilotes
  Armad DE FARIA LEITE

- Création des proposition de vol (style BlablaCar) (front / back)
  Alexandre HARDY

- Page profil
  Théo HERVE

- Upload de photo de profil (front)
  Théo HERVE

- Upload de photo de profil (Back)
  Théo HERVE, Noé PIGEAU, Alexandre HARDY

- Page principal admin avec KPIs
  Théo HERVE

- Page de gestion des utilisateurs avec CRUD (admin)
  Théo HERVE

- Page de gestion des vols avec CRUD (admin)
  Théo HERVE

- Page de gestion des véhicules avec CRUD (admin)
  Théo HERVE

- Page monitoring logs (admin)
  Noé PIGEAU

- Page module features fliping (admin)
  Armand DE FARIA LEITE, Théo HERVE

- Mise en production
  Alexandre HARDY


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