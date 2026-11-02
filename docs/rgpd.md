# RetailOps — Données et protection des accès

## Périmètre
Les données du projet sont synthétiques et ne représentent aucune personne
réelle. Cette note décrit les mesures retenues dans le laboratoire et les
adaptations à prévoir si des données personnelles réelles étaient utilisées.
Elle ne constitue pas une attestation de conformité RGPD.

## Données et finalités
- customers : identifiant, nom, email, région, date de création.
- products : références, catégories, prix et disponibilité.
- orders : client, date, statut et canal de commande.
- order_items : produits commandés, quantités et prix.

Finalités simulées : gestion des commandes, analyse des ventes et exploitation
technique de la base. Dans un contexte réel, les commandes liées à un client
constitueraient aussi des données personnelles.

## Matrice des accès

| Compte | Données accessibles | Opérations | Finalité |
|---|---|---|---|
| analyst_login via retail_ro | Les quatre tables | SELECT | Analyse des ventes |
| app_login via retail_rw et retail_ro | Les quatre tables | SELECT ; INSERT sur orders et order_items ; UPDATE du statut sur orders | Enregistrement et suivi des commandes |
| postgres | Ensemble de la base et configuration | Administration complète | Installation, maintenance et récupération |

Les comptes analyst_login et app_login ne sont pas superutilisateurs.
Les accès autorisés et refusés sont testés dans evidence/droits.txt.

## Minimisation
Les trois requêtes métier ne nécessitent pas les noms et emails.
Limite actuelle : l'analyste dispose néanmoins d'un accès direct à customers,
y compris à ces champs.
Avec des données réelles, remplacer cet accès par des vues limitées aux
colonnes nécessaires et adapter les droits avant toute mise en service.

## Protection
- Port Docker publié uniquement sur 127.0.0.1.
- Authentification réseau SCRAM-SHA-256.
- TLS obligatoire sur les connexions réseau.
- Test verify-full avec certificat autosigné explicitement approuvé en local.
- En production : certificats gérés, renouvellement et autorité de confiance.
- Mots de passe et clés privées exclus de Git.
- Accès au Mac, au volume Docker et aux sauvegardes réservé à l'administrateur.

## Audit
pgAudit journalise les écritures, changements de structure et de rôles.
Le texte SQL et les paramètres sont désactivés dans les événements pgAudit.
Les autres messages techniques peuvent contenir des informations : examiner
et expurger les journaux avant partage.
Le projet conserve une preuve d'écriture auditée sans données client.

## Conservation proposée pour le laboratoire
- Données et preuves : jusqu'à la fin de l'évaluation et des éventuels recours,
  puis suppression selon les consignes de l'école.
- Logs techniques : objectif de 30 jours maximum.
- Sauvegardes et WAL : conservation limitée à la période des essais.

Ces durées sont des propositions pédagogiques. Aucune purge automatique
fondée sur ces durées n'est actuellement déployée.
Avec des données réelles, les durées, la base légale et les obligations de
conservation devraient être établies avec les responsables compétents.

## Sauvegardes et limites
Le dump a été restauré dans une base distincte et ses volumes comparés.
Les archives WAL sont conservées sur le même Mac : elles ne protègent pas
contre la perte de cet ordinateur.
Les sauvegardes ne sont pas chiffrées par ce projet.
Prévoir en production une copie externe protégée, un chiffrement adapté,
des essais de restauration et une politique de suppression des copies.
Une restauration doit aussi tenir compte des suppressions déjà demandées.
