import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SmartYat'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Enhance your crew.'**
  String get appSlogan;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @changeUser.
  ///
  /// In en, this message translates to:
  /// **'Change user'**
  String get changeUser;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @setupYacht.
  ///
  /// In en, this message translates to:
  /// **'Set up yacht'**
  String get setupYacht;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequired;

  /// No description provided for @pinMustBe4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly 4 digits'**
  String get pinMustBe4Digits;

  /// No description provided for @pinsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDontMatch;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get wrongPin;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @loginWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Login with biometrics'**
  String get loginWithBiometrics;

  /// No description provided for @changePinRequired.
  ///
  /// In en, this message translates to:
  /// **'You must change your PIN before continuing'**
  String get changePinRequired;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @activeTasks.
  ///
  /// In en, this message translates to:
  /// **'Active tasks'**
  String get activeTasks;

  /// No description provided for @openIncidents.
  ///
  /// In en, this message translates to:
  /// **'Open incidents'**
  String get openIncidents;

  /// No description provided for @certificateAlerts.
  ///
  /// In en, this message translates to:
  /// **'Certificate alerts'**
  String get certificateAlerts;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low / out of stock'**
  String get lowStock;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get upcomingEvents;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to...'**
  String get assignTo;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection (required)'**
  String get rejectReason;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @taskHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get taskHistory;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get myTasks;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompleted;

  /// No description provided for @taskRejected.
  ///
  /// In en, this message translates to:
  /// **'Task rejected'**
  String get taskRejected;

  /// No description provided for @taskPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskPending;

  /// No description provided for @taskAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get taskAssigned;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @newChecklist.
  ///
  /// In en, this message translates to:
  /// **'New checklist'**
  String get newChecklist;

  /// No description provided for @checklistType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get checklistType;

  /// No description provided for @checklistEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get checklistEvent;

  /// No description provided for @checklistDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get checklistDaily;

  /// No description provided for @checklistWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get checklistWeekly;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed (48h)'**
  String get filterCompleted;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @crew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crew;

  /// No description provided for @addCrewMember.
  ///
  /// In en, this message translates to:
  /// **'Add crew member'**
  String get addCrewMember;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get firstName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @departmentDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get departmentDeck;

  /// No description provided for @departmentInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get departmentInterior;

  /// No description provided for @departmentCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get departmentCook;

  /// No description provided for @departmentEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get departmentEngine;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDate;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @editCrewMember.
  ///
  /// In en, this message translates to:
  /// **'Edit crew member'**
  String get editCrewMember;

  /// No description provided for @deleteCrewMember.
  ///
  /// In en, this message translates to:
  /// **'Delete crew member'**
  String get deleteCrewMember;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This action cannot be undone.'**
  String deleteConfirmation(String name);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @yachtCertificates.
  ///
  /// In en, this message translates to:
  /// **'Yacht'**
  String get yachtCertificates;

  /// No description provided for @crewCertificates.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewCertificates;

  /// No description provided for @addCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add certificate'**
  String get addCertificate;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @certificateName.
  ///
  /// In en, this message translates to:
  /// **'Certificate name'**
  String get certificateName;

  /// No description provided for @searchOrTypeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Search or type certificate name...'**
  String get searchOrTypeCertificate;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issueDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get expired;

  /// No description provided for @searchCertificates.
  ///
  /// In en, this message translates to:
  /// **'Search certificates...'**
  String get searchCertificates;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @minimumLevel.
  ///
  /// In en, this message translates to:
  /// **'Minimum level'**
  String get minimumLevel;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingList;

  /// No description provided for @markAsBought.
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get markAsBought;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStockAlert;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @incidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get incidents;

  /// No description provided for @newIncident.
  ///
  /// In en, this message translates to:
  /// **'New incident'**
  String get newIncident;

  /// No description provided for @openIncident.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openIncident;

  /// No description provided for @assignedIncident.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedIncident;

  /// No description provided for @inProgressIncident.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgressIncident;

  /// No description provided for @resolvedIncident.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedIncident;

  /// No description provided for @heyYat.
  ///
  /// In en, this message translates to:
  /// **'HEY YAT'**
  String get heyYat;

  /// No description provided for @heyYatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Intelligent voice assistant'**
  String get heyYatSubtitle;

  /// No description provided for @heyYatListening.
  ///
  /// In en, this message translates to:
  /// **'LISTENING...'**
  String get heyYatListening;

  /// No description provided for @heyYatClassifying.
  ///
  /// In en, this message translates to:
  /// **'CLASSIFYING...'**
  String get heyYatClassifying;

  /// No description provided for @heyYatConfirmed.
  ///
  /// In en, this message translates to:
  /// **'REGISTERED!'**
  String get heyYatConfirmed;

  /// No description provided for @heyYatPendingMessages.
  ///
  /// In en, this message translates to:
  /// **'{count} pending message(s)'**
  String heyYatPendingMessages(int count);

  /// No description provided for @heyYatProcessingOffline.
  ///
  /// In en, this message translates to:
  /// **'Processing offline messages...'**
  String get heyYatProcessingOffline;

  /// No description provided for @heyYatTypeManually.
  ///
  /// In en, this message translates to:
  /// **'Type manually'**
  String get heyYatTypeManually;

  /// No description provided for @heyYatHideKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Hide keyboard'**
  String get heyYatHideKeyboard;

  /// No description provided for @heyYatSavedInSystem.
  ///
  /// In en, this message translates to:
  /// **'Saved in the system'**
  String get heyYatSavedInSystem;

  /// No description provided for @heyYatSpeakNow.
  ///
  /// In en, this message translates to:
  /// **'Speak now...'**
  String get heyYatSpeakNow;

  /// No description provided for @heyYatSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get heyYatSendMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @yachtName.
  ///
  /// In en, this message translates to:
  /// **'Yacht name'**
  String get yachtName;

  /// No description provided for @adminEmail.
  ///
  /// In en, this message translates to:
  /// **'Administrator email'**
  String get adminEmail;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection · Offline mode'**
  String get offlineBanner;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count} pending to sync'**
  String syncPending(int count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @reassignTask.
  ///
  /// In en, this message translates to:
  /// **'Reassign task'**
  String get reassignTask;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @activeIncidents.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE INCIDENTS'**
  String get activeIncidents;

  /// No description provided for @urgentCertificates.
  ///
  /// In en, this message translates to:
  /// **'URGENT CERTIFICATES'**
  String get urgentCertificates;

  /// No description provided for @noStock.
  ///
  /// In en, this message translates to:
  /// **'NO STOCK'**
  String get noStock;

  /// No description provided for @recentTasks.
  ///
  /// In en, this message translates to:
  /// **'RECENT TASKS'**
  String get recentTasks;

  /// No description provided for @noActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this category'**
  String get noActiveTasks;

  /// No description provided for @noRejectedTasks.
  ///
  /// In en, this message translates to:
  /// **'No rejected tasks'**
  String get noRejectedTasks;

  /// No description provided for @noCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks'**
  String get noCompletedTasks;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchHistory;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTime;

  /// No description provided for @pinFirstAccess.
  ///
  /// In en, this message translates to:
  /// **'First access. For security, you must change your PIN.'**
  String get pinFirstAccess;

  /// No description provided for @introduceNewPin.
  ///
  /// In en, this message translates to:
  /// **'ENTER NEW PIN'**
  String get introduceNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM NEW PIN'**
  String get confirmNewPin;

  /// No description provided for @pinRepeatToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Repeat PIN to confirm'**
  String get pinRepeatToConfirm;

  /// No description provided for @pinNotZeros.
  ///
  /// In en, this message translates to:
  /// **'PIN cannot be 0000'**
  String get pinNotZeros;

  /// No description provided for @pinNoMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get pinNoMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
