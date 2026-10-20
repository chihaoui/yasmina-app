import '../lecteur/contrat_moteur.dart';
import 'choix/gabarit_choix.dart';
import 'choix/gabarit_comparer.dart';
import 'choix/gabarit_haraka.dart';
import 'choix/gabarit_justification.dart';
import 'choix/gabarit_vrai_faux.dart';
import 'glisser/gabarit_affectation.dart';
import 'glisser/gabarit_ordre.dart';
import 'glisser/gabarit_racine_scheme.dart';
import 'jeux/gabarit_flashcards.dart';
import 'jeux/gabarit_memory.dart';
import 'jeux/gabarit_mots_meles.dart';
import 'manipulables/gabarit_blocs.dart';
import 'manipulables/gabarit_cadre_dix.dart';
import 'manipulables/gabarit_droite_numerique.dart';
import 'manipulables/gabarit_fractions.dart';
import 'manipulables/gabarit_modele_barres.dart';
import 'manipulables/gabarit_monnaie.dart';
import 'saisie/gabarit_calcul_pose.dart';
import 'saisie/gabarit_saisie_numerique.dart';
import 'scene/gabarit_ecoute_colorie.dart';
import 'scene/gabarit_ecoute_place.dart';
import 'scene/gabarit_etiquetage.dart';
import 'scene/gabarit_hot_spot.dart';
import 'texte/gabarit_dictee.dart';
import 'texte/gabarit_toucher_mots.dart';

/// Gabarits des types jouables, par id de type. Un type y entre quand son
/// moteur sait le jouer, et passe alors à « jouable » dans le registre.
const Map<String, GabaritReponse> gabaritsJouables = {
  // Moteur Choix.
  'T01': GabaritChoix('T01'),
  'T02': GabaritVraiFaux(),
  'T03': GabaritChoix('T03'),
  'T04': GabaritChoix('T04'),
  'T05': GabaritChoix('T05'),
  'T18': GabaritChoix('T18'),
  'T19': GabaritHaraka(),
  'T23': GabaritComparer(),
  'T24': GabaritChoix('T24'),
  'T45': GabaritChoix('T45'),
  'T46': GabaritJustification(),
  'T55': GabaritChoix('T55'),
  'T61': GabaritChoix('T61'),
  // Moteur Glisser-déposer.
  'T06': GabaritAffectation('T06'),
  'T09': GabaritAffectation('T09'),
  'T11': GabaritAffectation('T11'),
  'T12': GabaritAffectation('T12'),
  'T13': GabaritOrdre('T13'),
  'T14': GabaritOrdre('T14'),
  'T15': GabaritOrdre('T15'),
  'T16': GabaritOrdre('T16'),
  'T56': GabaritRacineScheme(),
  'T62': GabaritOrdre('T62'),
  // Moteur Manipulables (base et avancés).
  'T25': GabaritDroiteNumerique(),
  'T27': GabaritBlocs(),
  'T51': GabaritCadreDix(),
  'T26': GabaritMonnaie(),
  'T29': GabaritFractions(),
  'T52': GabaritModeleBarres(),
  // Moteur Texte.
  'T07': GabaritToucherMots(),
  'T17': GabaritDictee(),
  // Moteur Saisie numérique (base).
  'T22': GabaritSaisieNumerique(),
  'T48': GabaritCalculPose(),
  // Moteur Scène image (base et avec audio).
  'T08': GabaritHotSpot(),
  'T47': GabaritEtiquetage(),
  'T53': GabaritEcoutePlace(),
  'T54': GabaritEcouteColorie(),
  // Moteur Révision et jeux.
  'T36': GabaritFlashcards(),
  'T37': GabaritMemory(),
  'T38': GabaritMotsMeles(),
};

/// Gabarit du type [idType], `null` s'il n'est pas encore jouable.
GabaritReponse? gabaritPour(String idType) => gabaritsJouables[idType];
