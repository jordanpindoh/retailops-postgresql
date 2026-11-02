# Sauvegarde et récupération — RetailOps

## Réalisé et vérifié
- Dump logique au format custom : backups/retail_admin.dump.
- Restauration dans une base distincte : retail_restore_check.
- Comparaison des volumes : 300 clients, 80 produits, 5000 commandes,
  9989 lignes de commande dans les deux bases.
- Archivage WAL activé ; au moment du test, un segment de 16 Mo archivé
  et aucun échec enregistré.
- Preuves dans evidence/ : dump_contenu.txt, restauration.txt,
  volumes_source.txt, volumes_restaures.txt, comparaison_restauration.txt
  et wal.txt.

La comparaison des volumes ne démontre pas à elle seule l'égalité de toutes
les valeurs ni le bon fonctionnement des permissions après restauration.

## Refaire une sauvegarde logique
Depuis la racine du projet :
docker compose exec -T db pg_dump -U postgres -d retail_admin -Fc > backups/retail_admin.dump

Vérifier le code de sortie de pg_dump et la lisibilité de l'archive.
Le dump ne sauvegarde pas les rôles globaux ni la configuration du serveur :
les scripts et fichiers de configuration doivent être conservés séparément.

## Restaurer dans une nouvelle base
Choisir un nom de base de test qui n'existe pas encore :
docker compose exec -T db createdb -U postgres retail_restore_test

docker compose exec -T db pg_restore -U postgres --exit-on-error --no-owner --no-privileges -d retail_restore_test /backups/retail_admin.dump

Comparer les quatre volumes avec sql/projet/08_volumes.sql.
Cette procédure restaure les données sans reproduire les droits applicatifs.
Les rôles et permissions doivent être réappliqués et testés pour une reprise
complète du service.

## Objectifs proposés, non encore garantis
- RPO : 24 heures avec un dump quotidien réussi et conservé hors du Mac.
- RTO : 30 minutes pour cette petite base, sur un environnement disponible,
  incluant restauration, configuration des accès et contrôles.

Ces objectifs nécessitent une planification des sauvegardes, des alertes,
une copie externe et des essais chronométrés.
Le projet réalise actuellement une sauvegarde manuelle : aucun RPO de
24 heures n'est donc garanti. Le RTO n'a pas été mesuré.

## WAL et PITR
Le PITR permet de restaurer une sauvegarde physique, puis de rejouer une
chaîne continue de WAL jusqu'à un instant cible.
Le dump logique ne remplace pas cette sauvegarde physique.
Le projet démontre l'archivage WAL, mais ne réalise pas de PITR complet :
aucune sauvegarde physique ni restauration à un instant cible n'a été testée.

L'archivage actuel dépend de la fermeture des segments WAL.
Aucun délai maximal d'archivage n'est garanti par cette configuration.

## Risques et améliorations
Le volume PostgreSQL, les dumps et les WAL sont sur le même Mac.
Une panne ou perte du Mac peut donc affecter toutes les copies.
Prévoir une copie externe protégée, une politique de rétention coordonnée
avec les sauvegardes physiques et des exercices de restauration réguliers.
L'archivage local n'a pas de purge automatique et doit être surveillé.
