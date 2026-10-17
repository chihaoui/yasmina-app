# Conventions d'écriture de l'arabe

Règles valables pour tout le contenu arabe de Yasmina (arabe, maths et éveil), décidées par Lamjed le 17 octobre 2026. Elles s'appliquent aux textes écrits à la main comme aux textes produits par le pipeline de génération.

## A. Alif de liaison en début de phrase : avec kasra

En début de phrase, l'alif de liaison (همزة الوصل) porte une kasra.

| Correct | À éviter |
|---|---|
| اِسْتَمِعْ إِلَى أَوَّلِ صَوْتٍ فِي كُلِّ كَلِمَةٍ. | استَمِعْ إِلَى أَوَّلِ صَوْتٍ فِي كُلِّ كَلِمَةٍ. |

## B. Alif suscrit simplifié : jamais de U+0670

On écrit la forme simplifiée avec une fatha, jamais l'alif suscrit (U+0670, ARABIC LETTER SUPERSCRIPT ALEF).

| Correct | À éviter |
|---|---|
| هَلْ هَذِهِ الْجُمْلَةُ صَحِيحَةٌ؟ | هَلْ هٰذِهِ الْجُمْلَةُ صَحِيحَةٌ؟ |

Même règle pour هَذَا, ذَلِكَ, لَكِنَّ. Le validateur signale tout U+0670 par l'avertissement `alif_suscrit`, avec le chemin exact du texte.

## C. Article : soukoun sur le lam devant une lettre lunaire

Le lam de l'article porte toujours un soukoun devant une lettre lunaire, hamza comprise. Devant une lettre solaire, il ne porte rien et la lettre suivante prend une shadda. Devant un alif de liaison, le lam porte une kasra.

| Cas | Correct | À éviter |
|---|---|---|
| Lettre lunaire | الْكَلِمَةُ | الكَلِمَةُ |
| Hamza (lunaire) | الْإِعْدَادَاتُ | الإِعْدَادَاتُ |
| Lettre solaire | الصَّحِيحَةُ | الْصَّحِيحَةُ |
| Alif de liaison | الِاسْمُ | الْاسْمُ |

Le validateur et le test des textes de l'interface signalent un lam sans soukoun devant une lettre lunaire (dans un texte vocalisé) par l'avertissement `lam_sans_soukoun`.

## Jamais de NFC ni de NFD sur les textes stockés

Les textes sont stockés exactement comme ils ont été écrits et relus. Aucun outil (app, validateur, back-office, pipeline) ne leur applique de normalisation Unicode NFC ou NFD.

Pourquoi : la normalisation réordonne les signes combinants. Par exemple, une shadda saisie avant la fatha (ط + U+0651 + U+064E) devient ط + U+064E + U+0651 après NFC. Le rendu ne change pas forcément, mais les octets changent : l'empreinte de l'exercice ne correspond plus, les comparaisons de réponses échouent et le texte relu n'est plus celui qui est stocké.

Les comparaisons de réponses passent par le champ `normalisation` de l'exercice. Il s'applique à une copie, au moment de comparer, et chaque normalisation est testée.

## Toute étape reste en brouillon jusqu'à la relecture humaine des harakat

- Un exercice nouveau ou modifié a le statut `brouillon`.
- Il ne passe à `valide` qu'après la relecture humaine de tous ses textes arabes (harakat, conventions A et B).
- L'empreinte est recalculée après chaque modification de `type`, `consigne`, `donnees` ou `reponse` (méthode décrite dans `schema/README.md`).
- Les avertissements du validateur (`harakat_manquantes`, `alif_suscrit`) aident la relecture mais ne la remplacent pas.

Exemple : `apps/mobile/assets/content/ar/1/ar-1-t1-u1-e01.json` est passé en `valide` le 17 octobre 2026, après relecture par Lamjed.
