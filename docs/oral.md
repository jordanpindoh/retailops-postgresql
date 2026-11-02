# Trame de démonstration orale

1. Architecture : expliquer Compose, le port local et le volume persistant.
2. Modèle : présenter les quatre tables et les 5 000 commandes ; afficher les contrôles.
3. Sécurité : connexion analyste en verify-full, SELECT réussi, UPDATE refusé ; écriture applicative annulée.
4. Audit : afficher audit_write.txt, expliquer les informations masquées.
5. Récupération : présenter la base restaurée et la comparaison des volumes ; distinguer dump, WAL et PITR.
6. Performance : comparer les deux plans et préciser que le tri subsiste.
7. Exploitation : présenter les seuils de supervision, le verrou observé et les limites.

Chaque membre doit comprendre les commandes qu'il présente. Ne pas annoncer un PITR testé ni un RTO mesuré. Les tests d'écriture doivent se terminer par ROLLBACK.
