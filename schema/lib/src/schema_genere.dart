// Fichier généré par tool/generer_schema.dart. Ne pas modifier à la main.
// Source de vérité : schema/edu-content-1.0.schema.json

/// Texte exact de schema/edu-content-1.0.schema.json.
const String texteSchemaEduContent = r'''
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:forgia:edu-content:1.0",
  "title": "edu-content/1.0",
  "description": "Une étape de contenu Yasmina : bloc generation, bloc etape et liste des exercices. Les règles qu'un JSON Schema ne sait pas exprimer (langues, références entre id, cohérence des id) sont vérifiées par le validateur Dart du package edu_content.",
  "type": "object",
  "required": ["generation", "etape", "exercices"],
  "additionalProperties": false,
  "properties": {
    "generation": { "$ref": "#/$defs/generation" },
    "etape": { "$ref": "#/$defs/etape" },
    "exercices": {
      "type": "array",
      "minItems": 1,
      "items": { "$ref": "#/$defs/exercice" }
    }
  },
  "$defs": {
    "texteNonVide": { "type": "string", "minLength": 1 },
    "texteGenre": {
      "description": "Attendu : un texte non vide, ou un objet avec deux textes non vides masculin et feminin (accord selon le genre du profil).",
      "oneOf": [
        { "$ref": "#/$defs/texteNonVide" },
        {
          "type": "object",
          "required": ["masculin", "feminin"],
          "additionalProperties": false,
          "properties": {
            "masculin": { "$ref": "#/$defs/texteNonVide" },
            "feminin": { "$ref": "#/$defs/texteNonVide" }
          }
        }
      ]
    },
    "cheminMedia": {
      "description": "Chemin relatif d'un fichier image ou audio.",
      "type": "string",
      "minLength": 1
    },
    "langue": { "enum": ["ar", "fr", "en"] },
    "idEtape": {
      "description": "<matiere>-<niveau>-t<trimestre>-u<unite>-e<ordre sur 2 chiffres>, par exemple ar-1-t1-u1-e01.",
      "type": "string",
      "pattern": "^(ar|fr|en|ma|ev)-[1-6]-t[1-3]-u([1-9]|[1-9][0-9])-e(0[1-9]|[1-9][0-9])$"
    },
    "idSequence": {
      "description": "<id de l'étape>-s<n>, par exemple ar-1-t1-u1-e01-s1.",
      "type": "string",
      "pattern": "^(ar|fr|en|ma|ev)-[1-6]-t[1-3]-u([1-9]|[1-9][0-9])-e(0[1-9]|[1-9][0-9])-s([1-9]|[1-9][0-9])$"
    },
    "idExercice": {
      "description": "<id de l'étape>-x<nn>, par exemple ar-1-t1-u1-e01-x03. Numéro de création, pas une position. Jamais réutilisé.",
      "type": "string",
      "pattern": "^(ar|fr|en|ma|ev)-[1-6]-t[1-3]-u([1-9]|[1-9][0-9])-e(0[1-9]|[1-9][0-9])-x(0[1-9]|[1-9][0-9])$"
    },
    "idChoix": { "type": "string", "pattern": "^c[1-9]$" },
    "idPreuve": { "type": "string", "pattern": "^p[1-9]$" },

    "generation": {
      "type": "object",
      "required": ["id", "schema", "date", "modele", "version_prompt", "auteur"],
      "additionalProperties": false,
      "properties": {
        "id": {
          "description": "gen-<id de l'étape>-<aaaammjj>-<nn>, par exemple gen-ar-1-t1-u1-e01-20261017-01.",
          "type": "string",
          "pattern": "^gen-(ar|fr|en|ma|ev)-[1-6]-t[1-3]-u([1-9]|[1-9][0-9])-e(0[1-9]|[1-9][0-9])-[0-9]{8}-[0-9]{2}$"
        },
        "schema": { "const": "edu-content/1.0" },
        "date": {
          "description": "Date de génération au format AAAA-MM-JJ.",
          "type": "string",
          "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
        },
        "modele": {
          "description": "Modèle qui a produit le contenu, ou manuel.",
          "$ref": "#/$defs/texteNonVide"
        },
        "version_prompt": { "$ref": "#/$defs/texteNonVide" },
        "auteur": { "$ref": "#/$defs/texteNonVide" }
      }
    },

    "etape": {
      "type": "object",
      "required": ["id", "matiere", "niveau", "trimestre", "unite", "ordre", "langue", "titre", "sequences"],
      "additionalProperties": false,
      "properties": {
        "id": { "$ref": "#/$defs/idEtape" },
        "matiere": { "enum": ["arabe", "francais", "anglais", "maths", "eveil"] },
        "niveau": { "type": "integer", "minimum": 1, "maximum": 6 },
        "trimestre": { "type": "integer", "minimum": 1, "maximum": 3 },
        "unite": { "type": "integer", "minimum": 1, "maximum": 99 },
        "ordre": { "type": "integer", "minimum": 1, "maximum": 99 },
        "langue": { "$ref": "#/$defs/langue" },
        "titre": { "$ref": "#/$defs/texteNonVide" },
        "sequences": {
          "type": "array",
          "minItems": 1,
          "items": { "$ref": "#/$defs/sequence" }
        }
      }
    },
    "sequence": {
      "type": "object",
      "required": ["id", "titre", "exercices"],
      "additionalProperties": false,
      "properties": {
        "id": { "$ref": "#/$defs/idSequence" },
        "titre": { "$ref": "#/$defs/texteNonVide" },
        "exercices": {
          "description": "Id des exercices, dans l'ordre de passage.",
          "type": "array",
          "minItems": 1,
          "uniqueItems": true,
          "items": { "$ref": "#/$defs/idExercice" }
        }
      }
    },

    "exercice": {
      "type": "object",
      "required": [
        "id", "type", "gabarit", "competence", "critere", "niveau_critere", "langue",
        "consigne", "donnees", "reponse", "feedbacks", "empreinte", "statut", "version"
      ],
      "additionalProperties": false,
      "properties": {
        "id": { "$ref": "#/$defs/idExercice" },
        "type": {
          "description": "Type du catalogue, de T01 à T63.",
          "type": "string",
          "pattern": "^T(0[1-9]|[1-5][0-9]|6[0-3])$"
        },
        "gabarit": {
          "description": "Variante d'affichage du type, en kebab-case (référentiel à venir).",
          "type": "string",
          "pattern": "^[a-z0-9]+(-[a-z0-9]+)*$"
        },
        "competence": {
          "description": "Code libre en kebab-case, préfixé par le code matière (ar-, fr-, en-, ma-, ev-). Référentiel à venir.",
          "type": "string",
          "pattern": "^(ar|fr|en|ma|ev)(-[a-z0-9]+)+$"
        },
        "critere": { "type": "string", "pattern": "^C[1-9][0-9]?$" },
        "niveau_critere": { "enum": ["minimal", "perfectionnement"] },
        "langue": { "$ref": "#/$defs/langue" },
        "consigne": {
          "type": "object",
          "required": ["texte"],
          "additionalProperties": false,
          "properties": {
            "texte": { "$ref": "#/$defs/texteGenre" },
            "audio": { "$ref": "#/$defs/cheminMedia" }
          }
        },
        "donnees": {
          "description": "Données propres au type. Détaillées pour les 13 types du moteur Choix (T01, T02, T03, T04, T05, T18, T19, T23, T24, T45, T46, T55, T61), génériques pour les autres types (précisées moteur par moteur).",
          "type": "object"
        },
        "reponse": {
          "description": "Réponse attendue, propre au type.",
          "not": { "type": "null" }
        },
        "normalisation": {
          "description": "Normalisations appliquées uniquement au moment de comparer une réponse, jamais au texte stocké. Vide par défaut.",
          "type": "array",
          "uniqueItems": true,
          "items": {
            "enum": ["espaces", "casse", "ponctuation", "tatweel", "chiffres", "harakat_ignorees"]
          },
          "default": []
        },
        "tolerance": {
          "description": "Écart toléré pour une réponse numérique. 0 par défaut.",
          "type": "number",
          "minimum": 0,
          "default": 0
        },
        "feedbacks": {
          "type": "object",
          "required": ["reussite", "indice", "explication"],
          "additionalProperties": false,
          "properties": {
            "reussite": { "$ref": "#/$defs/texteGenre" },
            "indice": { "$ref": "#/$defs/texteGenre" },
            "explication": { "$ref": "#/$defs/texteGenre" }
          }
        },
        "empreinte": {
          "description": "sha256 du JSON canonique (clés triées, sans espaces, UTF-8) de type, consigne, donnees et reponse.",
          "type": "string",
          "pattern": "^sha256:[0-9a-f]{64}$"
        },
        "statut": { "enum": ["brouillon", "valide", "publie", "rejete"] },
        "version": { "type": "integer", "minimum": 1 }
      },
      "allOf": [
        {
          "if": {
            "required": ["type"],
            "properties": { "type": { "enum": ["T01", "T04", "T05", "T45"] } }
          },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesChoix" },
              "reponse": { "$ref": "#/$defs/reponseChoix" }
            }
          }
        },
        {
          "if": {
            "required": ["type"],
            "properties": { "type": { "const": "T02" } }
          },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesVraiFaux" },
              "reponse": { "$ref": "#/$defs/reponseVraiFaux" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "enum": ["T03", "T55"] } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesEcoute" },
              "reponse": { "$ref": "#/$defs/reponseChoix" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T18" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesFormeLettre" },
              "reponse": { "$ref": "#/$defs/reponseChoix" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T19" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesHaraka" },
              "reponse": { "$ref": "#/$defs/reponseHaraka" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T23" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesComparer" },
              "reponse": { "$ref": "#/$defs/reponseComparer" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T24" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesSuite" },
              "reponse": { "$ref": "#/$defs/reponseChoix" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T46" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesJustification" },
              "reponse": { "$ref": "#/$defs/reponseJustification" }
            }
          }
        },
        {
          "if": { "required": ["type"], "properties": { "type": { "const": "T61" } } },
          "then": {
            "properties": {
              "donnees": { "$ref": "#/$defs/donneesResume" },
              "reponse": { "$ref": "#/$defs/reponseChoix" }
            }
          }
        }
      ]
    },

    "choix": {
      "description": "Attendu : un choix avec un id et au moins un texte ou une image.",
      "type": "object",
      "required": ["id"],
      "additionalProperties": false,
      "anyOf": [{ "required": ["texte"] }, { "required": ["image"] }],
      "properties": {
        "id": { "$ref": "#/$defs/idChoix" },
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "image": { "$ref": "#/$defs/cheminMedia" },
        "audio": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "choixTexte": {
      "description": "Choix avec un texte obligatoire (phrase, forme de lettre, preuve).",
      "type": "object",
      "required": ["id", "texte"],
      "additionalProperties": false,
      "properties": {
        "id": { "$ref": "#/$defs/idChoix" },
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "audio": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "listeChoix": {
      "type": "array",
      "minItems": 2,
      "maxItems": 6,
      "items": { "$ref": "#/$defs/choix" }
    },
    "support": {
      "description": "Attendu : un support affiché au-dessus des choix, avec au moins un texte, une image ou un audio.",
      "type": "object",
      "additionalProperties": false,
      "anyOf": [{ "required": ["texte"] }, { "required": ["image"] }, { "required": ["audio"] }],
      "properties": {
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "image": { "$ref": "#/$defs/cheminMedia" },
        "audio": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "ecoute": {
      "description": "Ce que l'enfant entend. texte : dit par la synthèse vocale du prototype et relu par l'humain, jamais affiché. audio : fichier pré-généré, plus tard.",
      "type": "object",
      "required": ["texte"],
      "additionalProperties": false,
      "properties": {
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "audio": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "donneesChoix": {
      "description": "T01 (QCM, une bonne réponse), T04 (trouve l'intrus, une bonne réponse, 3 choix au moins), T05 (choix multiple) et T45 (barrer les éléments faux).",
      "type": "object",
      "required": ["choix"],
      "additionalProperties": false,
      "properties": {
        "support": { "$ref": "#/$defs/support" },
        "choix": { "$ref": "#/$defs/listeChoix" },
        "melanger": { "type": "boolean", "default": true }
      }
    },
    "reponseChoix": {
      "description": "Id des bons choix (T45 : des éléments à barrer). Nombre contrôlé par le validateur Dart : exactement 1 pour T01, T03, T04, T18, T24 et T55, au moins 1 pour T05 et T45, au moins 2 pour T61, jamais tous les choix pour T05, T45 et T61.",
      "type": "object",
      "required": ["choix"],
      "additionalProperties": false,
      "properties": {
        "choix": {
          "type": "array",
          "minItems": 1,
          "maxItems": 6,
          "uniqueItems": true,
          "items": { "$ref": "#/$defs/idChoix" }
        }
      }
    },
    "donneesVraiFaux": {
      "description": "T02. Les libellés vrai et faux viennent du moteur, dans la langue de l'exercice.",
      "type": "object",
      "required": ["affirmation"],
      "additionalProperties": false,
      "properties": {
        "affirmation": { "$ref": "#/$defs/texteNonVide" },
        "image": { "$ref": "#/$defs/cheminMedia" },
        "audio": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "reponseVraiFaux": {
      "type": "object",
      "required": ["valeur"],
      "additionalProperties": false,
      "properties": { "valeur": { "type": "boolean" } }
    },

    "donneesEcoute": {
      "description": "T03 (écoute et choisis, souvent des images) et T55 (paires minimales sonores : le texte entendu est celui du bon choix).",
      "type": "object",
      "required": ["ecoute", "choix"],
      "additionalProperties": false,
      "properties": {
        "ecoute": { "$ref": "#/$defs/ecoute" },
        "choix": { "$ref": "#/$defs/listeChoix" },
        "melanger": { "type": "boolean", "default": true }
      }
    },
    "donneesFormeLettre": {
      "description": "T18 (arabe) : choisir la forme d'une lettre selon sa position dans le mot. Chaque choix contient la lettre.",
      "type": "object",
      "required": ["lettre", "position", "choix"],
      "additionalProperties": false,
      "properties": {
        "lettre": {
          "description": "Une seule lettre arabe, sans haraka.",
          "type": "string",
          "pattern": "^[\u0621-\u064A]$"
        },
        "position": { "enum": ["isolee", "debut", "milieu", "fin"] },
        "mot": {
          "description": "Mot vocalisé où la lettre occupe cette position.",
          "$ref": "#/$defs/texteNonVide"
        },
        "choix": {
          "type": "array",
          "minItems": 2,
          "maxItems": 4,
          "items": { "$ref": "#/$defs/choixTexte" }
        },
        "melanger": { "type": "boolean", "default": true }
      }
    },
    "donneesHaraka": {
      "description": "T19 (arabe) : choisir la haraka d'une lettre. Le mot complet vaut avant + lettre + haraka de la réponse + apres.",
      "type": "object",
      "required": ["avant", "lettre", "apres", "harakat"],
      "additionalProperties": false,
      "properties": {
        "avant": {
          "description": "Début du mot, vocalisé, avant la lettre (peut être vide).",
          "type": "string"
        },
        "lettre": {
          "description": "La lettre dont on cherche la haraka : une seule lettre arabe, sans haraka.",
          "type": "string",
          "pattern": "^[\u0621-\u064A]$"
        },
        "apres": {
          "description": "Fin du mot, vocalisée, après la lettre (peut être vide).",
          "type": "string"
        },
        "harakat": {
          "description": "Harakat proposées, dans l'ordre d'affichage.",
          "type": "array",
          "minItems": 2,
          "maxItems": 4,
          "uniqueItems": true,
          "items": { "$ref": "#/$defs/haraka" }
        },
        "ecoute": { "$ref": "#/$defs/ecoute" }
      }
    },
    "haraka": { "enum": ["fatha", "damma", "kasra", "soukoun"] },
    "reponseHaraka": {
      "type": "object",
      "required": ["haraka"],
      "additionalProperties": false,
      "properties": { "haraka": { "$ref": "#/$defs/haraka" } }
    },
    "donneesComparer": {
      "description": "T23 : comparer deux nombres. La réponse se lit « a signe b » en notation mathématique (de gauche à droite, isolée du sens de la phrase).",
      "type": "object",
      "required": ["a", "b"],
      "additionalProperties": false,
      "properties": { "a": { "type": "number" }, "b": { "type": "number" } }
    },
    "reponseComparer": {
      "type": "object",
      "required": ["signe"],
      "additionalProperties": false,
      "properties": { "signe": { "enum": ["<", "=", ">"] } }
    },
    "elementSuite": {
      "description": "Attendu : un élément de suite avec au moins un texte ou une image.",
      "type": "object",
      "additionalProperties": false,
      "anyOf": [{ "required": ["texte"] }, { "required": ["image"] }],
      "properties": {
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "image": { "$ref": "#/$defs/cheminMedia" }
      }
    },
    "donneesSuite": {
      "description": "T24 : suites et motifs. L'élément à trouver vient juste après le dernier élément de la suite.",
      "type": "object",
      "required": ["suite", "choix"],
      "additionalProperties": false,
      "properties": {
        "suite": {
          "type": "array",
          "minItems": 3,
          "maxItems": 12,
          "items": { "$ref": "#/$defs/elementSuite" }
        },
        "choix": { "$ref": "#/$defs/listeChoix" },
        "melanger": { "type": "boolean", "default": true }
      }
    },
    "donneesJustification": {
      "description": "T46 : répondre (A), puis toucher la phrase du texte qui le prouve (B). Chaque preuve est une phrase copiée du texte.",
      "type": "object",
      "required": ["texte", "question", "choix", "preuves"],
      "additionalProperties": false,
      "properties": {
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "question": { "$ref": "#/$defs/texteNonVide" },
        "choix": {
          "type": "array",
          "minItems": 2,
          "maxItems": 4,
          "items": { "$ref": "#/$defs/choixTexte" }
        },
        "preuves": {
          "type": "array",
          "minItems": 2,
          "maxItems": 6,
          "items": { "$ref": "#/$defs/preuve" }
        },
        "melanger": { "type": "boolean", "default": true }
      }
    },
    "preuve": {
      "type": "object",
      "required": ["id", "texte"],
      "additionalProperties": false,
      "properties": {
        "id": { "$ref": "#/$defs/idPreuve" },
        "texte": { "$ref": "#/$defs/texteNonVide" }
      }
    },
    "reponseJustification": {
      "description": "Exactement une bonne réponse et une preuve (règles Dart).",
      "type": "object",
      "required": ["choix", "preuves"],
      "additionalProperties": false,
      "properties": {
        "choix": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": { "$ref": "#/$defs/idChoix" }
        },
        "preuves": {
          "type": "array",
          "minItems": 1,
          "maxItems": 1,
          "items": { "$ref": "#/$defs/idPreuve" }
        }
      }
    },
    "donneesResume": {
      "description": "T61 : choisir les phrases qui résument le texte (au moins 2 bonnes réponses, jamais toutes).",
      "type": "object",
      "required": ["texte", "choix"],
      "additionalProperties": false,
      "properties": {
        "texte": { "$ref": "#/$defs/texteNonVide" },
        "choix": {
          "type": "array",
          "minItems": 3,
          "maxItems": 6,
          "items": { "$ref": "#/$defs/choixTexte" }
        },
        "melanger": { "type": "boolean", "default": true }
      }
    }
  }
}
''';
