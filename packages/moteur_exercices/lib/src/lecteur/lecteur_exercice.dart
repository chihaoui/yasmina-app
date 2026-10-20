import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../composants/bandeau_feedback.dart';
import '../composants/bouton_icone.dart';
import '../composants/bouton_yasmina.dart';
import '../composants/yasmina_bulle.dart';
import '../langue_exercice.dart';
import '../moteurs/gabarits.dart';
import '../plateforme/services.dart';
import '../registre/registre_types.dart';
import '../theme/jetons_yasmina.g.dart';
import '../theme/mouvements_yasmina.dart';
import '../theme/theme_yasmina.dart';
import 'config_exercice.dart';
import 'contrat_moteur.dart';
import 'deroule_exercice.dart';
import 'evenements.dart';
import 'libelles_lecteur.dart';

/// Lecteur d'exercice générique : joue un exercice edu-content/1.0 avec le
/// gabarit de son type. Même code dans l'app, l'aperçu web et le
/// back-office (CLAUDE.md §4).
///
/// Il ne connaît ni la base, ni la navigation, ni les profils : il reçoit
/// une configuration et des services, et il émet des événements.
class LecteurExercice extends StatefulWidget {
  const LecteurExercice({
    super.key,
    required this.exercice,
    required this.config,
    required this.services,
    this.onEvenement,
    this.onContinuer,
    this.gabarit,
  });

  /// Exercice edu-content/1.0 déjà validé par l'hôte.
  final Map<String, dynamic> exercice;

  final ConfigExercice config;
  final ServicesExercice services;
  final ValueChanged<EvenementExercice>? onEvenement;

  /// Continuer, après la réussite ou l'explication.
  final VoidCallback? onContinuer;

  /// Gabarit à utiliser. Par défaut, celui du type de l'exercice.
  final GabaritReponse? gabarit;

  @override
  State<LecteurExercice> createState() => _LecteurExerciceState();
}

class _LecteurExerciceState extends State<LecteurExercice> {
  GabaritReponse? _gabarit;
  ControleurReponse? _controleur;
  StreamSubscription<bool>? _fins;
  StreamSubscription<DemandeAudio>? _demandesAudio;
  late DerouleExercice _deroule;
  Timer? _minuterieFaux;
  String? _derniereReponse;
  Object? _erreur;

  LibellesLecteur get _libelles =>
      LibellesLecteur.pour(widget.config.langue, widget.config.formeAdresse);

  bool get _apercu => widget.config.mode != ModeExercice.enfant;

  @override
  void initState() {
    super.initState();
    _demarrer();
  }

  @override
  void didUpdateWidget(LecteurExercice ancien) {
    super.didUpdateWidget(ancien);
    // Mode édition : l'exercice se recharge quand le JSON change.
    if (widget.config.mode == ModeExercice.edition &&
        jsonEncode(ancien.exercice) != jsonEncode(widget.exercice)) {
      _arreter();
      _demarrer();
    }
  }

  @override
  void dispose() {
    _arreter();
    super.dispose();
  }

  void _demarrer() {
    _erreur = null;
    _gabarit = widget.gabarit ?? gabaritPour('${widget.exercice['type']}');
    _deroule = DerouleExercice(
      validation: _gabarit?.validation ?? ModeValidation.verifier,
      mode: widget.config.mode,
    );
    try {
      _controleur = _gabarit?.creerControleur(widget.exercice, widget.config)
        ?..addListener(_reponseChangee);
    } on Object catch (e) {
      _erreur = e;
      _controleur = null;
    }
    // Un changement d'état sans réponse (élément en attente) n'émet rien.
    _derniereReponse = jsonEncode(_controleur?.reponse);
    _fins = _controleur?.fins.listen(_finAutomatique);
    _demandesAudio = _controleur?.demandesAudio.listen(_direPourLaZone);
    if (_controleur case final controleur?) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        // La consigne, puis le mot à écouter du type (sans couper la
        // consigne : le service enchaîne).
        await _lireConsigne();
        if (!mounted || _controleur != controleur) return;
        if (controleur.ecouteOuverture case final texte?) {
          controleur.demanderAudio(texte, langue: widget.config.langue);
        }
      });
    }
  }

  void _arreter() {
    _minuterieFaux?.cancel();
    _fins?.cancel();
    _demandesAudio?.cancel();
    _controleur
      ?..removeListener(_reponseChangee)
      ..dispose();
    _controleur = null;
  }

  void _emettre(Iterable<EvenementExercice> evenements) {
    for (final e in evenements) {
      widget.onEvenement?.call(e);
    }
  }

  String _texte(Object? texte) =>
      texte == null ? '' : widget.config.formeAdresse.accorder(texte);

  String get _consigne =>
      _texte((widget.exercice['consigne'] as Map?)?['texte']);

  Future<void> _lireConsigne() {
    final langue = widget.config.langue;
    final dite = widget.services.audio.dire(_consigne, langue: langue);
    _emettre([
      DemandeAudio(_consigne, langue: langue, origine: OrigineAudio.consigne),
    ]);
    return dite;
  }

  void _direPourLaZone(DemandeAudio demande) {
    widget.services.audio.dire(demande.texte, langue: demande.langue);
    _emettre([demande]);
  }

  void _reponseChangee() {
    final controleur = _controleur!;
    final reponse = jsonEncode(controleur.reponse);
    if (controleur.modifiable && reponse != _derniereReponse) {
      _derniereReponse = reponse;
      _emettre([ReponseDonnee(controleur.reponse)]);
    }
    setState(() {});
  }

  void _verifier() {
    final controleur = _controleur!;
    final juste = controleur.corriger();
    _emettre(_deroule.verifier(juste: juste));
    _jouerSonDuFeedback();
    switch (_deroule.phase) {
      case PhaseExercice.reussi:
        controleur.montrer(AffichageReponse.juste);
      case PhaseExercice.explique:
        controleur.montrer(AffichageReponse.revelee);
      case PhaseExercice.indice:
        // Les choix faux restent marqués un instant, puis la sélection est
        // vidée pour le nouvel essai (l'indice reste affiché).
        controleur.montrer(AffichageReponse.faux);
        _minuterieFaux = Timer(MouvementsYasmina.dureeFaux, () {
          if (!mounted || _controleur != controleur) return;
          _retirerFauxSansEvenement(controleur);
        });
      case PhaseExercice.saisie || PhaseExercice.termine:
        break;
    }
    setState(() {});
  }

  void _finAutomatique(bool juste) {
    _emettre(_deroule.finAutomatique(juste: juste));
    _jouerSonDuFeedback();
    _controleur?.montrer(
      juste ? AffichageReponse.juste : AffichageReponse.revelee,
    );
    setState(() {});
  }

  /// Son d'interface de chaque temps du feedback : juste, essai faux
  /// (doux), réponse révélée. Le service le coupe si les sons des effets
  /// sont désactivés ou l'appareil en silencieux.
  void _jouerSonDuFeedback() {
    final son = switch (_deroule.feedback) {
      TempsFeedback.validation => SonInterface.juste,
      TempsFeedback.indice => SonInterface.essaiFaux,
      TempsFeedback.explication => SonInterface.revelee,
      null => null,
    };
    if (son != null) widget.services.audio.jouerSon(son);
  }

  void _continuer() {
    if (_deroule.validation == ModeValidation.sansNote &&
        !_deroule.estTermine) {
      _emettre(_deroule.terminerSansNote());
      // Type non noté : la zone est verrouillée telle quelle (aucune
      // réponse après le résultat), sans jugement affiché.
      _controleur?.montrer(AffichageReponse.juste);
      setState(() {});
    }
    widget.onContinuer?.call();
  }

  void _rejouer() {
    _minuterieFaux?.cancel();
    _deroule.rejouer();
    if (_controleur case final controleur?) _viderSansEvenement(controleur);
    setState(() {});
  }

  /// Vide la réponse et rend la main à l'enfant. Ce vidage vient du
  /// lecteur, pas de l'enfant : aucun reponseDonnee.
  void _viderSansEvenement(ControleurReponse controleur) {
    controleur.vider();
    _derniereReponse = jsonEncode(controleur.reponse);
    controleur.montrer(AffichageReponse.saisie);
  }

  /// Après le 1er essai faux : retire ce qui est faux, sans reponseDonnee.
  void _retirerFauxSansEvenement(ControleurReponse controleur) {
    controleur.retirerFaux();
    _derniereReponse = jsonEncode(controleur.reponse);
    controleur.montrer(AffichageReponse.saisie);
  }

  void _afficherReponse(bool afficher) {
    _controleur?.montrer(
      afficher ? AffichageReponse.revelee : AffichageReponse.saisie,
    );
    setState(() {});
  }

  HumeurYasmina get _humeur => switch (_deroule.phase) {
    PhaseExercice.reussi => HumeurYasmina.bravo,
    PhaseExercice.indice || PhaseExercice.explique => HumeurYasmina.encourage,
    PhaseExercice.saisie || PhaseExercice.termine => HumeurYasmina.neutre,
  };

  @override
  Widget build(BuildContext context) {
    return LangueExercice(
      langue: widget.config.langue,
      child: PorteurServices(
        services: widget.services,
        child: Builder(builder: _contenu),
      ),
    );
  }

  Widget _contenu(BuildContext context) {
    final c = context.couleurs;
    final arabe = widget.config.langue == 'ar';
    final controleur = _controleur;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_apercu)
          _BarreApercu(
            reponseAffichee: controleur?.affichage == AffichageReponse.revelee,
            onAfficherReponse: controleur == null ? null : _afficherReponse,
            onRejouer: controleur == null ? null : _rejouer,
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            EspacesYasmina.space5,
            EspacesYasmina.space4,
            EspacesYasmina.space5,
            EspacesYasmina.space2,
          ),
          child: Row(
            children: [
              Yasmina(humeur: _humeur, taille: TaillesYasmina.yasminaReader),
              const SizedBox(width: EspacesYasmina.space3),
              Expanded(
                child: Text(
                  _consigne,
                  key: const ValueKey('lecteur_consigne'),
                  style:
                      (arabe ? StylesYasmina.prompt : StylesYasmina.latinPrompt)
                          .copyWith(color: c.ink),
                ),
              ),
              const SizedBox(width: EspacesYasmina.space2),
              BoutonIcone(
                key: const ValueKey('lecteur_reecoute'),
                icone: Icons.volume_up_rounded,
                libelle: _libelles.ecouter,
                rond: true,
                onPressed: controleur == null ? null : _lireConsigne,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(EspacesYasmina.space5),
            child: controleur == null
                ? Text(
                    _erreur == null
                        ? 'Type ${widget.exercice['type']} pas encore jouable.'
                        : 'Exercice illisible : $_erreur',
                    key: const ValueKey('lecteur_erreur'),
                    style: ThemeYasmina.pourLangue(
                      StylesYasmina.latinBody,
                      'fr',
                    ).copyWith(color: c.coralText),
                  )
                : _gabarit!.construire(context, controleur),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(EspacesYasmina.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: EspacesYasmina.space3,
            children: [
              if (_deroule.feedback case final temps?)
                BandeauFeedback(
                  key: ValueKey('lecteur_feedback_${temps.name}'),
                  variante: switch (temps) {
                    TempsFeedback.validation => VarianteFeedback.validation,
                    TempsFeedback.indice => VarianteFeedback.indice,
                    TempsFeedback.explication => VarianteFeedback.explication,
                  },
                  libelle: switch (temps) {
                    TempsFeedback.validation => _libelles.validation,
                    TempsFeedback.indice => _libelles.indice,
                    TempsFeedback.explication => _libelles.explication,
                  },
                  texte: _texte(
                    (widget.exercice['feedbacks'] as Map?)?[switch (temps) {
                      TempsFeedback.validation => 'reussite',
                      TempsFeedback.indice => 'indice',
                      TempsFeedback.explication => 'explication',
                    }],
                  ),
                ),
              ?_boutonPrincipal(controleur),
            ],
          ),
        ),
      ],
    );
  }

  /// Vérifier (actif si la réponse est complète), puis Continuer. Aucun
  /// bouton en mode automatique tant que la zone n'a pas fini.
  Widget? _boutonPrincipal(ControleurReponse? controleur) {
    const cle = ValueKey('lecteur_bouton');
    if (_deroule.estTermine) {
      return BoutonYasmina(
        key: cle,
        libelle: _libelles.continuer,
        variante: VarianteBouton.vert,
        onPressed: _continuer,
      );
    }
    final complete = controleur != null && controleur.complete;
    return switch (_deroule.validation) {
      ModeValidation.automatique => null,
      ModeValidation.sansNote => BoutonYasmina(
        key: cle,
        libelle: _libelles.continuer,
        variante: VarianteBouton.vert,
        onPressed: complete ? _continuer : null,
      ),
      ModeValidation.verifier => BoutonYasmina(
        key: cle,
        libelle: _libelles.verifier,
        onPressed: complete && controleur.modifiable ? _verifier : null,
      ),
    };
  }
}

/// Outils de l'aperçu et de l'édition (adulte, back-office), en français,
/// au-dessus de l'écran de l'enfant.
class _BarreApercu extends StatelessWidget {
  const _BarreApercu({
    required this.reponseAffichee,
    required this.onAfficherReponse,
    required this.onRejouer,
  });

  final bool reponseAffichee;
  final ValueChanged<bool>? onAfficherReponse;
  final VoidCallback? onRejouer;

  @override
  Widget build(BuildContext context) {
    final c = context.couleurs;
    final style = ThemeYasmina.pourLangue(
      StylesYasmina.latinLabel,
      'fr',
    ).copyWith(color: c.ink);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            bottom: BorderSide(color: c.line, width: TraitsYasmina.borderThin),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: EspacesYasmina.space4,
          ),
          child: Row(
            children: [
              // Souple : le cadre de l'aperçu fait 360 px.
              Flexible(child: Text('Afficher la réponse', style: style)),
              Switch(
                key: const ValueKey('lecteur_afficher_reponse'),
                value: reponseAffichee,
                onChanged: onAfficherReponse,
              ),
              const Spacer(),
              TextButton.icon(
                key: const ValueKey('lecteur_rejouer'),
                icon: const Icon(Icons.replay_rounded),
                label: Text('Rejouer', style: style),
                onPressed: onRejouer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
