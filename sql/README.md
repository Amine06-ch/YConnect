## Scripts SQL (MySQL 8)

### Prérequis
Tu dois avoir MySQL 8 (ou compatible) et un utilisateur avec les droits `CREATE`, `DROP` (pour les tables) et `INSERT`.

### Commandes (copier-coller)
```bash
mysql -u <USER> -p < sql/01_schema.sql
mysql -u <USER> -p < sql/02_demo.sql
mysql -u <USER> -p < sql/04_frontend_compat.sql
mysql -u <USER> -p < sql/03_queries.sql
```

### Base créée
La base s'appelle `school_social`.

### Remarque
Le script de schéma supprime les tables si elles existent, puis les recrée (utile pour relancer le projet).
