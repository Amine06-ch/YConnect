## Scripts SQL (PostgreSQL)

Ces scripts sont la version **PostgreSQL** du schéma YConnect.

### Exécution (copier-coller)
Depuis la racine du projet :

```bash
psql -U <USER> -d postgres -f sql/postgres/00_create_db.sql
psql -U <USER> -d school_social -f sql/postgres/01_schema.sql
psql -U <USER> -d school_social -f sql/postgres/02_demo.sql
psql -U <USER> -d school_social -f sql/postgres/04_frontend_compat.sql
psql -U <USER> -d school_social -f sql/postgres/05_auth.sql
psql -U <USER> -d school_social -f sql/postgres/03_queries.sql
```

### Notes
- La base créée s’appelle `school_social`.
- Si ton outil n’accepte que du **SQL pur**, n’exécute pas `psql ... -f` : ouvre chaque fichier et exécute-le dans la bonne base.
- Le schéma supprime les tables/vues existantes si besoin (pour relancer facilement).
