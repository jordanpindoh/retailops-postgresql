# Revue du dossier remis

Contrôles statiques effectués sur le ZIP : 14 scripts SQL, quatre CSV avec volumes attendus, scripts Bash syntaxiquement valides, comparaisons source/restauration et avant/après redémarrage identiques, signature PGDMP présente. Les preuves de TLS, pgAudit, performance et reconstruction ont été lues. Aucun fichier .env ni clé privée n'est inclus.

Limites : Docker et pg_restore ne sont pas disponibles dans l'environnement de revue. Le dump n'a donc pas été restauré une nouvelle fois ici. Les résultats opérationnels proviennent des sorties enregistrées sur le Mac de l'étudiant. Le verrouillage est décrit dans une transcription, sans sortie brute sauvegardée. Aucun vérificateur officiel du kit enseignant n'a été fourni.

Le rapport PDF compte six pages ; sa version Markdown est modifiable.

GitHub : conserver .env.example et les règles d'exclusion ; ne pas forcer l'ajout des dumps/WAL. Les CSV synthétiques sont inclus pour la reproduction du devoir ; vérifier les consignes de diffusion de l'école avant publication publique. Aucun fichier du support de cours n'est inclus.
