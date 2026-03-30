## YConnect
Réseau social “campus” (maquette front + scripts SQL) pour les étudiants Ynov : **posts**, **recherche**, **profil**, **messagerie** et une base de données prête à l’emploi.

---

## Objectif du projet
YConnect vise à proposer une expérience type “social app” centrée sur la vie étudiante :
- **Publier** des posts et interagir (likes/commentaires)
- **Se connecter** avec d’autres étudiants (abonnements / connexions)
- **Découvrir** des étudiants et des projets (recherche)
- **Discuter** via une messagerie (conversations + messages)
- **Structurer** proprement les données côté SQL pour évoluer vers une vraie API plus tard

---

## Fonctionnalités (côté base SQL)
Le dossier `sql/` fournit un schéma MySQL 8 complet pour :
- **Utilisateurs**: `users`, `user_profiles`
- **Connexions**: `follows` (abonnements)
- **Posts**: `posts`, `post_media`, `post_likes`
- **Commentaires**: `comments`, `comment_likes` (avec réponses via `parent_comment_id`)
- **Groupes**: `groups`, `group_memberships`
- **Événements**: `events`, `events_rsvps`
- **Messagerie**: `conversations`, `conversation_members`, `messages`
- **Compat UI** (profil/recherche): `skills`, `user_skills`, `projects`, `project_members` + vues pratiques (`v_inbox`, `v_profile_stats`, etc.)

---

## Aperçu du front (fichiers HTML)
Le front est actuellement une **maquette statique** (HTML/CSS/JS) :
- **Accueil / feed**: `index.html`
- **Recherche**: `search.html`
- **Profil**: `profile.html`
- **Messagerie**: `messages.html`
- **Bot IA (UI)**: `bot.html`

Styles et scripts :
- `style.css`
- `script.js`

---

## Structure du projet
```
YConnect/
  index.html
  profile.html
  messages.html
  search.html
  bot.html
  style.css
  script.js
  sql/
    01_schema.sql
    02_demo.sql
    03_queries.sql
    04_frontend_compat.sql
    README.md
```

---

## Prérequis
### Front (maquette)
- Un navigateur web (Chrome/Edge/Firefox)

### Base de données
- **MySQL 8** (recommandé) ou MariaDB compatible
- Un compte MySQL avec droits `CREATE`, `DROP`, `INSERT`, `SELECT`

---

## Lancer la maquette (front)
Option simple :
- Ouvre `index.html` dans ton navigateur.

Option recommandée (petit serveur local, évite certains problèmes CORS) :
- VS Code / Cursor: extension “Live Server”
- Ou tout serveur statique (ex: `python -m http.server` si Python est installé)

---

## Installer la base (MySQL) avec les scripts fournis
Les scripts sont pensés pour être **copiés-collés/exécutés en ligne de commande**.

Ordre recommandé :
1) Schéma (crée `school_social` et toutes les tables)
2) Données de démo
3) Extensions “compat UI” (skills/projets + vues)
4) Requêtes utiles (vues + exemples)

### Commandes (Windows / PowerShell)
Depuis la racine du projet :
```bash
mysql -u <USER> -p < sql/01_schema.sql
mysql -u <USER> -p < sql/02_demo.sql
mysql -u <USER> -p < sql/04_frontend_compat.sql
mysql -u <USER> -p < sql/03_queries.sql
```

Si `mysql` n’est pas reconnu, c’est que MySQL n’est pas installé ou que son dossier `bin` n’est pas dans le `PATH`.

---

## Vues SQL utiles (pour alimenter une future API)
Quelques vues prêtes pour simplifier l’intégration :
- **`v_inbox`**: boîte de réception (autre utilisateur + dernier message + date)
- **`v_profile_stats`**: stats profil (posts, connexions, projets)
- **`v_search_students`**: recherche étudiants (nom, username, bio, département, avatar)
- **`v_search_projects`**: recherche projets (titre, résumé, statut, créateur)

---

## Données de démonstration
Après import, tu as :
- 3 utilisateurs
- 2 groupes
- quelques posts/commentaires/likes
- 2 événements + RSVP
- 1 conversation DM + messages
- quelques compétences + 1 projet

---

## Conventions de données (recommandations)
- **Connexions**: une “connexion” peut être traitée comme **mutual follows** (A suit B et B suit A).
- **Visibilité des posts**: `public`, `private`, `friends`, `group` (avec `group_id` obligatoire si `group`).
- **Commentaires**: threads simples via `parent_comment_id`.

---

## Roadmap (idées d’amélioration)
- **API** (Node/Express, PHP, Python…) qui expose :
  - feed filtré par visibilité
  - recherche étudiants/projets
  - inbox/messages
- **Auth** (hash réel + sessions/JWT) et gestion des rôles
- **Notifications** (likes, commentaires, nouveaux messages)
- **Upload média** (stockage + modération)
- **Vraie page projets** (rôles, compétences recherchées, candidatures)

---

## Crédit / Auteur
Projet étudiant Ynov — YConnect.
