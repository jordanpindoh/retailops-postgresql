# Supervision RetailOps

## Collecte
Exécuter sql/projet/13_supervision.sql.
La sortie de référence est conservée dans evidence/supervision.txt.
Cette collecte est manuelle ; aucune notification automatique n'est déployée.

## Indicateurs et seuils proposés

| Indicateur | Seuil d'alerte | Justification et action |
|---|---|---|
| Blocage | Attente de verrou supérieure à 30 secondes | Anormale pour des transactions courtes. Identifier le bloqueur avec pg_blocking_pids, puis examiner sa transaction avant intervention. |
| Archivage WAL | Augmentation de failed_count entre deux collectes | Peut compromettre la continuité des archives. Vérifier les logs, les permissions et l'espace de destination. |
| Connexions | Plus de 80 % de max_connections pendant 5 minutes | Conserver une marge pour les nouvelles sessions. Examiner les connexions inutiles et le pool applicatif. |
| Requête active | Durée supérieure à 5 secondes | Seuil exploratoire pour cette petite base. Examiner le plan SQL et les attentes ; ajuster selon l'usage. |
| Deadlocks | Augmentation de deadlocks entre deux collectes | Examiner l'ordre des écritures et réduire la durée des transactions. |
| Espace disque | Moins de 20 % d'espace libre | Préserver une marge pour les données, WAL et sauvegardes. Contrôler le disque du Mac et celui de la VM Docker. |

Les compteurs sont cumulatifs : leurs variations doivent être comparées
entre collectes, en tenant compte des remises à zéro des statistiques.

## Maintenance
Surveiller n_dead_tup, les dates VACUUM/ANALYZE et la croissance des tables.
n_live_tup et n_dead_tup sont des estimations.
Autovacuum reste activé ; ses seuils peuvent expliquer l'absence d'exécution
sur les petites tables. VACUUM ANALYZE a été exécuté sur orders.

## Limites
Le script observe les requêtes longues encore actives au moment du relevé.
Il ne constitue pas un historique des requêtes lentes terminées.
Les seuils proposés doivent être ajustés après observation d'une charge réelle.
