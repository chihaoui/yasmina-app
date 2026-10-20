import '../lecteur/contrat_moteur.dart';
import 'choix/gabarit_choix.dart';
import 'choix/gabarit_comparer.dart';
import 'choix/gabarit_haraka.dart';
import 'choix/gabarit_justification.dart';
import 'choix/gabarit_vrai_faux.dart';

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
};

/// Gabarit du type [idType], `null` s'il n'est pas encore jouable.
GabaritReponse? gabaritPour(String idType) => gabaritsJouables[idType];
