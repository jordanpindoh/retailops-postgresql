# RetailOps — Administration PostgreSQL

Projet pédagogique : déployer et administrer une base de commandes locale,
sécurisée et reproductible.

## Prérequis
- Docker Desktop démarré et Docker Compose disponible.
- Bash et OpenSSL sur la machine hôte.
- Accès Internet pour télécharger les images et compiler pgAudit.
- Ports locaux 5433 et 5434 disponibles selon l'environnement utilisé.

Environnement testé : Mac Intel, PostgreSQL 17.11 Alpine, pgAudit 17.1.

## Contenu
- compose.yaml : service PostgreSQL et volume persistant.
- Dockerfile : compilation de pgAudit dans une image personnalisée.
- data/ : quatre CSV synthétiques fournis.
- sql/projet/ : scripts SQL numérotés.
- config/pg_hba.conf : règles TLS et authentification SCRAM.
- scripts/ : installation et configuration des comptes de test.
- evidence/ : sorties des essais.
- docs/ : RGPD, supervision, sauvegarde et scénario de verrouillage.
- backups/ : dump logique ; archives WAL conservées localement.

## Préparer la configuration
Depuis la racine du projet, sur une installation neuve :

cp .env.example .env

Remplacer le mot de passe d'exemple dans .env par un secret local.
Ne jamais versionner ce fichier ni les clés privées.

Créer la configuration de reproduction :

cat > .env.repro <<'CONFIG'
COMPOSE_PROJECT_NAME=retailops_repro
RETAIL_PORT=5434
RETAIL_BACKUPS=./backups_repro
CONFIG

mkdir -p backups_repro

## Reconstruire une instance indépendante
bash scripts/initialiser_repro.sh

Le script crée l'environnement retailops_repro, importe les CSV,
configure les rôles, l'index, TLS, pgAudit et l'archivage WAL.
Il refuse de réimporter si le schéma retail existe déjà.
Il ne supprime aucune donnée.

Configurer ensuite les mots de passe :
bash scripts/configurer_comptes_repro.sh

Dans PostgreSQL, exécuter les commandes affichées par le script.
La saisie des mots de passe est interactive et invisible.

## Tester la connexion TLS de l'analyste
docker compose --env-file .env --env-file .env.repro exec db psql "host=localhost dbname=retail_admin user=analyst_login sslmode=verify-full sslrootcert=/var/lib/postgresql/data/server.crt" -W

Dans PostgreSQL :
SELECT current_user, COUNT(*) FROM retail.orders;
SELECT ssl, version FROM pg_stat_ssl WHERE pid = pg_backend_pid();

Résultats attendus : analyst_login, 5000 commandes, ssl = t.
Quitter avec \q.

## Tester les permissions sur la reproduction
docker compose --env-file .env --env-file .env.repro exec -T db psql -U postgres -d retail_admin -f /sql/projet/06_tests_droits.sql

Le refus UPDATE de l'analyste est attendu.
L'UPDATE du rôle applicatif doit réussir, puis être annulé.
Ce script teste les permissions avec SET ROLE ; la connexion par mot de passe
se teste séparément.

## Volumes attendus
| Table | Lignes |
|---|---:|
| customers | 300 |
| products | 80 |
| orders | 5000 |
| order_items | 9989 |

Les contrôles de doublons d'identifiants et de références invalides
doivent retourner zéro anomalie.

## Scripts et preuves
- 01–03 : schéma, import et contrôles.
- 04 : trois requêtes métier.
- 05–06 : rôles et tests des droits.
- 07 : configuration pgAudit.
- 08 : comparaison des volumes.
- 09–10 : mesure de performance et indexation.
- 11 : maintenance et tablespaces.
- 12 : configuration d'archivage WAL.
- 13 : supervision.
- 14 : démonstration COMMIT et ROLLBACK.
- 15 : insertion applicative et annulation vérifiées.

Ne pas exécuter tous les scripts aveuglément dans l'ordre :
l'import et la création des rôles supposent une base neuve ;
pgAudit et le WAL nécessitent une préparation et un redémarrage.
Le script d'installation orchestre ces dépendances.

## Sauvegarde et restauration
La procédure est décrite dans docs/sauvegarde.md.
Le dump custom a été restauré dans retail_restore_check.
Les quatre volumes restaurés sont identiques aux volumes source.
La comparaison des volumes ne démontre pas l'égalité de toutes les valeurs.

Les archives WAL ont été testées, mais aucun PITR complet n'a été réalisé.
RPO/RTO proposés et limites sont documentés dans docs/sauvegarde.md.

## Performance
Requête : commandes du client 42, triées par date décroissante.
Index : retail.orders(customer_id, ordered_at DESC).

Mesures relevées sur l'instance principale :
- Avant : Seq Scan ; 18 résultats ; 4982 lignes écartées ;
  41 shared hits au niveau racine ; 0,701 ms d'exécution.
- Après : Bitmap Index Scan et Bitmap Heap Scan, puis tri ;
  18 résultats ; 20 shared hits au niveau racine ; 0,345 ms.

Mesures ponctuelles, sensibles au cache et à la charge.
L'index ajoute un coût de stockage et de maintenance lors des écritures.
L'instance reconstruite possède déjà l'index : elle ne constitue pas
un nouveau scénario de mesure avant indexation.

## Exploitation
Consulter docs/supervision.md et docs/verrous.md.
Le volume nommé conserve les données après redémarrage du conteneur.
Sa suppression détruirait les données qu'il contient.

Arrêter le test sans supprimer son volume :
docker compose --env-file .env --env-file .env.repro stop

Redémarrer un test déjà initialisé :
docker compose --env-file .env --env-file .env.repro up -d --wait

## Limites
- Laboratoire local, non déployé en production.
- Certificat autosigné explicitement approuvé pour le test TLS.
- Données synthétiques ; limites de minimisation décrites dans docs/rgpd.md.
- Sauvegardes et WAL sur le même ordinateur.
- Aucune purge, sauvegarde planifiée ou notification automatique déployée.
- La branche pgAudit utilisée peut évoluer : figer son commit améliorerait
  la reproductibilité exacte de la construction.
- La reconstruction a été testée sur un volume neuf sur le même Mac,
  sans valider une installation sur une autre machine.

## Validations complémentaires du 3 novembre 2026
- Insertion réelle avec app_login : création d'une commande et de sa ligne,
  puis annulation par ROLLBACK. Les quatre validations retournent t.
  Script : sql/projet/15_test_insertion.sql.
  Preuve : evidence/test_insertion.txt.
- Blocage entre deux sessions observé avec pg_stat_activity et pg_locks.
  Preuve brute horodatée : evidence/preuve_blocage.txt.
  Les transactions du test ont été annulées pour libérer les verrous.

La preuve brute de blocage a été corrigée : capture du 3 novembre 2026 à
13:33:09 UTC, B (3403) bloquée par A (3309), transaction 813.
Le rapport PDF et sa version Markdown intègrent ces validations.
