import '../lecteur/contrat_moteur.dart';
import 'choix/gabarit_vrai_faux.dart';

/// Gabarits des types jouables, par id de type. Un type y entre quand son
/// moteur sait le jouer, et passe alors à « jouable » dans le registre.
const Map<String, GabaritReponse> gabaritsJouables = {
  // Moteur Choix.
  'T02': GabaritVraiFaux(),
};

/// Gabarit du type [idType], `null` s'il n'est pas encore jouable.
GabaritReponse? gabaritPour(String idType) => gabaritsJouables[idType];
