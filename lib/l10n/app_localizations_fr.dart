// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'SmartYat';

  @override
  String get appSlogan => 'Enhance your crew.';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get changeUser => 'Changer d\'utilisateur';

  @override
  String get register => 'S\'inscrire';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get setupYacht => 'Configurer le yacht';

  @override
  String get enterPin => 'Entrez votre code PIN';

  @override
  String get confirmPin => 'Confirmez le code PIN';

  @override
  String get newPin => 'Nouveau code PIN';

  @override
  String get pinRequired => 'Le code PIN est obligatoire';

  @override
  String get pinMustBe4Digits => 'Le code PIN doit avoir exactement 4 chiffres';

  @override
  String get pinsDontMatch => 'Les codes PIN ne correspondent pas';

  @override
  String get wrongPin => 'Code PIN incorrect';

  @override
  String get biometrics => 'Biométrie';

  @override
  String get loginWithBiometrics => 'Se connecter avec la biométrie';

  @override
  String get changePinRequired =>
      'Vous devez changer votre code PIN avant de continuer';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get activeTasks => 'Tâches actives';

  @override
  String get openIncidents => 'Incidents ouverts';

  @override
  String get certificateAlerts => 'Alertes certificats';

  @override
  String get lowStock => 'Stock bas / épuisé';

  @override
  String get upcomingEvents => 'Événements à venir';

  @override
  String get tasks => 'Tâches';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskDescription => 'Description';

  @override
  String get priority => 'Priorité';

  @override
  String get priorityHigh => 'Haute';

  @override
  String get priorityMedium => 'Moyenne';

  @override
  String get priorityLow => 'Basse';

  @override
  String get assignTo => 'Assigner à...';

  @override
  String get instructions => 'Instructions';

  @override
  String get markAsCompleted => 'Marquer comme terminée';

  @override
  String get reject => 'Rejeter';

  @override
  String get rejectReason => 'Motif du rejet (obligatoire)';

  @override
  String get reassign => 'Réassigner';

  @override
  String get taskHistory => 'Historique';

  @override
  String get myTasks => 'Mes tâches';

  @override
  String get taskCompleted => 'Tâche terminée';

  @override
  String get taskRejected => 'Tâche rejetée';

  @override
  String get taskPending => 'En attente';

  @override
  String get taskAssigned => 'Assignée';

  @override
  String get checklist => 'Liste de contrôle';

  @override
  String get newChecklist => 'Nouvelle liste';

  @override
  String get checklistType => 'Type';

  @override
  String get checklistEvent => 'Événement';

  @override
  String get checklistDaily => 'Quotidien';

  @override
  String get checklistWeekly => 'Hebdomadaire';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterPending => 'En attente';

  @override
  String get filterInProgress => 'En cours';

  @override
  String get filterCompleted => 'Terminées (48h)';

  @override
  String get filterRejected => 'Rejetées';

  @override
  String get crew => 'Équipage';

  @override
  String get addCrewMember => 'Ajouter un membre';

  @override
  String get firstName => 'Nom complet';

  @override
  String get role => 'Poste';

  @override
  String get department => 'Département';

  @override
  String get departmentDeck => 'Pont';

  @override
  String get departmentInterior => 'Intérieur';

  @override
  String get departmentCook => 'Cuisine';

  @override
  String get departmentEngine => 'Moteur';

  @override
  String get expirationDate => 'Date d\'expiration';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get editCrewMember => 'Modifier le membre';

  @override
  String get deleteCrewMember => 'Supprimer le membre';

  @override
  String deleteConfirmation(String name) {
    return 'Supprimer $name ? Cette action est irréversible.';
  }

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get resetPin => 'Réinitialiser le PIN';

  @override
  String get certificates => 'Certificats';

  @override
  String get yachtCertificates => 'Yacht';

  @override
  String get crewCertificates => 'Équipage';

  @override
  String get addCertificate => 'Ajouter un certificat';

  @override
  String get scanDocument => 'Scanner le document';

  @override
  String get attachFile => 'Joindre un fichier';

  @override
  String get uploadPhoto => 'Télécharger une photo';

  @override
  String get certificateName => 'Nom du certificat';

  @override
  String get searchOrTypeCertificate => 'Rechercher ou saisir le nom...';

  @override
  String get issueDate => 'Date d\'émission';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get expired => 'EXPIRÉ';

  @override
  String get searchCertificates => 'Rechercher des certificats...';

  @override
  String daysRemaining(int days) {
    return '$days jours restants';
  }

  @override
  String get inventory => 'Inventaire';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get itemName => 'Nom de l\'article';

  @override
  String get quantity => 'Quantité';

  @override
  String get unit => 'Unité';

  @override
  String get minimumLevel => 'Niveau minimum';

  @override
  String get shoppingList => 'Liste de courses';

  @override
  String get markAsBought => 'Marquer comme acheté';

  @override
  String get lowStockAlert => 'Stock bas';

  @override
  String get outOfStock => 'Épuisé';

  @override
  String get incidents => 'Incidents';

  @override
  String get newIncident => 'Nouvel incident';

  @override
  String get openIncident => 'Ouvert';

  @override
  String get assignedIncident => 'Assigné';

  @override
  String get inProgressIncident => 'En cours';

  @override
  String get resolvedIncident => 'Résolu';

  @override
  String get heyYat => 'HEY YAT';

  @override
  String get heyYatSubtitle => 'Assistant vocal intelligent';

  @override
  String get heyYatListening => 'ÉCOUTE EN COURS...';

  @override
  String get heyYatClassifying => 'CLASSIFICATION...';

  @override
  String get heyYatConfirmed => 'ENREGISTRÉ !';

  @override
  String heyYatPendingMessages(int count) {
    return '$count message(s) en attente';
  }

  @override
  String get heyYatProcessingOffline => 'Traitement des messages hors ligne...';

  @override
  String get heyYatTypeManually => 'Écrire manuellement';

  @override
  String get heyYatHideKeyboard => 'Masquer le clavier';

  @override
  String get heyYatSavedInSystem => 'Enregistré dans le système';

  @override
  String get heyYatSpeakNow => 'Parlez maintenant...';

  @override
  String get heyYatSendMessage => 'Envoyer le message';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get settings => 'Paramètres';

  @override
  String get yachtName => 'Nom du yacht';

  @override
  String get adminEmail => 'Email de l\'administrateur';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';

  @override
  String get offlineBanner => 'Hors ligne · Mode hors connexion';

  @override
  String syncPending(int count) {
    return '$count en attente de synchronisation';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get back => 'Retour';

  @override
  String get search => 'Rechercher';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get create => 'Créer';

  @override
  String get add => 'Ajouter';

  @override
  String get assign => 'Assigner';

  @override
  String get reassignTask => 'Réassigner la tâche';

  @override
  String get complete => 'Terminée';

  @override
  String get resolve => 'Résoudre';

  @override
  String get inProgress => 'En cours';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get activeIncidents => 'INCIDENTS ACTIFS';

  @override
  String get urgentCertificates => 'CERTIFICATS URGENTS';

  @override
  String get noStock => 'RUPTURE DE STOCK';

  @override
  String get recentTasks => 'TÂCHES RÉCENTES';

  @override
  String get noActiveTasks => 'Aucune tâche dans cette catégorie';

  @override
  String get noRejectedTasks => 'Aucune tâche rejetée';

  @override
  String get noCompletedTasks => 'Aucune tâche terminée';

  @override
  String get searchHistory => 'Rechercher dans l\'historique...';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get allTime => 'Tout';

  @override
  String get pinFirstAccess =>
      'Premier accès. Pour la sécurité, vous devez changer votre PIN.';

  @override
  String get introduceNewPin => 'ENTREZ LE NOUVEAU CODE PIN';

  @override
  String get confirmNewPin => 'CONFIRMEZ LE NOUVEAU CODE PIN';

  @override
  String get pinRepeatToConfirm => 'Répétez le PIN pour confirmer';

  @override
  String get pinNotZeros => 'Le PIN ne peut pas être 0000';

  @override
  String get pinNoMatch => 'Les PIN ne correspondent pas. Réessayez.';
}
