# YConnect

YConnect est une application web pensée pour les étudiants Ynov.  
Elle permet de centraliser la vie de campus dans une interface moderne, mobile-first et collaborative.

L’application propose plusieurs espaces :
- un **fil d’actualité**
- une **messagerie**
- une **recherche** de profils et projets
- un **assistant IA**
- un espace **Ymatch** pour les stages, alternances et jobs
- un **profil étudiant**
- des pages **connexion / inscription**

L’objectif est de créer une plateforme utile à la collaboration, à la visibilité des étudiants et à la recherche d’opportunités.

---

## Résumé du projet

YConnect est une plateforme étudiante qui mélange :
- réseau social campus
- espace projet
- aide IA
- opportunités professionnelles

Le projet met en avant :
- une interface premium
- un design system CSS réutilisable
- une navigation type application mobile
- des interactions JavaScript simples
- une structure prête à être reliée à un backend

---

## Technologies utilisées

### Front-end
- HTML
- CSS
- JavaScript

### Back-end
- Node.js
- Express
- TypeScript

### Base de données
- Prisma
- base SQL selon ta configuration (`PostgreSQL`, `MySQL`, `SQLite`, etc.)

---

## Structure du projet

```bash
YConnect/
│
├── frontend/
│   ├── index.html
│   ├── bot.html
│   ├── search.html
│   ├── messages.html
│   ├── profile.html
│   ├── ymatch.html
│   ├── login.html
│   ├── register.html
│   ├── style.css
│   ├── script.js
│   └── assets/
│
├── backend/
│   ├── src/
│   ├── prisma/
│   │   └── schema.prisma
│   ├── package.json
│   ├── tsconfig.json
│   └── .env
│
└── README.md
````

---

## Comment lancer le projet

## 1. Lancer le front


### Option 1 — ouvrir directement le fichier

Ouvre `index.html` dans ton navigateur.

### Option 2 — utiliser Live Server

Dans VS Code :

* installe l’extension **Live Server**
* clic droit sur `index.html`
* clique sur **Open with Live Server**

---

## 2. Lancer le back

Dans le dossier backend :

```bash
cd backend
npm install
npm run dev
```

Dans ton cas, si ton projet s’appelle `ynov-backend`, ça peut être :

```bash
cd ynov-backend
npm install
npm run dev
```

Si tout est bien configuré, le serveur démarre sur le port défini dans ton projet, par exemple :

```bash
Server running on port 5000
```

---

## 3. Configuration `.env`

Vérifie que ton fichier `.env` existe dans le backend.

Exemple classique :

```env
PORT=5000
DATABASE_URL="file:./dev.db"
JWT_SECRET="ton_secret"
GEMINI_API_KEY="ta_cle_api"
```

Selon ton projet, `DATABASE_URL` peut pointer vers :

* SQLite
* PostgreSQL
* MySQL

---

## Prisma

Prisma sert à gérer la base de données et les modèles.

Le fichier principal est :

```bash
prisma/schema.prisma
```

---

## Commandes Prisma utiles

### Générer le client Prisma

```bash
npx prisma generate
```

### Appliquer les migrations en développement

```bash
npx prisma migrate dev
```

### Réinitialiser la base

```bash
npx prisma migrate reset
```

### Ouvrir Prisma Studio

```bash
npx prisma studio
```

### Pousser le schéma sans migration

```bash
npx prisma db push
```

---

## Ordre conseillé pour lancer Prisma

Quand tu récupères le projet pour la première fois :

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run dev
```

Si tu veux juste synchroniser rapidement la base sans créer de migration :

```bash
npx prisma db push
```

---

## Exemple complet de démarrage

### Front

```bash
cd frontend
```

Puis ouvrir `index.html` avec Live Server.

### Back

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run dev
```

---

## Si Prisma ne marche pas

Vérifie :

* que `DATABASE_URL` est bien renseigné dans `.env`
* que `schema.prisma` existe
* que Prisma est installé dans les dépendances

Installation classique :

```bash
npm install prisma @prisma/client
```

Puis :

```bash
npx prisma generate
```

---

## Fonctionnalités principales

* publication de contenu
* navigation entre plusieurs pages
* assistant IA
* messagerie
* moteur de recherche
* profil étudiant
* opportunités Ymatch
* authentification

---

## Améliorations futures

* authentification réelle
* données persistantes
* messagerie temps réel
* recherche reliée à la base
* intégration IA réelle
* notifications
* mode clair / sombre
* dashboard étudiant

---




lien git: https://github.com/Amine06-ch/YConnect.git

* collaboration
* réseau
* innovation
* opportunités
* accompagnement IA
