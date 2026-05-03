// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SmartYat';

  @override
  String get appSlogan => 'Enhance your crew.';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get changeUser => 'Change user';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get setupYacht => 'Set up yacht';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get pinRequired => 'PIN is required';

  @override
  String get pinMustBe4Digits => 'PIN must be exactly 4 digits';

  @override
  String get pinsDontMatch => 'PINs do not match';

  @override
  String get wrongPin => 'Incorrect PIN';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get loginWithBiometrics => 'Login with biometrics';

  @override
  String get changePinRequired => 'You must change your PIN before continuing';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get activeTasks => 'Active tasks';

  @override
  String get openIncidents => 'Open incidents';

  @override
  String get certificateAlerts => 'Certificate alerts';

  @override
  String get lowStock => 'Low / out of stock';

  @override
  String get upcomingEvents => 'Upcoming events';

  @override
  String get tasks => 'Tasks';

  @override
  String get newTask => 'New task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get taskDescription => 'Description';

  @override
  String get priority => 'Priority';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get assignTo => 'Assign to...';

  @override
  String get instructions => 'Instructions';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReason => 'Reason for rejection (required)';

  @override
  String get reassign => 'Reassign';

  @override
  String get taskHistory => 'History';

  @override
  String get myTasks => 'My tasks';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get taskRejected => 'Task rejected';

  @override
  String get taskPending => 'Pending';

  @override
  String get taskAssigned => 'Assigned';

  @override
  String get checklist => 'Checklist';

  @override
  String get newChecklist => 'New checklist';

  @override
  String get checklistType => 'Type';

  @override
  String get checklistEvent => 'Event';

  @override
  String get checklistDaily => 'Daily';

  @override
  String get checklistWeekly => 'Weekly';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterCompleted => 'Completed (48h)';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get crew => 'Crew';

  @override
  String get addCrewMember => 'Add crew member';

  @override
  String get firstName => 'Full name';

  @override
  String get role => 'Role';

  @override
  String get department => 'Department';

  @override
  String get departmentDeck => 'Deck';

  @override
  String get departmentInterior => 'Interior';

  @override
  String get departmentCook => 'Cook';

  @override
  String get departmentEngine => 'Engine';

  @override
  String get expirationDate => 'Expiration date';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get editCrewMember => 'Edit crew member';

  @override
  String get deleteCrewMember => 'Delete crew member';

  @override
  String deleteConfirmation(String name) {
    return 'Delete $name? This action cannot be undone.';
  }

  @override
  String get saveChanges => 'Save changes';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get certificates => 'Certificates';

  @override
  String get yachtCertificates => 'Yacht';

  @override
  String get crewCertificates => 'Crew';

  @override
  String get addCertificate => 'Add certificate';

  @override
  String get scanDocument => 'Scan document';

  @override
  String get attachFile => 'Attach file';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get certificateName => 'Certificate name';

  @override
  String get searchOrTypeCertificate => 'Search or type certificate name...';

  @override
  String get issueDate => 'Issue date';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get expired => 'EXPIRED';

  @override
  String get searchCertificates => 'Search certificates...';

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get inventory => 'Inventory';

  @override
  String get addItem => 'Add item';

  @override
  String get itemName => 'Item name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get minimumLevel => 'Minimum level';

  @override
  String get shoppingList => 'Shopping list';

  @override
  String get markAsBought => 'Mark as bought';

  @override
  String get lowStockAlert => 'Low stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get incidents => 'Incidents';

  @override
  String get newIncident => 'New incident';

  @override
  String get openIncident => 'Open';

  @override
  String get assignedIncident => 'Assigned';

  @override
  String get inProgressIncident => 'In progress';

  @override
  String get resolvedIncident => 'Resolved';

  @override
  String get heyYat => 'HEY YAT';

  @override
  String get heyYatSubtitle => 'Intelligent voice assistant';

  @override
  String get heyYatListening => 'LISTENING...';

  @override
  String get heyYatClassifying => 'CLASSIFYING...';

  @override
  String get heyYatConfirmed => 'REGISTERED!';

  @override
  String heyYatPendingMessages(int count) {
    return '$count pending message(s)';
  }

  @override
  String get heyYatProcessingOffline => 'Processing offline messages...';

  @override
  String get heyYatTypeManually => 'Type manually';

  @override
  String get heyYatHideKeyboard => 'Hide keyboard';

  @override
  String get heyYatSavedInSystem => 'Saved in the system';

  @override
  String get heyYatSpeakNow => 'Speak now...';

  @override
  String get heyYatSendMessage => 'Send message';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get settings => 'Settings';

  @override
  String get yachtName => 'Yacht name';

  @override
  String get adminEmail => 'Administrator email';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get offlineBanner => 'No connection · Offline mode';

  @override
  String syncPending(int count) {
    return '$count pending to sync';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get viewAll => 'View all';

  @override
  String get seeAll => 'See all';

  @override
  String get create => 'Create';

  @override
  String get add => 'Add';

  @override
  String get assign => 'Assign';

  @override
  String get reassignTask => 'Reassign task';

  @override
  String get complete => 'Complete';

  @override
  String get resolve => 'Resolve';

  @override
  String get inProgress => 'In progress';

  @override
  String get moreOptions => 'More options';

  @override
  String get activeIncidents => 'ACTIVE INCIDENTS';

  @override
  String get urgentCertificates => 'URGENT CERTIFICATES';

  @override
  String get noStock => 'NO STOCK';

  @override
  String get recentTasks => 'RECENT TASKS';

  @override
  String get noActiveTasks => 'No tasks in this category';

  @override
  String get noRejectedTasks => 'No rejected tasks';

  @override
  String get noCompletedTasks => 'No completed tasks';

  @override
  String get searchHistory => 'Search history...';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get allTime => 'All';

  @override
  String get pinFirstAccess =>
      'First access. For security, you must change your PIN.';

  @override
  String get introduceNewPin => 'ENTER NEW PIN';

  @override
  String get confirmNewPin => 'CONFIRM NEW PIN';

  @override
  String get pinRepeatToConfirm => 'Repeat PIN to confirm';

  @override
  String get pinNotZeros => 'PIN cannot be 0000';

  @override
  String get pinNoMatch => 'PINs do not match. Try again.';
}
