# Relecture des harakat

`harakat.html` est produite par `dart run tool/relecture_harakat.dart` (depuis la racine du dépôt). Elle rassemble tous les textes arabes en statut brouillon : exemples de `schema/exemples/`, exercices en brouillon des étapes embarquées, fixtures et libellés arabes des tests et du moteur, textes de l'interface (`app_ar.arb`). Les textes sont groupés par type, affichés en grand avec Noto Naskh Arabic (police embarquée dans la page : elle s'ouvre sans réseau, depuis le Finder ou le navigateur).

Pour chaque texte : le fichier source et son chemin, une case « ok » ou « à corriger » et un champ de commentaire (la bonne écriture, par exemple). Les choix restent dans le navigateur entre deux ouvertures. Le bouton « Exporter en JSON » télécharge `relecture-harakat-AAAA-MM-JJ.json`, à déposer dans ce dossier ou à envoyer à Claude Code pour appliquer les corrections.

À régénérer après tout ajout ou modification de texte arabe (la page committée date de la nuit du 20 au 21 oct. 2026).
