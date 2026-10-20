# Moteur Texte : points tranchés et questions ouvertes

Préparation du moteur Texte (branche `moteur/texte`, soir du 20 oct. 2026, session sans surveillance, décision 39). Consigne reçue : en cas de doute, choisir l'option la plus simple et la plus réversible, la rendre configurable dans le JSON si elle touche au sens, à l'ordre ou à une convention scolaire, la noter ici et continuer.

## Points tranchés seul (à valider par Lamjed)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 1 | T07 : réponse | Index des mots (à partir de 0) dans la phrase découpée sur les espaces, `plusieurs` pour la sélection multiple | Un mot peut apparaître deux fois dans la phrase : le texte ne suffit pas | Liste de textes |
| 2 | T07 : ponctuation | Elle reste collée au mot (« الْحَدِيقَةِ. ») et ne compte pas dans la comparaison, qui porte sur les index | Découper la ponctuation ferait des « mots » vides | Mots sans ponctuation |
| 3 | T17 : clavier arabe du moteur | 28 lettres plus hamza, ta marbouta et alif maqsura sur 3 rangées dans l'ordre alphabétique, rangée de harakat si `harakat`, Effacer, Espace si le mot en a | Un même clavier sur tous les appareils, en naskh, sans dialecte ni suggestion | Clavier système arabe |
| 4 | T17 : clavier système en latin | `TextField` sans correction ni suggestion, pas de majuscule automatique | Les enfants le connaissent, pas d'AZERTY à dessiner | Clavier du moteur aussi en latin |
| 5 | T17 : comparaison | `comparerTextes` en Dart pur, normalisations du champ `normalisation` appliquées à une copie de la saisie et de la réponse, puis comparaison caractère par caractère, jamais de NFC ni de NFD | CLAUDE.md §5 et conventions-arabe.md | Comparaison souple (distance) |
| 6 | T17 : harakat | `harakat: false` par défaut (lettres seules), recommandé avec `harakat_ignorees` en 1re et 2e. `harakat: true` propose une rangée de harakat et la comparaison exacte attend la bonne haraka | Le plus simple pour un enfant de 1re, et le choix reste dans le contenu | Toujours des harakat |
| 7 | T17 : mot jamais affiché | Le mot n'apparaît qu'à l'explication (2e essai faux) ou en aperçu | C'est une dictée | Afficher le mot à l'indice |
| 8 | T17 : `casse` | `libre` par défaut (comparaison avec `casse` dans `normalisation` quand on veut l'ignorer), `minuscules` force le clavier en minuscules | Réversible | Toujours ignorer la casse |

### Nuit du 20 au 21 oct. (corrections du test de Lamjed du 20 oct. au soir)

| N° | Sujet | Choix fait | Pourquoi | Alternative |
|---|---|---|---|---|
| 9 | Clavier en grille | Rangées équilibrées : au plus 7 touches par rangée (moins si la largeur n'en loge pas 7 de 48 dp), nombre de rangées = plafond(n ÷ 7), touches réparties également (36 touches : 6 rangées de 6), largeur calculée = (largeur − écarts) ÷ touches par rangée | Lamjed demande environ 7 par rangée et au moins 48 dp : la répartition égale évite une dernière rangée d'une touche | 7 par rangée remplies de gauche à droite, dernière rangée incomplète |
| 10 | Clavier réduit | `clavier: reduit` et `lettres` (chaîne de lettres nues) dans le JSON, touches affichées dans l'ordre alphabétique du clavier complet. Défaut `complet` (comportement d'avant) avec un avertissement du validateur en 1re et 2e | Le contenu décide des lettres en trop (le validateur contrôle), l'ordre alphabétique ne trahit pas le mot. Un défaut selon le niveau aurait rendu invalides les exercices existants sans `lettres` | Défaut `reduit` en 1re et 2e avec lettres en trop tirées au hasard par le moteur |
| 11 | Champ français | `autofocus`, champ qui remplit sa case (`expands`), curseur `blue`, tout toucher dans la case ouvre le clavier | Sur l'iPhone, Lamjed n'a vu aucun champ : le `TextField` sans bordure dans une tuile vide ne se distinguait pas, et rien n'ouvrait le clavier. La cause exacte n'a pas pu être reproduite en test | Un libellé flottant « écris ici » (donnerait un texte de plus à traduire) |

## Questions ouvertes

1. **Ordre des touches du clavier arabe** : alphabétique (أ ب ت ث...) sur 3 rangées, ou disposition des claviers arabes usuels ? L'alphabétique aide un enfant de 1re qui apprend les lettres. Configurable plus tard par `clavier` dans le JSON si besoin.
2. **Hamza** : une seule touche ء, ou aussi أ إ آ ؤ ئ ? Le clavier propose أ, إ, آ, ء, ؤ, ئ comme touches à part (lettres de l'alphabet élargi), à confirmer.
3. **T17 avec plusieurs mots** (phrase dictée) : hors MVP (un mot).
4. **Harakat des exemples arabes** : brouillon, relecture humaine.
5. **T07 sur un texte long** (plusieurs phrases, 4e à 6e) : le `Wrap` suffit, mais la limite de 20 mots du schéma est à confirmer.
