import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Spendroo'**
  String get appName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get haveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Try again.'**
  String get googleSignInFailed;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your money and your shop, in one app.'**
  String get tagline;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get verifyEmailTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {email}. Enter it below.'**
  String codeSentTo(String email);

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send the code again'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get codeResent;

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a code.'**
  String get resetPasswordHint;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get setNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Log in with the new one.'**
  String get passwordChanged;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Try again when you are online.'**
  String get offlineError;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use Spendroo?'**
  String get welcomeTitle;

  /// No description provided for @forMyself.
  ///
  /// In en, this message translates to:
  /// **'For myself'**
  String get forMyself;

  /// No description provided for @forMyselfHint.
  ///
  /// In en, this message translates to:
  /// **'Track accounts, spending and budgets.'**
  String get forMyselfHint;

  /// No description provided for @forMyBusiness.
  ///
  /// In en, this message translates to:
  /// **'For my business'**
  String get forMyBusiness;

  /// No description provided for @forMyBusinessHint.
  ///
  /// In en, this message translates to:
  /// **'Keep a cashbook for a shop or business.'**
  String get forMyBusinessHint;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try a demo business'**
  String get tryDemo;

  /// No description provided for @tryDemoHint.
  ///
  /// In en, this message translates to:
  /// **'A sample shop with a few weeks of entries.'**
  String get tryDemoHint;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @createBusiness.
  ///
  /// In en, this message translates to:
  /// **'Create business'**
  String get createBusiness;

  /// No description provided for @needsConnection.
  ///
  /// In en, this message translates to:
  /// **'This needs an internet connection.'**
  String get needsConnection;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

  /// No description provided for @switchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace'**
  String get switchWorkspace;

  /// No description provided for @newBusiness.
  ///
  /// In en, this message translates to:
  /// **'New business'**
  String get newBusiness;

  /// No description provided for @deleteWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Delete this business'**
  String get deleteWorkspace;

  /// No description provided for @deleteWorkspaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this business and all its cashbooks?'**
  String get deleteWorkspaceConfirm;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @cashbooks.
  ///
  /// In en, this message translates to:
  /// **'Cashbooks'**
  String get cashbooks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get spendingByCategory;

  /// No description provided for @noSpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No spending this month yet.'**
  String get noSpendingYet;

  /// No description provided for @uncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get uncategorised;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Add your first one.'**
  String get noTransactions;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get amountInvalid;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this?'**
  String get deleteConfirm;

  /// No description provided for @sameAccountError.
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get sameAccountError;

  /// No description provided for @currencyMismatch.
  ///
  /// In en, this message translates to:
  /// **'Both accounts must use the same currency'**
  String get currencyMismatch;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @accountKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountKind;

  /// No description provided for @kindCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get kindCash;

  /// No description provided for @kindBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get kindBank;

  /// No description provided for @kindSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get kindSavings;

  /// No description provided for @kindMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get kindMobileMoney;

  /// No description provided for @kindCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get kindCard;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get defaultCurrency;

  /// No description provided for @defaultCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'New accounts, cashbooks and budgets start in it, and totals are shown in it. What you already have keeps its own.'**
  String get defaultCurrencyHint;

  /// No description provided for @currencyFixedHint.
  ///
  /// In en, this message translates to:
  /// **'The currency cannot be changed after this is created.'**
  String get currencyFixedHint;

  /// No description provided for @keypadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get keypadClear;

  /// No description provided for @keypadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Delete last'**
  String get keypadBackspace;

  /// No description provided for @keypadDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get keypadDone;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudget;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet. Set a monthly limit for a category.'**
  String get noBudgets;

  /// No description provided for @spentOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String spentOf(String spent, String limit);

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @addCashbook.
  ///
  /// In en, this message translates to:
  /// **'Add cashbook'**
  String get addCashbook;

  /// No description provided for @cashbookName.
  ///
  /// In en, this message translates to:
  /// **'Cashbook name'**
  String get cashbookName;

  /// No description provided for @noCashbooks.
  ///
  /// In en, this message translates to:
  /// **'No cashbooks yet. Add one to start recording cash.'**
  String get noCashbooks;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @cashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash in'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get cashOut;

  /// No description provided for @totalIn.
  ///
  /// In en, this message translates to:
  /// **'Total in'**
  String get totalIn;

  /// No description provided for @totalOut.
  ///
  /// In en, this message translates to:
  /// **'Total out'**
  String get totalOut;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Use Cash in or Cash out below.'**
  String get noEntries;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @newPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'New payment method'**
  String get newPaymentMethod;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @byPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'By payment method'**
  String get byPaymentMethod;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries} =1{1 entry} other{{count} entries}}'**
  String entriesCount(int count);

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'You can view this cashbook but not change it.'**
  String get readOnly;

  /// No description provided for @addOnly.
  ///
  /// In en, this message translates to:
  /// **'You can add entries to this cashbook but not change them.'**
  String get addOnly;

  /// No description provided for @whoHasAccess.
  ///
  /// In en, this message translates to:
  /// **'Who has access'**
  String get whoHasAccess;

  /// No description provided for @accessIntro.
  ///
  /// In en, this message translates to:
  /// **'Owners, admins and viewers see every cashbook. Choose what each staff member may do in this one.'**
  String get accessIntro;

  /// No description provided for @noStaff.
  ///
  /// In en, this message translates to:
  /// **'No staff yet. People who join this business as staff appear here.'**
  String get noStaff;

  /// No description provided for @accessNone.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get accessNone;

  /// No description provided for @accessNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t see this cashbook'**
  String get accessNoneHint;

  /// No description provided for @accessView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get accessView;

  /// No description provided for @accessViewHint.
  ///
  /// In en, this message translates to:
  /// **'Sees the entries but can\'t change anything'**
  String get accessViewHint;

  /// No description provided for @accessAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get accessAdd;

  /// No description provided for @accessAddHint.
  ///
  /// In en, this message translates to:
  /// **'Adds entries but can\'t change or delete them'**
  String get accessAddHint;

  /// No description provided for @accessEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accessEdit;

  /// No description provided for @accessEditHint.
  ///
  /// In en, this message translates to:
  /// **'Adds, changes and deletes entries'**
  String get accessEditHint;

  /// No description provided for @accessManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get accessManage;

  /// No description provided for @accessManageHint.
  ///
  /// In en, this message translates to:
  /// **'Also categories, payment methods and who has access'**
  String get accessManageHint;

  /// No description provided for @accessRefused.
  ///
  /// In en, this message translates to:
  /// **'You can\'t make that change.'**
  String get accessRefused;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @allSynced.
  ///
  /// In en, this message translates to:
  /// **'Everything is saved to the cloud'**
  String get allSynced;

  /// No description provided for @pendingChanges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String pendingChanges(int count);

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes are kept on this device and sync later.'**
  String get offlineStatus;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync problem: {message}'**
  String syncError(String message);

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get notSynced;

  /// No description provided for @notSyncedHint.
  ///
  /// In en, this message translates to:
  /// **'The server refused these changes and they were undone on this device.'**
  String get notSyncedHint;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out? Data on this device is removed; everything already synced stays in your account.'**
  String get logOutConfirm;

  /// No description provided for @logOutUnsynced.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change has not synced and will be lost.} other{{count} changes have not synced and will be lost.}}'**
  String logOutUnsynced(int count);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @budgetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Budget this month'**
  String get budgetThisMonth;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @dailyAllowance.
  ///
  /// In en, this message translates to:
  /// **'Daily allowance'**
  String get dailyAllowance;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} a day'**
  String perDay(String amount);

  /// No description provided for @thisMonthOnly.
  ///
  /// In en, this message translates to:
  /// **'This month only'**
  String get thisMonthOnly;

  /// No description provided for @thisMonthOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Other months keep the usual limit.'**
  String get thisMonthOnlyHint;

  /// No description provided for @usualLimit.
  ///
  /// In en, this message translates to:
  /// **'Usual limit: {amount}'**
  String usualLimit(String amount);

  /// No description provided for @useUsualLimit.
  ///
  /// In en, this message translates to:
  /// **'Use usual limit'**
  String get useUsualLimit;

  /// No description provided for @noTransactionsOnDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded on this day.'**
  String get noTransactionsOnDay;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get noCategories;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @automaticColour.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automaticColour;

  /// No description provided for @customColour.
  ///
  /// In en, this message translates to:
  /// **'Custom colour'**
  String get customColour;

  /// No description provided for @colourHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get colourHue;

  /// No description provided for @colourShade.
  ///
  /// In en, this message translates to:
  /// **'Shade'**
  String get colourShade;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? {count, plural, =0{Its budgets are removed.} =1{1 transaction stays, without a category, and its budgets are removed.} other{{count} transactions stay, without a category, and its budgets are removed.}}'**
  String deleteCategoryConfirm(String name, int count);

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @netRemaining.
  ///
  /// In en, this message translates to:
  /// **'Net remaining balance'**
  String get netRemaining;

  /// No description provided for @lastMonthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last month} other{Last {count} months}}'**
  String lastMonthsCount(int count);

  /// No description provided for @monthsShort.
  ///
  /// In en, this message translates to:
  /// **'{count}M'**
  String monthsShort(String count);

  /// No description provided for @trendLength.
  ///
  /// In en, this message translates to:
  /// **'Months shown'**
  String get trendLength;

  /// No description provided for @showingLatestMonths.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest {months} months. Earlier ones come with an upgrade.'**
  String showingLatestMonths(String months);

  /// No description provided for @changeVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs last month'**
  String changeVsLastMonth(String percent);

  /// No description provided for @newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New this month'**
  String get newThisMonth;

  /// No description provided for @changeVsPeriodBefore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs the period before'**
  String changeVsPeriodBefore(String percent);

  /// No description provided for @newThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'New this period'**
  String get newThisPeriod;

  /// No description provided for @accountBalances.
  ///
  /// In en, this message translates to:
  /// **'Account balances'**
  String get accountBalances;

  /// No description provided for @shareOfTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Percentages show each account’s share of the total balance.'**
  String get shareOfTotalBalance;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverHint.
  ///
  /// In en, this message translates to:
  /// **'Address of the Spendroo API this test build talks to.'**
  String get serverHint;

  /// No description provided for @serverChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch server? You will be logged out and data on this device is removed.'**
  String get serverChangeConfirm;

  /// No description provided for @serverInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an address starting with http:// or https://'**
  String get serverInvalid;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what works and what does not.'**
  String get sendFeedbackHint;

  /// No description provided for @needsConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'This needs an internet connection. Try again when you are online.'**
  String get needsConnectionRetry;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search by merchant, note, tag or amount'**
  String get searchTransactions;

  /// No description provided for @searchOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Search or type a new name'**
  String get searchOrCreate;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String noResultsFor(String query);

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches.'**
  String get noMatches;

  /// No description provided for @createNamed.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String createNamed(String name);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @paceLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to spend'**
  String paceLeft(String amount);

  /// No description provided for @paceOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String paceOver(String amount);

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get emailOrUsername;

  /// No description provided for @enterEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get enterEmailOrUsername;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from your current one'**
  String get passwordSameAsCurrent;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get setPassword;

  /// No description provided for @setPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'You signed in with Google. Set a password to also log in with your email or username.'**
  String get setPasswordHint;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileHint.
  ///
  /// In en, this message translates to:
  /// **'Photo, username and password'**
  String get profileHint;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get profileDetails;

  /// No description provided for @signInAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Sign-in and security'**
  String get signInAndSecurity;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get bio;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'You can log in with it instead of your email.'**
  String get usernameHint;

  /// No description provided for @usernameChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get usernameChecking;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Already taken'**
  String get usernameTaken;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers and . _ + - only'**
  String get usernameInvalid;

  /// No description provided for @usernameYours.
  ///
  /// In en, this message translates to:
  /// **'This is your username'**
  String get usernameYours;

  /// No description provided for @usernameSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Free ones like it:'**
  String get usernameSuggestions;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get changeUsername;

  /// No description provided for @usernameChanged.
  ///
  /// In en, this message translates to:
  /// **'Username changed.'**
  String get usernameChanged;

  /// No description provided for @confirmWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm this change.'**
  String get confirmWithPassword;

  /// No description provided for @confirmChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmChange;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @cropPhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop photo'**
  String get cropPhoto;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get photoUpdated;

  /// No description provided for @photoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get photoRemoved;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @planYours.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planYours;

  /// No description provided for @planUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String planUntil(String date);

  /// No description provided for @planGraceNote.
  ///
  /// In en, this message translates to:
  /// **'Your payment is late. The plan stays on for a few more days.'**
  String get planGraceNote;

  /// No description provided for @planSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get planSeePlans;

  /// No description provided for @planUsage.
  ///
  /// In en, this message translates to:
  /// **'What you are using'**
  String get planUsage;

  /// No description provided for @planCountOf.
  ///
  /// In en, this message translates to:
  /// **'{count} of {limit}'**
  String planCountOf(int count, int limit);

  /// No description provided for @planUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get planUnlimited;

  /// No description provided for @planResetsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts again on {date}'**
  String planResetsOn(String date);

  /// No description provided for @planRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem a code'**
  String get planRedeem;

  /// No description provided for @planRedeemHint.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code? Enter it here.'**
  String get planRedeemHint;

  /// No description provided for @planCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Code applied. You are on the {plan} plan.'**
  String planCodeApplied(String plan);

  /// No description provided for @planThrottled.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a while and try again.'**
  String get planThrottled;

  /// No description provided for @planUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Get more from Spendroo'**
  String get planUpgradeTitle;

  /// No description provided for @planBuySoon.
  ///
  /// In en, this message translates to:
  /// **'Buying a plan in the app is coming soon. If you have a code, use it below.'**
  String get planBuySoon;

  /// No description provided for @planSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate purchase (test build)'**
  String get planSimulate;

  /// No description provided for @planSimulateExpire.
  ///
  /// In en, this message translates to:
  /// **'End my plan now (test build)'**
  String get planSimulateExpire;

  /// No description provided for @planLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the plans. Check your connection.'**
  String get planLoadFailed;

  /// No description provided for @planOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get planOffers;

  /// No description provided for @planUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get planUpgrade;

  /// No description provided for @planEverythingIn.
  ///
  /// In en, this message translates to:
  /// **'Everything in {plan}, and:'**
  String planEverythingIn(String plan);

  /// No description provided for @limitAccounts.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =1{1 account} other{{limit} accounts}}.'**
  String limitAccounts(String plan, int limit);

  /// No description provided for @limitCategories.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =1{1 category} other{{limit} categories}} of your own.'**
  String limitCategories(String plan, int limit);

  /// No description provided for @limitCashbooks.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =1{1 cashbook} other{{limit} cashbooks}} in a business.'**
  String limitCashbooks(String plan, int limit);

  /// No description provided for @limitWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =0{no business} =1{1 business} other{{limit} businesses}}.'**
  String limitWorkspaces(String plan, int limit);

  /// No description provided for @limitGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan does not allow more of this.'**
  String limitGeneric(String plan);

  /// No description provided for @limitFeature.
  ///
  /// In en, this message translates to:
  /// **'{feature} is not part of your {plan} plan.'**
  String limitFeature(String feature, String plan);

  /// No description provided for @limitLocked.
  ///
  /// In en, this message translates to:
  /// **'This is read-only on your {plan} plan. Upgrade, or choose what to keep.'**
  String limitLocked(String plan);

  /// No description provided for @limitQuota.
  ///
  /// In en, this message translates to:
  /// **'This month\'s allowance is used up: {feature}.'**
  String limitQuota(String feature);

  /// No description provided for @featureAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get featureAccounts;

  /// No description provided for @featureCustomCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories of your own'**
  String get featureCustomCategories;

  /// No description provided for @featureBudgetMonthOverride.
  ///
  /// In en, this message translates to:
  /// **'A different budget for one month'**
  String get featureBudgetMonthOverride;

  /// No description provided for @featureInsightsCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Insights for any dates'**
  String get featureInsightsCustomRange;

  /// No description provided for @featureYearReview.
  ///
  /// In en, this message translates to:
  /// **'Year in review'**
  String get featureYearReview;

  /// No description provided for @featureTrendMonths.
  ///
  /// In en, this message translates to:
  /// **'Months of trends'**
  String get featureTrendMonths;

  /// No description provided for @featureRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions and reminders'**
  String get featureRecurring;

  /// No description provided for @featureSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get featureSavingsGoals;

  /// No description provided for @featureHomeWidget.
  ///
  /// In en, this message translates to:
  /// **'Home screen widget'**
  String get featureHomeWidget;

  /// No description provided for @featureBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get featureBusinesses;

  /// No description provided for @featureCashbooks.
  ///
  /// In en, this message translates to:
  /// **'Cashbooks in a business'**
  String get featureCashbooks;

  /// No description provided for @featureTeamSeats.
  ///
  /// In en, this message translates to:
  /// **'Team members'**
  String get featureTeamSeats;

  /// No description provided for @featureReportRange.
  ///
  /// In en, this message translates to:
  /// **'Custom reports: any dates, types and categories'**
  String get featureReportRange;

  /// No description provided for @featureReportExport.
  ///
  /// In en, this message translates to:
  /// **'Reports as Excel'**
  String get featureReportExport;

  /// No description provided for @featureAuditTrail.
  ///
  /// In en, this message translates to:
  /// **'History of every change'**
  String get featureAuditTrail;

  /// No description provided for @featureCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom fields on entries'**
  String get featureCustomFields;

  /// No description provided for @featureStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage for bills and receipts'**
  String get featureStorage;

  /// No description provided for @featureAiCredits.
  ///
  /// In en, this message translates to:
  /// **'AI credits a month'**
  String get featureAiCredits;

  /// No description provided for @featurePdfPages.
  ///
  /// In en, this message translates to:
  /// **'Statement pages read a month'**
  String get featurePdfPages;

  /// No description provided for @featureDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get featureDevices;

  /// No description provided for @featureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get featureNoAds;

  /// No description provided for @keepTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what to keep'**
  String get keepTitle;

  /// No description provided for @keepIntro.
  ///
  /// In en, this message translates to:
  /// **'Your plan now allows fewer than you have. Choose the ones to go on editing. The rest stay safe and readable; nothing is deleted.'**
  String get keepIntro;

  /// No description provided for @keepChosen.
  ///
  /// In en, this message translates to:
  /// **'{chosen} of {limit} chosen'**
  String keepChosen(int chosen, int limit);

  /// No description provided for @keepSave.
  ///
  /// In en, this message translates to:
  /// **'Keep these'**
  String get keepSave;

  /// No description provided for @keepSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. The others are read-only.'**
  String get keepSaved;

  /// No description provided for @keepChangeFrom.
  ///
  /// In en, this message translates to:
  /// **'You can change this again from {date}.'**
  String keepChangeFrom(String date);

  /// No description provided for @keepPendingNote.
  ///
  /// In en, this message translates to:
  /// **'Until you choose, the oldest ones stay editable.'**
  String get keepPendingNote;

  /// No description provided for @keepOnceNote.
  ///
  /// In en, this message translates to:
  /// **'Choose with care: after saving, this cannot be changed for a while.'**
  String get keepOnceNote;

  /// No description provided for @keepNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing is locked. Everything you have fits your plan.'**
  String get keepNothing;

  /// No description provided for @keepIn.
  ///
  /// In en, this message translates to:
  /// **'{feature} in {workspace}'**
  String keepIn(String feature, String workspace);

  /// No description provided for @keepLockedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item is read-only} other{{count} items are read-only}}'**
  String keepLockedCount(int count);

  /// No description provided for @keepOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to change this.'**
  String get keepOffline;

  /// No description provided for @defaultTag.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultTag;

  /// No description provided for @customCount.
  ///
  /// In en, this message translates to:
  /// **'Your own: {count} of {limit}'**
  String customCount(int count, int limit);

  /// No description provided for @offerEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String offerEnds(String date);

  /// No description provided for @offerClaim.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get offerClaim;

  /// No description provided for @offerClaimed.
  ///
  /// In en, this message translates to:
  /// **'It is yours now. Enjoy!'**
  String get offerClaimed;

  /// No description provided for @offerActive.
  ///
  /// In en, this message translates to:
  /// **'On for you'**
  String get offerActive;

  /// No description provided for @lockedTag.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedTag;

  /// No description provided for @spendInsightTop.
  ///
  /// In en, this message translates to:
  /// **'{name} takes {percent}% of what you spent.'**
  String spendInsightTop(String name, String percent);

  /// No description provided for @spendInsightRise.
  ///
  /// In en, this message translates to:
  /// **'{name} is up {percent}% on last month.'**
  String spendInsightRise(String name, String percent);

  /// No description provided for @spendInsightRisePeriod.
  ///
  /// In en, this message translates to:
  /// **'{name} is up {percent}% on the period before.'**
  String spendInsightRisePeriod(String name, String percent);

  /// No description provided for @spendTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a category for details'**
  String get spendTapHint;

  /// No description provided for @shareOfSpending.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of spending'**
  String shareOfSpending(String percent);

  /// No description provided for @statAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statAverage;

  /// No description provided for @statLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get statLargest;

  /// No description provided for @moreCategories.
  ///
  /// In en, this message translates to:
  /// **'{count} more'**
  String moreCategories(String count);

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodLast3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get periodLast3Months;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @chooseDates.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get chooseDates;

  /// No description provided for @backToMonths.
  ///
  /// In en, this message translates to:
  /// **'Back to months'**
  String get backToMonths;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @transfersIn.
  ///
  /// In en, this message translates to:
  /// **'Transfers in'**
  String get transfersIn;

  /// No description provided for @transfersOut.
  ///
  /// In en, this message translates to:
  /// **'Transfers out'**
  String get transfersOut;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'To {account}'**
  String transferTo(String account);

  /// No description provided for @transferFrom.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String transferFrom(String account);

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get closingBalance;

  /// No description provided for @balanceOverTime.
  ///
  /// In en, this message translates to:
  /// **'Balance over time'**
  String get balanceOverTime;

  /// No description provided for @cashInAndOut.
  ///
  /// In en, this message translates to:
  /// **'Cash in and out'**
  String get cashInAndOut;

  /// No description provided for @whereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get whereItWent;

  /// No description provided for @whereItCameFrom.
  ///
  /// In en, this message translates to:
  /// **'Where it came from'**
  String get whereItCameFrom;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per day'**
  String get averagePerDay;

  /// No description provided for @largestExpense.
  ///
  /// In en, this message translates to:
  /// **'Largest expense'**
  String get largestExpense;

  /// No description provided for @accountGone.
  ///
  /// In en, this message translates to:
  /// **'This account is no longer here.'**
  String get accountGone;

  /// No description provided for @nothingInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period.'**
  String get nothingInPeriod;

  /// No description provided for @inAndOutDetails.
  ///
  /// In en, this message translates to:
  /// **'In and out, in detail'**
  String get inAndOutDetails;

  /// No description provided for @reportDownload.
  ///
  /// In en, this message translates to:
  /// **'Download report'**
  String get reportDownload;

  /// No description provided for @reportTitlePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal report'**
  String get reportTitlePersonal;

  /// No description provided for @reportTitleAccount.
  ///
  /// In en, this message translates to:
  /// **'Account statement'**
  String get reportTitleAccount;

  /// No description provided for @reportTitleCashbook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook report'**
  String get reportTitleCashbook;

  /// No description provided for @reportTitleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business report'**
  String get reportTitleBusiness;

  /// No description provided for @reportCoversPersonal.
  ///
  /// In en, this message translates to:
  /// **'All your personal accounts together.'**
  String get reportCoversPersonal;

  /// No description provided for @reportCoversAccount.
  ///
  /// In en, this message translates to:
  /// **'Only the account {name}.'**
  String reportCoversAccount(String name);

  /// No description provided for @reportCoversCashbook.
  ///
  /// In en, this message translates to:
  /// **'Only the cashbook {name}.'**
  String reportCoversCashbook(String name);

  /// No description provided for @reportCoversBusiness.
  ///
  /// In en, this message translates to:
  /// **'Every cashbook of {name} together.'**
  String reportCoversBusiness(String name);

  /// No description provided for @reportInside.
  ///
  /// In en, this message translates to:
  /// **'What\'s inside'**
  String get reportInside;

  /// No description provided for @reportInsidePersonal1.
  ///
  /// In en, this message translates to:
  /// **'Opening and closing balance of every account'**
  String get reportInsidePersonal1;

  /// No description provided for @reportInsidePersonal2.
  ///
  /// In en, this message translates to:
  /// **'Income and spending by category'**
  String get reportInsidePersonal2;

  /// No description provided for @reportInsidePersonal3.
  ///
  /// In en, this message translates to:
  /// **'Every transaction, with transfers listed on their own'**
  String get reportInsidePersonal3;

  /// No description provided for @reportInsideAccount1.
  ///
  /// In en, this message translates to:
  /// **'Opening and closing balance'**
  String get reportInsideAccount1;

  /// No description provided for @reportInsideAccount2.
  ///
  /// In en, this message translates to:
  /// **'Spending and income by category'**
  String get reportInsideAccount2;

  /// No description provided for @reportInsideAccount3.
  ///
  /// In en, this message translates to:
  /// **'Every transaction, with the balance after it'**
  String get reportInsideAccount3;

  /// No description provided for @reportInsideCashbook1.
  ///
  /// In en, this message translates to:
  /// **'Opening and closing balance'**
  String get reportInsideCashbook1;

  /// No description provided for @reportInsideCashbook2.
  ///
  /// In en, this message translates to:
  /// **'Totals by category and by payment method'**
  String get reportInsideCashbook2;

  /// No description provided for @reportInsideCashbook3.
  ///
  /// In en, this message translates to:
  /// **'Every entry, with the balance after it'**
  String get reportInsideCashbook3;

  /// No description provided for @reportInsideBusiness1.
  ///
  /// In en, this message translates to:
  /// **'Your cashbooks side by side'**
  String get reportInsideBusiness1;

  /// No description provided for @reportInsideBusiness2.
  ///
  /// In en, this message translates to:
  /// **'Totals by category and by payment method'**
  String get reportInsideBusiness2;

  /// No description provided for @reportInsideBusiness3.
  ///
  /// In en, this message translates to:
  /// **'Every entry of every cashbook'**
  String get reportInsideBusiness3;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get reportPeriod;

  /// No description provided for @reportFileType.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get reportFileType;

  /// No description provided for @reportPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Ready to read, print or share'**
  String get reportPdfHint;

  /// No description provided for @reportExcelHint.
  ///
  /// In en, this message translates to:
  /// **'A spreadsheet you can sort and add up'**
  String get reportExcelHint;

  /// No description provided for @reportFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get reportFree;

  /// No description provided for @reportPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid plan'**
  String get reportPaid;

  /// No description provided for @reportDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get reportDownloadPdf;

  /// No description provided for @reportDownloadExcel.
  ///
  /// In en, this message translates to:
  /// **'Download Excel'**
  String get reportDownloadExcel;

  /// No description provided for @reportHint.
  ///
  /// In en, this message translates to:
  /// **'Made online from everything you have saved.'**
  String get reportHint;

  /// No description provided for @reportOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to download a report.'**
  String get reportOffline;

  /// No description provided for @reportTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This period has too many lines for one file (up to {limit}). Choose a shorter period.'**
  String reportTooLarge(int limit);

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be made. Try again.'**
  String get reportFailed;

  /// No description provided for @reportThrottled.
  ///
  /// In en, this message translates to:
  /// **'Too many downloads. Try again in a little while.'**
  String get reportThrottled;

  /// No description provided for @reportReady.
  ///
  /// In en, this message translates to:
  /// **'Your report is ready'**
  String get reportReady;

  /// No description provided for @reportReference.
  ///
  /// In en, this message translates to:
  /// **'Reference {reference}'**
  String reportReference(String reference);

  /// No description provided for @reportOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get reportOpen;

  /// No description provided for @reportShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get reportShare;

  /// No description provided for @reportNoApp.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this file. Use Share or save.'**
  String get reportNoApp;

  /// No description provided for @reportAnother.
  ///
  /// In en, this message translates to:
  /// **'Download another'**
  String get reportAnother;

  /// No description provided for @reportCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom report'**
  String get reportCustomTitle;

  /// No description provided for @reportCustomDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get reportCustomDates;

  /// No description provided for @reportCustomTypes.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reportCustomTypes;

  /// No description provided for @reportCustomAllHint.
  ///
  /// In en, this message translates to:
  /// **'Choose none to include all.'**
  String get reportCustomAllHint;

  /// No description provided for @reportCustomNote.
  ///
  /// In en, this message translates to:
  /// **'A filtered report adds up only the lines that match. It shows money in, money out and the difference, without opening or closing balances.'**
  String get reportCustomNote;

  /// No description provided for @reportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved on your phone in {folder}'**
  String reportSavedTo(String folder);

  /// No description provided for @reportNotSaved.
  ///
  /// In en, this message translates to:
  /// **'This phone has no Downloads folder the app can save to. Use Share to keep a copy.'**
  String get reportNotSaved;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @savedPercent.
  ///
  /// In en, this message translates to:
  /// **'Saved {percent}%'**
  String savedPercent(String percent);

  /// No description provided for @spendingPace.
  ///
  /// In en, this message translates to:
  /// **'Spending pace'**
  String get spendingPace;

  /// No description provided for @spentSoFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String spentSoFar(String amount);

  /// No description provided for @paceLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than at this point the month before'**
  String paceLess(String amount);

  /// No description provided for @paceMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than at this point the month before'**
  String paceMore(String amount);

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @monthEndForecast.
  ///
  /// In en, this message translates to:
  /// **'By month end'**
  String get monthEndForecast;

  /// No description provided for @biggestDay.
  ///
  /// In en, this message translates to:
  /// **'Biggest day'**
  String get biggestDay;

  /// No description provided for @noSpendDays.
  ///
  /// In en, this message translates to:
  /// **'No-spend days'**
  String get noSpendDays;

  /// No description provided for @budgetEvenPace.
  ///
  /// In en, this message translates to:
  /// **'Budget, spread evenly'**
  String get budgetEvenPace;

  /// No description provided for @thatDay.
  ///
  /// In en, this message translates to:
  /// **'{amount} that day'**
  String thatDay(String amount);

  /// No description provided for @soFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} so far'**
  String soFar(String amount);

  /// No description provided for @tapDayHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see its transactions'**
  String get tapDayHint;

  /// No description provided for @budgetHealth.
  ///
  /// In en, this message translates to:
  /// **'Budget health'**
  String get budgetHealth;

  /// No description provided for @percentUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String percentUsed(String percent);

  /// No description provided for @usedLabel.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get usedLabel;

  /// No description provided for @safePerDay.
  ///
  /// In en, this message translates to:
  /// **'Safe per day'**
  String get safePerDay;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get daysLeft;

  /// No description provided for @keepsWithin.
  ///
  /// In en, this message translates to:
  /// **'{amount} a day keeps you within it'**
  String keepsWithin(String amount);

  /// No description provided for @keepsWithinBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} a day keeps you within budget this month'**
  String keepsWithinBudget(String amount);

  /// No description provided for @allBudgets.
  ///
  /// In en, this message translates to:
  /// **'All budgets'**
  String get allBudgets;

  /// No description provided for @spentShare.
  ///
  /// In en, this message translates to:
  /// **'Spent · {percent}%'**
  String spentShare(String percent);

  /// No description provided for @leftShare.
  ///
  /// In en, this message translates to:
  /// **'Left · {percent}%'**
  String leftShare(String percent);

  /// No description provided for @overShare.
  ///
  /// In en, this message translates to:
  /// **'Over · {percent}%'**
  String overShare(String percent);

  /// No description provided for @limitAmount.
  ///
  /// In en, this message translates to:
  /// **'Limit {amount}'**
  String limitAmount(String amount);

  /// No description provided for @verdictOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track. Spending is behind the calendar.'**
  String get verdictOnTrack;

  /// No description provided for @verdictAhead.
  ///
  /// In en, this message translates to:
  /// **'Spending is running ahead of the calendar.'**
  String get verdictAhead;

  /// No description provided for @verdictWithin.
  ///
  /// In en, this message translates to:
  /// **'You stayed within the budget.'**
  String get verdictWithin;

  /// No description provided for @legendWithin.
  ///
  /// In en, this message translates to:
  /// **'Within allowance'**
  String get legendWithin;

  /// No description provided for @legendNear.
  ///
  /// In en, this message translates to:
  /// **'A little over'**
  String get legendNear;

  /// No description provided for @legendOver.
  ///
  /// In en, this message translates to:
  /// **'Far over'**
  String get legendOver;

  /// No description provided for @notBudgeted.
  ///
  /// In en, this message translates to:
  /// **'No limit set'**
  String get notBudgeted;

  /// No description provided for @setLimit.
  ///
  /// In en, this message translates to:
  /// **'Set limit'**
  String get setLimit;

  /// No description provided for @dayByDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day'**
  String get dayByDay;

  /// No description provided for @seeTransactions.
  ///
  /// In en, this message translates to:
  /// **'See transactions'**
  String get seeTransactions;

  /// No description provided for @noTransactionsHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded here.'**
  String get noTransactionsHere;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get cashFlow;

  /// No description provided for @savedInMonths.
  ///
  /// In en, this message translates to:
  /// **'Income beat spending in {saved} of {months} months.'**
  String savedInMonths(String saved, String months);

  /// No description provided for @tapMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a month for details'**
  String get tapMonthHint;

  /// No description provided for @goToMonth.
  ///
  /// In en, this message translates to:
  /// **'Go to {month}'**
  String goToMonth(String month);

  /// No description provided for @keptOfIncome.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of income kept'**
  String keptOfIncome(String percent);

  /// No description provided for @spentMoreThanEarned.
  ///
  /// In en, this message translates to:
  /// **'Spent more than came in'**
  String get spentMoreThanEarned;

  /// No description provided for @splitTitle.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitTitle;

  /// No description provided for @splitAction.
  ///
  /// In en, this message translates to:
  /// **'Split into categories'**
  String get splitAction;

  /// No description provided for @splitRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove split'**
  String get splitRemove;

  /// No description provided for @splitAddPart.
  ///
  /// In en, this message translates to:
  /// **'Add a part'**
  String get splitAddPart;

  /// No description provided for @splitEvenly.
  ///
  /// In en, this message translates to:
  /// **'Share equally'**
  String get splitEvenly;

  /// No description provided for @splitDone.
  ///
  /// In en, this message translates to:
  /// **'All of it is filed'**
  String get splitDone;

  /// No description provided for @splitLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to file'**
  String splitLeft(String amount);

  /// No description provided for @splitOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than the amount'**
  String splitOver(String amount);

  /// No description provided for @splitMismatch.
  ///
  /// In en, this message translates to:
  /// **'The parts must add up to {amount}.'**
  String splitMismatch(String amount);

  /// No description provided for @splitNeedsAmounts.
  ///
  /// In en, this message translates to:
  /// **'Give every part an amount.'**
  String get splitNeedsAmounts;

  /// No description provided for @splitInParts.
  ///
  /// In en, this message translates to:
  /// **'Split in {count}'**
  String splitInParts(String count);

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @recurringEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing repeats yet. Rent, salary, a bill: set it once and it comes round by itself.'**
  String get recurringEmpty;

  /// No description provided for @newRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction'**
  String get newRecurring;

  /// No description provided for @newReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get newReminder;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring transaction'**
  String get editRecurring;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @repeatThis.
  ///
  /// In en, this message translates to:
  /// **'Make this repeat'**
  String get repeatThis;

  /// No description provided for @ruleTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ruleTitle;

  /// No description provided for @ruleTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Give it a title.'**
  String get ruleTitleRequired;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @freqOptOnce.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get freqOptOnce;

  /// No description provided for @freqOptDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqOptDaily;

  /// No description provided for @freqOptWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqOptWeekly;

  /// No description provided for @freqOptMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqOptMonthly;

  /// No description provided for @freqOptYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get freqOptYearly;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get repeatEvery;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @unitWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get unitWeeks;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get unitMonths;

  /// No description provided for @unitYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get unitYears;

  /// No description provided for @freqOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get freqOnce;

  /// No description provided for @freqDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get freqDaily;

  /// No description provided for @freqDailyN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String freqDailyN(String n);

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get freqWeekly;

  /// No description provided for @freqWeeklyN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} weeks'**
  String freqWeeklyN(String n);

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get freqMonthly;

  /// No description provided for @freqMonthlyN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} months'**
  String freqMonthlyN(String n);

  /// No description provided for @freqYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get freqYearly;

  /// No description provided for @freqYearlyN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} years'**
  String freqYearlyN(String n);

  /// No description provided for @monthlyOn.
  ///
  /// In en, this message translates to:
  /// **'Falls on'**
  String get monthlyOn;

  /// No description provided for @onDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String onDayOfMonth(String n);

  /// No description provided for @onLastDay.
  ///
  /// In en, this message translates to:
  /// **'The last day'**
  String get onLastDay;

  /// No description provided for @onWeekdayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'A weekday of the month'**
  String get onWeekdayOfMonth;

  /// No description provided for @theNthWeekday.
  ///
  /// In en, this message translates to:
  /// **'The {ordinal} {weekday}'**
  String theNthWeekday(String ordinal, String weekday);

  /// No description provided for @whichOne.
  ///
  /// In en, this message translates to:
  /// **'Which'**
  String get whichOne;

  /// No description provided for @weekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get weekday;

  /// No description provided for @ordinalFirst.
  ///
  /// In en, this message translates to:
  /// **'first'**
  String get ordinalFirst;

  /// No description provided for @ordinalSecond.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get ordinalSecond;

  /// No description provided for @ordinalThird.
  ///
  /// In en, this message translates to:
  /// **'third'**
  String get ordinalThird;

  /// No description provided for @ordinalFourth.
  ///
  /// In en, this message translates to:
  /// **'fourth'**
  String get ordinalFourth;

  /// No description provided for @ordinalLast.
  ///
  /// In en, this message translates to:
  /// **'last'**
  String get ordinalLast;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startsOn;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @endsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// No description provided for @endsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get endsOnDate;

  /// No description provided for @endsAfterTimes.
  ///
  /// In en, this message translates to:
  /// **'After a number of times'**
  String get endsAfterTimes;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get endsOn;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'How many times'**
  String get timesCount;

  /// No description provided for @numberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a number above zero.'**
  String get numberRequired;

  /// No description provided for @nextDates.
  ///
  /// In en, this message translates to:
  /// **'Next: {dates}'**
  String nextDates(String dates);

  /// No description provided for @noMoreDates.
  ///
  /// In en, this message translates to:
  /// **'No date falls on this schedule.'**
  String get noMoreDates;

  /// No description provided for @recordAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Record automatically'**
  String get recordAutomatically;

  /// No description provided for @recordAutomaticallyHint.
  ///
  /// In en, this message translates to:
  /// **'Without it you are asked first, and can change the amount.'**
  String get recordAutomaticallyHint;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindOnTheDay.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get remindOnTheDay;

  /// No description provided for @remindDayBefore.
  ///
  /// In en, this message translates to:
  /// **'The day before'**
  String get remindDayBefore;

  /// No description provided for @remindDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} days before'**
  String remindDaysBefore(String n);

  /// No description provided for @remindAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get remindAt;

  /// No description provided for @usualTime.
  ///
  /// In en, this message translates to:
  /// **'The usual time'**
  String get usualTime;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @pausedHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing falls due while it is paused.'**
  String get pausedHint;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @nextOn.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextOn(String date);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @waitingForYou.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get waitingForYou;

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @everythingThatRepeats.
  ///
  /// In en, this message translates to:
  /// **'Everything that repeats'**
  String get everythingThatRepeats;

  /// No description provided for @recordIt.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordIt;

  /// No description provided for @skipIt.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipIt;

  /// No description provided for @laterIt.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterIt;

  /// No description provided for @doneIt.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneIt;

  /// No description provided for @snoozeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get snoozeTomorrow;

  /// No description provided for @snoozeThreeDays.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get snoozeThreeDays;

  /// No description provided for @snoozeWeek.
  ///
  /// In en, this message translates to:
  /// **'In a week'**
  String get snoozeWeek;

  /// No description provided for @deleteRuleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this? What it has already recorded stays.'**
  String get deleteRuleConfirm;

  /// No description provided for @recordsItself.
  ///
  /// In en, this message translates to:
  /// **'Recorded automatically'**
  String get recordsItself;

  /// No description provided for @asksFirst.
  ///
  /// In en, this message translates to:
  /// **'Asks first'**
  String get asksFirst;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartsOn;

  /// No description provided for @splitKept.
  ///
  /// In en, this message translates to:
  /// **'Split in {count}, as in the transaction'**
  String splitKept(String count);

  /// No description provided for @featureReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get featureReminders;

  /// No description provided for @limitReminders.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =1{1 reminder} other{{limit} reminders}} at a time.'**
  String limitReminders(String plan, int limit);

  /// No description provided for @seeAllRecurring.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllRecurring;

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addRecurring;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get inbox;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to tell you yet. What falls due, what was recorded for you and how your budgets are doing will show up here.'**
  String get inboxEmpty;

  /// No description provided for @inboxEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get inboxEarlier;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @inboxUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{title} is due in {days} days'**
  String inboxUpcoming(String title, String days);

  /// No description provided for @inboxUpcomingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{title} is due tomorrow'**
  String inboxUpcomingTomorrow(String title);

  /// No description provided for @inboxDue.
  ///
  /// In en, this message translates to:
  /// **'{title} is due today'**
  String inboxDue(String title);

  /// No description provided for @inboxOverdue.
  ///
  /// In en, this message translates to:
  /// **'{title} is still waiting'**
  String inboxOverdue(String title);

  /// No description provided for @inboxPosted.
  ///
  /// In en, this message translates to:
  /// **'{title} was recorded'**
  String inboxPosted(String title);

  /// No description provided for @inboxIncomeComing.
  ///
  /// In en, this message translates to:
  /// **'{title} is expected in {days} days'**
  String inboxIncomeComing(String title, String days);

  /// No description provided for @inboxIncomeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{title} is expected tomorrow'**
  String inboxIncomeTomorrow(String title);

  /// No description provided for @inboxIncomeDue.
  ///
  /// In en, this message translates to:
  /// **'Has {title} come in?'**
  String inboxIncomeDue(String title);

  /// No description provided for @inboxBlocked.
  ///
  /// In en, this message translates to:
  /// **'{title} could not be recorded. Check its account.'**
  String inboxBlocked(String title);

  /// No description provided for @inboxBudget80.
  ///
  /// In en, this message translates to:
  /// **'{title}: {percent}% of the budget is spent'**
  String inboxBudget80(String title, String percent);

  /// No description provided for @inboxBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'{title} is over its budget'**
  String inboxBudgetOver(String title);

  /// No description provided for @inboxBudgetDetail.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String inboxBudgetDetail(String spent, String limit);

  /// No description provided for @untitledRule.
  ///
  /// In en, this message translates to:
  /// **'A recurring transaction'**
  String get untitledRule;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifAllow;

  /// No description provided for @notifBlocked.
  ///
  /// In en, this message translates to:
  /// **'This phone is not letting Spendroo show notifications.'**
  String get notifBlocked;

  /// No description provided for @notifBlockedHint.
  ///
  /// In en, this message translates to:
  /// **'If nothing happens, allow them for Spendroo in the phone\'s settings.'**
  String get notifBlockedHint;

  /// No description provided for @notifPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notifPush;

  /// No description provided for @notifPushHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders reach this phone even when the app is closed.'**
  String get notifPushHint;

  /// No description provided for @notifWhat.
  ///
  /// In en, this message translates to:
  /// **'What to tell you'**
  String get notifWhat;

  /// No description provided for @notifBills.
  ///
  /// In en, this message translates to:
  /// **'Bills and reminders'**
  String get notifBills;

  /// No description provided for @notifBillsHint.
  ///
  /// In en, this message translates to:
  /// **'Coming up, due today and still waiting'**
  String get notifBillsHint;

  /// No description provided for @notifIncome.
  ///
  /// In en, this message translates to:
  /// **'Expected income'**
  String get notifIncome;

  /// No description provided for @notifRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded for you'**
  String get notifRecorded;

  /// No description provided for @notifRecordedHint.
  ///
  /// In en, this message translates to:
  /// **'When a recurring transaction is recorded, or could not be'**
  String get notifRecordedHint;

  /// No description provided for @notifBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notifBudgets;

  /// No description provided for @notifBudgetsHint.
  ///
  /// In en, this message translates to:
  /// **'At 80% of a budget, and when it is passed'**
  String get notifBudgetsHint;

  /// No description provided for @notifNudge.
  ///
  /// In en, this message translates to:
  /// **'Daily nudge'**
  String get notifNudge;

  /// No description provided for @notifNudgeHint.
  ///
  /// In en, this message translates to:
  /// **'On days you have written nothing down'**
  String get notifNudgeHint;

  /// No description provided for @notifNudgeTime.
  ///
  /// In en, this message translates to:
  /// **'Nudge at'**
  String get notifNudgeTime;

  /// No description provided for @notifWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get notifWhen;

  /// No description provided for @notifReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get notifReminderTime;

  /// No description provided for @notifReminderTimeHint.
  ///
  /// In en, this message translates to:
  /// **'For recurring transactions without a time of their own.'**
  String get notifReminderTimeHint;

  /// No description provided for @notifQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notifQuiet;

  /// No description provided for @notifQuietHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent between these hours. It waits until they end.'**
  String get notifQuietHint;

  /// No description provided for @notifQuietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get notifQuietFrom;

  /// No description provided for @notifQuietTo.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get notifQuietTo;

  /// No description provided for @notifTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get notifTest;

  /// No description provided for @notifTestSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. It should arrive in a moment.'**
  String get notifTestSent;

  /// No description provided for @notifTestNoDevice.
  ///
  /// In en, this message translates to:
  /// **'This phone is not registered for notifications yet. Check the connection and try again.'**
  String get notifTestNoDevice;

  /// No description provided for @notifTestNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'The server is not set up to send notifications yet.'**
  String get notifTestNotSetUp;

  /// No description provided for @notifTestFailed.
  ///
  /// In en, this message translates to:
  /// **'It could not be sent. Try again in a while.'**
  String get notifTestFailed;

  /// No description provided for @nudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you spend anything today?'**
  String get nudgeTitle;

  /// No description provided for @nudgeBody.
  ///
  /// In en, this message translates to:
  /// **'Write it down while you remember.'**
  String get nudgeBody;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available to spend'**
  String get available;

  /// No description provided for @inGoals.
  ///
  /// In en, this message translates to:
  /// **'In goals'**
  String get inGoals;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get netWorth;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get goals;

  /// No description provided for @goalKind.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get goalKind;

  /// No description provided for @toGoal.
  ///
  /// In en, this message translates to:
  /// **'To goal: {goal}'**
  String toGoal(String goal);

  /// No description provided for @fromGoal.
  ///
  /// In en, this message translates to:
  /// **'From goal: {goal}'**
  String fromGoal(String goal);

  /// No description provided for @intoGoal.
  ///
  /// In en, this message translates to:
  /// **'Saves into goal'**
  String get intoGoal;

  /// No description provided for @limitGoals.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan allows {limit, plural, =1{1 savings goal} other{{limit} savings goals}} at a time. Archive one, or upgrade for more.'**
  String limitGoals(String plan, int limit);

  /// No description provided for @limitTrendMonths.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan charts {limit, plural, =1{the last month} other{the last {limit} months}}. Upgrade to look further back.'**
  String limitTrendMonths(String plan, int limit);

  /// No description provided for @notifGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get notifGoals;

  /// No description provided for @notifGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'Each quarter of the way, falling behind, and a month with nothing saved'**
  String get notifGoalsHint;

  /// No description provided for @goalTemplateEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get goalTemplateEmergency;

  /// No description provided for @goalTemplateGadget.
  ///
  /// In en, this message translates to:
  /// **'Gadget'**
  String get goalTemplateGadget;

  /// No description provided for @goalTemplateTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get goalTemplateTrip;

  /// No description provided for @goalTemplateFestival.
  ///
  /// In en, this message translates to:
  /// **'Eid & festivals'**
  String get goalTemplateFestival;

  /// No description provided for @goalTemplateEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get goalTemplateEducation;

  /// No description provided for @goalTemplateWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get goalTemplateWedding;

  /// No description provided for @goalTemplateVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get goalTemplateVehicle;

  /// No description provided for @goalTemplateHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get goalTemplateHome;

  /// No description provided for @goalTemplateGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get goalTemplateGift;

  /// No description provided for @goalTemplateCustom.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get goalTemplateCustom;

  /// No description provided for @goalOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalOnTrack;

  /// No description provided for @goalAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get goalAhead;

  /// No description provided for @goalBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get goalBehind;

  /// No description provided for @goalNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get goalNoDate;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get goalReached;

  /// No description provided for @goalNew.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalNew;

  /// No description provided for @goalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEdit;

  /// No description provided for @goalCreate.
  ///
  /// In en, this message translates to:
  /// **'Start saving'**
  String get goalCreate;

  /// No description provided for @goalWhatFor.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get goalWhatFor;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @goalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTarget;

  /// No description provided for @goalHasDate.
  ///
  /// In en, this message translates to:
  /// **'Set a target date'**
  String get goalHasDate;

  /// No description provided for @goalHasDateHint.
  ///
  /// In en, this message translates to:
  /// **'Goals with a date are reached more often: you see each month what it takes'**
  String get goalHasDateHint;

  /// No description provided for @goalTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Reach it by'**
  String get goalTargetDate;

  /// No description provided for @goalColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get goalColour;

  /// No description provided for @goalPreviewNoDate.
  ///
  /// In en, this message translates to:
  /// **'Add a date to see what it takes each month'**
  String get goalPreviewNoDate;

  /// No description provided for @goalPreviewPace.
  ///
  /// In en, this message translates to:
  /// **'≈ {month}/month · {week}/week · {day}/day'**
  String goalPreviewPace(String month, String week, String day);

  /// No description provided for @goalEmergencySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {amount}, three months of your spending'**
  String goalEmergencySuggestion(String amount);

  /// No description provided for @goalSavedOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String goalSavedOf(String saved, String target);

  /// No description provided for @goalOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String goalOfTarget(String target);

  /// No description provided for @goalToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String goalToGo(String amount);

  /// No description provided for @goalLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String goalLeft(String amount);

  /// No description provided for @goalBy.
  ///
  /// In en, this message translates to:
  /// **'by {date}'**
  String goalBy(String date);

  /// No description provided for @goalPerWeekNeeded.
  ///
  /// In en, this message translates to:
  /// **'{amount}/week needed'**
  String goalPerWeekNeeded(String amount);

  /// No description provided for @goalNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next: {mark}% · {amount} away'**
  String goalNextMilestone(String mark, String amount);

  /// No description provided for @goalDaysEarly.
  ///
  /// In en, this message translates to:
  /// **'{days} days ahead'**
  String goalDaysEarly(String days);

  /// No description provided for @goalDaysLate.
  ///
  /// In en, this message translates to:
  /// **'{days} days behind'**
  String goalDaysLate(String days);

  /// No description provided for @goalAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get goalAddMoney;

  /// No description provided for @goalAddMoneyTo.
  ///
  /// In en, this message translates to:
  /// **'Add money to {goal}'**
  String goalAddMoneyTo(String goal);

  /// No description provided for @goalWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get goalWithdraw;

  /// No description provided for @goalUseMoney.
  ///
  /// In en, this message translates to:
  /// **'Use the money'**
  String get goalUseMoney;

  /// No description provided for @goalKeepSaving.
  ///
  /// In en, this message translates to:
  /// **'Keep saving'**
  String get goalKeepSaving;

  /// No description provided for @goalAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto-save'**
  String get goalAutoSave;

  /// No description provided for @goalAutoSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save for {goal}'**
  String goalAutoSaveTitle(String goal);

  /// No description provided for @goalAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-saved'**
  String get goalAuto;

  /// No description provided for @goalRestore.
  ///
  /// In en, this message translates to:
  /// **'Bring back'**
  String get goalRestore;

  /// No description provided for @goalGone.
  ///
  /// In en, this message translates to:
  /// **'This goal no longer exists.'**
  String get goalGone;

  /// No description provided for @goalDeleteHasMoney.
  ///
  /// In en, this message translates to:
  /// **'Take the money out first, so none of it is lost from sight.'**
  String get goalDeleteHasMoney;

  /// No description provided for @goalDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {goal}? Its history goes with it.'**
  String goalDeleteConfirm(String goal);

  /// No description provided for @goalLockedNote.
  ///
  /// In en, this message translates to:
  /// **'Your plan keeps this goal read-only: nothing more goes in, but you can always take the money out.'**
  String get goalLockedNote;

  /// No description provided for @goalNoAccountInCurrency.
  ///
  /// In en, this message translates to:
  /// **'You have no account in {currency} to move money with.'**
  String goalNoAccountInCurrency(String currency);

  /// No description provided for @goalMoreThanBalance.
  ///
  /// In en, this message translates to:
  /// **'That is more than {account} holds; its balance goes below zero.'**
  String goalMoreThanBalance(String account);

  /// No description provided for @goalQuickNeeded.
  ///
  /// In en, this message translates to:
  /// **'This month\'s share'**
  String get goalQuickNeeded;

  /// No description provided for @goalQuickTenth.
  ///
  /// In en, this message translates to:
  /// **'10% of income'**
  String get goalQuickTenth;

  /// No description provided for @goalQuickRest.
  ///
  /// In en, this message translates to:
  /// **'All that\'s left'**
  String get goalQuickRest;

  /// No description provided for @goalEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get goalEnterAmount;

  /// No description provided for @goalTrajectory.
  ///
  /// In en, this message translates to:
  /// **'How it is going'**
  String get goalTrajectory;

  /// No description provided for @goalTargetLine.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get goalTargetLine;

  /// No description provided for @goalLegendSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get goalLegendSaved;

  /// No description provided for @goalLegendSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady pace'**
  String get goalLegendSteady;

  /// No description provided for @goalLegendForecast.
  ///
  /// In en, this message translates to:
  /// **'At your pace'**
  String get goalLegendForecast;

  /// No description provided for @goalLegendMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get goalLegendMilestone;

  /// No description provided for @goalPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get goalPace;

  /// No description provided for @goalNeededMonthly.
  ///
  /// In en, this message translates to:
  /// **'Needed / month'**
  String get goalNeededMonthly;

  /// No description provided for @goalYourAverage.
  ///
  /// In en, this message translates to:
  /// **'You average'**
  String get goalYourAverage;

  /// No description provided for @goalSoFar.
  ///
  /// In en, this message translates to:
  /// **'So far'**
  String get goalSoFar;

  /// No description provided for @goalPaceTooEarly.
  ///
  /// In en, this message translates to:
  /// **'After a month of saving, this shows when you\'ll get there.'**
  String get goalPaceTooEarly;

  /// No description provided for @goalForecast.
  ///
  /// In en, this message translates to:
  /// **'You\'ll finish'**
  String get goalForecast;

  /// No description provided for @goalPaceNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Once money goes in, this shows when you\'ll get there.'**
  String get goalPaceNothingYet;

  /// No description provided for @goalPaceEarly.
  ///
  /// In en, this message translates to:
  /// **'At your pace you get there around {date}, in time.'**
  String goalPaceEarly(String date);

  /// No description provided for @goalPaceLate.
  ///
  /// In en, this message translates to:
  /// **'At your pace you get there around {date}, after your date. {needed} a month makes it in time.'**
  String goalPaceLate(String date, String needed);

  /// No description provided for @goalPaceNoDate.
  ///
  /// In en, this message translates to:
  /// **'At {amount} a month you get there around {date}.'**
  String goalPaceNoDate(String amount, String date);

  /// No description provided for @goalWhatIf.
  ///
  /// In en, this message translates to:
  /// **'What if I saved…'**
  String get goalWhatIf;

  /// No description provided for @goalWhatIfResult.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month → done by {date}'**
  String goalWhatIfResult(String amount, String date);

  /// No description provided for @goalWhatIfNever.
  ///
  /// In en, this message translates to:
  /// **'Move the slider to see when you\'d get there.'**
  String get goalWhatIfNever;

  /// No description provided for @goalWhatIfAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Save this every month'**
  String get goalWhatIfAutoSave;

  /// No description provided for @goalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Month by month'**
  String get goalMonthly;

  /// No description provided for @goalStreak.
  ///
  /// In en, this message translates to:
  /// **'{months} months in a row'**
  String goalStreak(String months);

  /// No description provided for @goalMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get goalMilestones;

  /// No description provided for @goalSources.
  ///
  /// In en, this message translates to:
  /// **'Where it came from'**
  String get goalSources;

  /// No description provided for @goalHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get goalHistory;

  /// No description provided for @goalNoMoves.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. The first step is the biggest.'**
  String get goalNoMoves;

  /// No description provided for @goalMoveIn.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String goalMoveIn(String account);

  /// No description provided for @goalMoveOut.
  ///
  /// In en, this message translates to:
  /// **'To {account}'**
  String goalMoveOut(String account);

  /// No description provided for @goalUndoMove.
  ///
  /// In en, this message translates to:
  /// **'Take this back? Both sides of the transfer are deleted.'**
  String get goalUndoMove;

  /// No description provided for @goalHalfway.
  ///
  /// In en, this message translates to:
  /// **'Halfway to {goal}!'**
  String goalHalfway(String goal);

  /// No description provided for @goalMilestoneReached.
  ///
  /// In en, this message translates to:
  /// **'{mark}% of the way to {goal}!'**
  String goalMilestoneReached(String mark, String goal);

  /// No description provided for @goalReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReachedTitle;

  /// No description provided for @goalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You saved {amount} for {goal}.'**
  String goalReachedBody(String goal, String amount);

  /// No description provided for @goalReachedDays.
  ///
  /// In en, this message translates to:
  /// **'Days it took'**
  String get goalReachedDays;

  /// No description provided for @goalReachedTimes.
  ///
  /// In en, this message translates to:
  /// **'Times you saved'**
  String get goalReachedTimes;

  /// No description provided for @goalsSummary.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target} across {count} goals'**
  String goalsSummary(String saved, String target, String count);

  /// No description provided for @goalsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount} this month'**
  String goalsThisMonth(String amount);

  /// No description provided for @goalsSavingRate.
  ///
  /// In en, this message translates to:
  /// **'You save {percent}% of income'**
  String goalsSavingRate(String percent);

  /// No description provided for @goalsHeaderEmpty.
  ///
  /// In en, this message translates to:
  /// **'Money you set aside shows here.'**
  String get goalsHeaderEmpty;

  /// No description provided for @goalsReachedSection.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get goalsReachedSection;

  /// No description provided for @goalsArchivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived ({count})'**
  String goalsArchivedSection(String count);

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Give your money a job'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Set money aside for what matters. It leaves what you can spend, so you are not tempted, and it is yours to take back anytime.'**
  String get goalsEmptyBody;

  /// No description provided for @goalsHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How goals work'**
  String get goalsHowTitle;

  /// No description provided for @goalsHowSetAside.
  ///
  /// In en, this message translates to:
  /// **'Money is set aside'**
  String get goalsHowSetAside;

  /// No description provided for @goalsHowSetAsideBody.
  ///
  /// In en, this message translates to:
  /// **'Adding money moves it out of an account into the goal. It is no longer in \'Available to spend\', but it still counts in your net worth.'**
  String get goalsHowSetAsideBody;

  /// No description provided for @goalsHowDate.
  ///
  /// In en, this message translates to:
  /// **'A date makes it real'**
  String get goalsHowDate;

  /// No description provided for @goalsHowDateBody.
  ///
  /// In en, this message translates to:
  /// **'With a date you see what each month needs, and whether you are on track.'**
  String get goalsHowDateBody;

  /// No description provided for @goalsHowFirst.
  ///
  /// In en, this message translates to:
  /// **'Pay yourself first'**
  String get goalsHowFirst;

  /// No description provided for @goalsHowFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Saving right after payday, on a schedule, works better than saving what is left at the month\'s end.'**
  String get goalsHowFirstBody;

  /// No description provided for @goalsHowWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Yours, anytime'**
  String get goalsHowWithdraw;

  /// No description provided for @goalsHowWithdrawBody.
  ///
  /// In en, this message translates to:
  /// **'To spend goal money, take it out into an account first. It is never locked away, just one deliberate step further.'**
  String get goalsHowWithdrawBody;

  /// No description provided for @insightBehind.
  ///
  /// In en, this message translates to:
  /// **'{goal} is {amount} behind. Adding {perWeek} a week gets it back on track.'**
  String insightBehind(String goal, String amount, String perWeek);

  /// No description provided for @insightStreak.
  ///
  /// In en, this message translates to:
  /// **'You saved for {goal} {months} months in a row. Keep the streak going!'**
  String insightStreak(String months, String goal);

  /// No description provided for @insightCutBack.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} on {category} this month. Half of that would bring {goal} {count, plural, =1{a week} other{{weeks} weeks}} sooner.'**
  String insightCutBack(
    String category,
    String amount,
    String goal,
    int count,
    String weeks,
  );

  /// No description provided for @insightPayday.
  ///
  /// In en, this message translates to:
  /// **'You usually save for {goal} right after payday. Let it happen on its own every month?'**
  String insightPayday(String goal);

  /// No description provided for @insightBestMonth.
  ///
  /// In en, this message translates to:
  /// **'You moved {amount} into goals this month, your best month yet.'**
  String insightBestMonth(String amount);

  /// No description provided for @insightEmergency.
  ///
  /// In en, this message translates to:
  /// **'No emergency fund yet. Most advice says to keep three to six months of spending for the unexpected.'**
  String get insightEmergency;

  /// No description provided for @insightEmergencyAction.
  ///
  /// In en, this message translates to:
  /// **'Start one'**
  String get insightEmergencyAction;

  /// No description provided for @withdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Take money out of {goal}?'**
  String withdrawTitle(String goal);

  /// No description provided for @withdrawReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the money 🎉'**
  String get withdrawReachedTitle;

  /// No description provided for @withdrawFinishMoves.
  ///
  /// In en, this message translates to:
  /// **'Your finish date moves from {from} to {to}.'**
  String withdrawFinishMoves(String from, String to);

  /// No description provided for @withdrawSetsBack.
  ///
  /// In en, this message translates to:
  /// **'This sets your goal back by {amount}.'**
  String withdrawSetsBack(String amount);

  /// No description provided for @withdrawAll.
  ///
  /// In en, this message translates to:
  /// **'All of it: {amount}'**
  String withdrawAll(String amount);

  /// No description provided for @withdrawWhy.
  ///
  /// In en, this message translates to:
  /// **'Why? (optional)'**
  String get withdrawWhy;

  /// No description provided for @withdrawEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get withdrawEmergency;

  /// No description provided for @withdrawReached.
  ///
  /// In en, this message translates to:
  /// **'Reached my goal'**
  String get withdrawReached;

  /// No description provided for @withdrawChangedPlans.
  ///
  /// In en, this message translates to:
  /// **'Changed plans'**
  String get withdrawChangedPlans;

  /// No description provided for @withdrawOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get withdrawOther;

  /// No description provided for @withdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount}'**
  String withdrawConfirm(String amount);

  /// No description provided for @withdrawMove.
  ///
  /// In en, this message translates to:
  /// **'Move {amount} to the account'**
  String withdrawMove(String amount);

  /// No description provided for @withdrawTooMuch.
  ///
  /// In en, this message translates to:
  /// **'The goal holds {amount}.'**
  String withdrawTooMuch(String amount);

  /// No description provided for @withdrawNote.
  ///
  /// In en, this message translates to:
  /// **'You are {percent}% of the way. The money goes back as a transfer you can see in both places.'**
  String withdrawNote(String percent);

  /// No description provided for @inboxGoalMilestone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the way to {title}'**
  String inboxGoalMilestone(String percent, String title);

  /// No description provided for @inboxGoalReached.
  ///
  /// In en, this message translates to:
  /// **'You reached {title}!'**
  String inboxGoalReached(String title);

  /// No description provided for @inboxGoalBehind.
  ///
  /// In en, this message translates to:
  /// **'{title} is falling behind'**
  String inboxGoalBehind(String title);

  /// No description provided for @inboxGoalIdle.
  ///
  /// In en, this message translates to:
  /// **'Nothing put into {title} for {days} days'**
  String inboxGoalIdle(String title, String days);

  /// No description provided for @inboxGoalDetail.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target} saved'**
  String inboxGoalDetail(String saved, String target);

  /// No description provided for @inboxGoalNeeded.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month gets it back on track'**
  String inboxGoalNeeded(String amount);

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @goalsShort.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsShort;

  /// No description provided for @saveKind.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveKind;

  /// No description provided for @goalPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal'**
  String get goalPick;

  /// No description provided for @goalStartFirst.
  ///
  /// In en, this message translates to:
  /// **'Start your first goal'**
  String get goalStartFirst;

  /// No description provided for @goalNewShort.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get goalNewShort;

  /// No description provided for @goalsBehindCount.
  ///
  /// In en, this message translates to:
  /// **'{count} behind'**
  String goalsBehindCount(String count);

  /// No description provided for @goalsSavedTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved'**
  String goalsSavedTotal(String amount);

  /// No description provided for @goalsInviteBody.
  ///
  /// In en, this message translates to:
  /// **'Set money aside for something that matters. Tap to start a goal.'**
  String get goalsInviteBody;

  /// No description provided for @goalsKeptAside.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 goal, kept apart from what you spend} other{{count} goals, kept apart from what you spend}}'**
  String goalsKeptAside(int n, String count);

  /// No description provided for @goalsShareOfWorth.
  ///
  /// In en, this message translates to:
  /// **'{percent} of what you own is set aside for goals'**
  String goalsShareOfWorth(String percent);

  /// No description provided for @goalAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'This account is read-only on your plan. Choose another to save from.'**
  String get goalAccountLocked;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Year in review'**
  String get reviewTitle;

  /// No description provided for @reviewYearSoFar.
  ///
  /// In en, this message translates to:
  /// **'{year} so far'**
  String reviewYearSoFar(String year);

  /// No description provided for @reviewPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get reviewPreviousYear;

  /// No description provided for @reviewNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get reviewNextYear;

  /// No description provided for @reviewKept.
  ///
  /// In en, this message translates to:
  /// **'You kept'**
  String get reviewKept;

  /// No description provided for @reviewOverspent.
  ///
  /// In en, this message translates to:
  /// **'You spent more than came in by'**
  String get reviewOverspent;

  /// No description provided for @reviewRate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of what came in'**
  String reviewRate(String percent);

  /// No description provided for @reviewCameIn.
  ///
  /// In en, this message translates to:
  /// **'Came in'**
  String get reviewCameIn;

  /// No description provided for @reviewWentOut.
  ///
  /// In en, this message translates to:
  /// **'Went out'**
  String get reviewWentOut;

  /// No description provided for @reviewAgainst.
  ///
  /// In en, this message translates to:
  /// **'Against {year}'**
  String reviewAgainst(String year);

  /// No description provided for @reviewChangeOn.
  ///
  /// In en, this message translates to:
  /// **'{percent}% on {year}'**
  String reviewChangeOn(String percent, String year);

  /// No description provided for @reviewNothingBefore.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {year}'**
  String reviewNothingBefore(String year);

  /// No description provided for @reviewMonthByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month by month'**
  String get reviewMonthByMonth;

  /// No description provided for @reviewSpentMost.
  ///
  /// In en, this message translates to:
  /// **'Spent most'**
  String get reviewSpentMost;

  /// No description provided for @reviewSpentLeast.
  ///
  /// In en, this message translates to:
  /// **'Spent least'**
  String get reviewSpentLeast;

  /// No description provided for @reviewMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a month to open it.'**
  String get reviewMonthHint;

  /// No description provided for @reviewWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get reviewWhereItWent;

  /// No description provided for @reviewShareOfSpending.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of spending'**
  String reviewShareOfSpending(String percent);

  /// No description provided for @reviewMoreCategories.
  ///
  /// In en, this message translates to:
  /// **'{count} more categories: {amount}'**
  String reviewMoreCategories(String count, String amount);

  /// No description provided for @reviewHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get reviewHighlights;

  /// No description provided for @reviewBiggestExpense.
  ///
  /// In en, this message translates to:
  /// **'Biggest expense'**
  String get reviewBiggestExpense;

  /// No description provided for @reviewAverageMonth.
  ///
  /// In en, this message translates to:
  /// **'A month on average'**
  String get reviewAverageMonth;

  /// No description provided for @reviewBestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best month for saving'**
  String get reviewBestMonth;

  /// No description provided for @reviewKeptAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} kept'**
  String reviewKeptAmount(String amount);

  /// No description provided for @reviewMonthsInGreen.
  ///
  /// In en, this message translates to:
  /// **'Months in the green'**
  String get reviewMonthsInGreen;

  /// No description provided for @reviewMonthsOf.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String reviewMonthsOf(String count, String total);

  /// No description provided for @reviewGoalsReached.
  ///
  /// In en, this message translates to:
  /// **'Goals reached'**
  String get reviewGoalsReached;

  /// No description provided for @reviewShare.
  ///
  /// In en, this message translates to:
  /// **'Share your year'**
  String get reviewShare;

  /// No description provided for @reviewShareText.
  ///
  /// In en, this message translates to:
  /// **'My {year} with Spendroo'**
  String reviewShareText(String year);

  /// No description provided for @reviewShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the card. Try again.'**
  String get reviewShareFailed;

  /// No description provided for @reviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing was recorded in {year}. Add income and expenses and your year will build up here.'**
  String reviewEmpty(String year);

  /// No description provided for @reviewLocked.
  ///
  /// In en, this message translates to:
  /// **'Look back on a whole year: what came in, where it went, your best and worst months, and how it compares with the year before.'**
  String get reviewLocked;

  /// No description provided for @reviewTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your {year} in review'**
  String reviewTileTitle(String year);

  /// No description provided for @reviewTileBody.
  ///
  /// In en, this message translates to:
  /// **'Totals, top categories and your best months'**
  String get reviewTileBody;

  /// No description provided for @widgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get widgetAdd;

  /// No description provided for @widgetSafePace.
  ///
  /// In en, this message translates to:
  /// **'Safe {amount}/day'**
  String widgetSafePace(String amount);

  /// No description provided for @widgetAveragePace.
  ///
  /// In en, this message translates to:
  /// **'Avg {amount}/day'**
  String widgetAveragePace(String amount);

  /// No description provided for @widgetBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'Budget left'**
  String get widgetBudgetLeft;

  /// No description provided for @widgetUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'See your whole month here'**
  String get widgetUnlockTitle;

  /// No description provided for @widgetUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Today, budget left, what\'s left this month and a daily spending chart'**
  String get widgetUnlockBody;

  /// No description provided for @widgetUnlockCta.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Plus'**
  String get widgetUnlockCta;

  /// No description provided for @widgetSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Spendroo'**
  String get widgetSignInTitle;

  /// No description provided for @widgetSignInBody.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending will show here'**
  String get widgetSignInBody;

  /// No description provided for @widgetEmptyChart.
  ///
  /// In en, this message translates to:
  /// **'Nothing spent yet this month. Tap + to log an expense.'**
  String get widgetEmptyChart;

  /// No description provided for @widgetHideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get widgetHideAmounts;

  /// No description provided for @widgetShowAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get widgetShowAmounts;

  /// No description provided for @widgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String widgetUpdated(String time);

  /// No description provided for @widgetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widget'**
  String get widgetSettingsTitle;

  /// No description provided for @widgetSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'This month\'s spending and one-tap adding, right on your home screen'**
  String get widgetSettingsBody;

  /// No description provided for @widgetAddToHome.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get widgetAddToHome;

  /// No description provided for @widgetPinManual.
  ///
  /// In en, this message translates to:
  /// **'Long-press an empty spot on your home screen, tap Widgets and find Spendroo.'**
  String get widgetPinManual;

  /// No description provided for @widgetSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get widgetSpentThisMonth;

  /// No description provided for @widgetSpentIn.
  ///
  /// In en, this message translates to:
  /// **'Spent in {month}'**
  String widgetSpentIn(String month);

  /// No description provided for @widgetLeftThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Left this month'**
  String get widgetLeftThisMonth;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @teamOpen.
  ///
  /// In en, this message translates to:
  /// **'Manage team'**
  String get teamOpen;

  /// No description provided for @teamHint.
  ///
  /// In en, this message translates to:
  /// **'People, roles and invitations'**
  String get teamHint;

  /// No description provided for @teamBusinessOnly.
  ///
  /// In en, this message translates to:
  /// **'A team belongs to a business. Switch to one to see its people.'**
  String get teamBusinessOnly;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'You are {role} here'**
  String yourRole(String role);

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// No description provided for @roleOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Owns the business and its plan. Can do everything.'**
  String get roleOwnerHint;

  /// No description provided for @roleAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Runs every cashbook and invites staff and viewers.'**
  String get roleAdminHint;

  /// No description provided for @roleStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Works only in the cashbooks you open to them.'**
  String get roleStaffHint;

  /// No description provided for @roleViewerHint.
  ///
  /// In en, this message translates to:
  /// **'Sees every cashbook but changes nothing.'**
  String get roleViewerHint;

  /// No description provided for @groupAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get groupAdmins;

  /// No description provided for @groupStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get groupStaff;

  /// No description provided for @groupViewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get groupViewers;

  /// No description provided for @groupInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get groupInvited;

  /// No description provided for @seatsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} seats used'**
  String seatsUsed(int used, int limit);

  /// No description provided for @seatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seat left} other{{count} seats left}}'**
  String seatsLeft(int count);

  /// No description provided for @seatsFull.
  ///
  /// In en, this message translates to:
  /// **'All seats taken'**
  String get seatsFull;

  /// No description provided for @seatsUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No one invited yet} =1{1 seat in use} other{{count} seats in use}}'**
  String seatsUnlimited(int count);

  /// No description provided for @seatsFullAskOwner.
  ///
  /// In en, this message translates to:
  /// **'Every seat on this business is taken. Ask the owner to make room or upgrade the plan.'**
  String get seatsFullAskOwner;

  /// No description provided for @limitSeats.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan gives {limit, plural, =0{no team seats} =1{1 team seat} other{{limit} team seats}} per business.'**
  String limitSeats(String plan, int limit);

  /// No description provided for @teamUpsellTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your team'**
  String get teamUpsellTitle;

  /// No description provided for @teamUpsellBody.
  ///
  /// In en, this message translates to:
  /// **'The Business plan gives you seats for staff. Invite them, choose who works in which cashbook, and see every entry in one place.'**
  String get teamUpsellBody;

  /// No description provided for @teamEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Just you so far'**
  String get teamEmptyTitle;

  /// No description provided for @teamEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Invite the people who keep the books with you. You decide what each of them can see and do.'**
  String get teamEmptyBody;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeone;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite to {business}'**
  String inviteTitle(String business);

  /// No description provided for @inviteIntro.
  ///
  /// In en, this message translates to:
  /// **'They join with a one-time code, valid for 7 days.'**
  String get inviteIntro;

  /// No description provided for @inviteEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get inviteEmailHint;

  /// No description provided for @invitePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+880 17XX-XXXXXX'**
  String get invitePhoneHint;

  /// No description provided for @inviteByEmailNote.
  ///
  /// In en, this message translates to:
  /// **'We email them the code. Only the account with this email can use it.'**
  String get inviteByEmailNote;

  /// No description provided for @inviteByPhoneNote.
  ///
  /// In en, this message translates to:
  /// **'You get a code to send them yourself, by SMS or any chat app.'**
  String get inviteByPhoneNote;

  /// No description provided for @inviteAs.
  ///
  /// In en, this message translates to:
  /// **'Invite as'**
  String get inviteAs;

  /// No description provided for @inviteUsesSeat.
  ///
  /// In en, this message translates to:
  /// **'This takes seat {seat} of {limit} until they join or the invitation ends.'**
  String inviteUsesSeat(int seat, int limit);

  /// No description provided for @inviteSend.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get inviteSend;

  /// No description provided for @inviteMakeCode.
  ///
  /// In en, this message translates to:
  /// **'Create code'**
  String get inviteMakeCode;

  /// No description provided for @inviteEmailNeeded.
  ///
  /// In en, this message translates to:
  /// **'Enter their email.'**
  String get inviteEmailNeeded;

  /// No description provided for @invitePhoneNeeded.
  ///
  /// In en, this message translates to:
  /// **'Enter their phone number.'**
  String get invitePhoneNeeded;

  /// No description provided for @inviteEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like an email address.'**
  String get inviteEmailInvalid;

  /// No description provided for @invitePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like a phone number.'**
  String get invitePhoneInvalid;

  /// No description provided for @inviteTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation to {business}'**
  String inviteTicketTitle(String business);

  /// No description provided for @inviteEmailed.
  ///
  /// In en, this message translates to:
  /// **'Sent to {email}. You can also pass the code on yourself.'**
  String inviteEmailed(String email);

  /// No description provided for @inviteShareOnce.
  ///
  /// In en, this message translates to:
  /// **'Send this code to them now. It is shown only once.'**
  String get inviteShareOnce;

  /// No description provided for @inviteValidDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Works for 1 day, once.} other{Works for {days} days, once.}}'**
  String inviteValidDays(int days);

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Join {business} on Spendroo. Open the app, tap the business name at the top, choose “Join a business” and enter this code: {code}'**
  String inviteShareText(String business, String code);

  /// No description provided for @inviteExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Ends today} =1{Ends tomorrow} other{Ends in {days} days}}'**
  String inviteExpiresIn(int days);

  /// No description provided for @inviteCancel.
  ///
  /// In en, this message translates to:
  /// **'Withdraw invitation'**
  String get inviteCancel;

  /// No description provided for @inviteCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Withdraw the invitation to {contact}? Their code will stop working and the seat is freed.'**
  String inviteCancelConfirm(String contact);

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @cashbookAccess.
  ///
  /// In en, this message translates to:
  /// **'Cashbook access'**
  String get cashbookAccess;

  /// No description provided for @booksOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{open} of {total} open'**
  String booksOpenCount(int open, int total);

  /// No description provided for @accessByRoleAll.
  ///
  /// In en, this message translates to:
  /// **'Reaches every cashbook through their role.'**
  String get accessByRoleAll;

  /// No description provided for @accessByRoleView.
  ///
  /// In en, this message translates to:
  /// **'Can look at every cashbook, but not change anything.'**
  String get accessByRoleView;

  /// No description provided for @accessByRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Works only in the cashbooks the owner or an admin opens to them.'**
  String get accessByRoleStaff;

  /// No description provided for @roleChangeNotYours.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can change this role.'**
  String get roleChangeNotYours;

  /// No description provided for @roleChangeDropsAccess.
  ///
  /// In en, this message translates to:
  /// **'Make {name} {role}? Their access to single cashbooks will be removed.'**
  String roleChangeDropsAccess(String name, String role);

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joinedOn(String date);

  /// No description provided for @memberGone.
  ///
  /// In en, this message translates to:
  /// **'This person is no longer in the business.'**
  String get memberGone;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from business'**
  String get removeMember;

  /// No description provided for @removeMemberHint.
  ///
  /// In en, this message translates to:
  /// **'They lose access straight away. You can invite them again.'**
  String get removeMemberHint;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {business}? Their entries stay.'**
  String removeMemberConfirm(String name, String business);

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get memberRemoved;

  /// No description provided for @handOver.
  ///
  /// In en, this message translates to:
  /// **'Make owner'**
  String get handOver;

  /// No description provided for @handOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand over the business'**
  String get handOverTitle;

  /// No description provided for @handOverHint.
  ///
  /// In en, this message translates to:
  /// **'Hand the business and its plan to {name}'**
  String handOverHint(String name);

  /// No description provided for @handOverBody.
  ///
  /// In en, this message translates to:
  /// **'{name} becomes the owner of {business}, and it runs on their plan from then on. You stay on as an admin, and only they can hand it back.'**
  String handOverBody(String name, String business);

  /// No description provided for @handOverTypeName.
  ///
  /// In en, this message translates to:
  /// **'Type “{business}” to confirm'**
  String handOverTypeName(String business);

  /// No description provided for @handedOver.
  ///
  /// In en, this message translates to:
  /// **'{name} is the owner now'**
  String handedOver(String name);

  /// No description provided for @handOverNoRoom.
  ///
  /// In en, this message translates to:
  /// **'{name}’s plan has no room for this business yet. They need a plan with enough businesses, team seats and cashbooks first.'**
  String handOverNoRoom(String name);

  /// No description provided for @leaveBusiness.
  ///
  /// In en, this message translates to:
  /// **'Leave business'**
  String get leaveBusiness;

  /// No description provided for @leaveBusinessConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave {business}? It will disappear from this phone, and you need a new invitation to come back.'**
  String leaveBusinessConfirm(String business);

  /// No description provided for @leftBusiness.
  ///
  /// In en, this message translates to:
  /// **'You left {business}'**
  String leftBusiness(String business);

  /// No description provided for @joinBusiness.
  ///
  /// In en, this message translates to:
  /// **'Join a business'**
  String get joinBusiness;

  /// No description provided for @joinIntro.
  ///
  /// In en, this message translates to:
  /// **'Got an invitation code? Enter it to join the business that sent it.'**
  String get joinIntro;

  /// No description provided for @joinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'10 letters and numbers, from the email or message you got'**
  String get joinCodeHint;

  /// No description provided for @invitedBy.
  ///
  /// In en, this message translates to:
  /// **'Invited by {name}'**
  String invitedBy(String name);

  /// No description provided for @joinAs.
  ///
  /// In en, this message translates to:
  /// **'Join as {role}'**
  String joinAs(String role);

  /// No description provided for @joinedBusiness.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {business}'**
  String joinedBusiness(String business);

  /// No description provided for @teamErrorAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'This person is already in the business.'**
  String get teamErrorAlreadyMember;

  /// No description provided for @teamErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code doesn’t match any invitation. Check it and try again.'**
  String get teamErrorInvalidCode;

  /// No description provided for @teamErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'This invitation has ended. Ask for a new one.'**
  String get teamErrorExpired;

  /// No description provided for @teamErrorUsed.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used.'**
  String get teamErrorUsed;

  /// No description provided for @teamErrorWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'This invitation was sent to another email. Sign in with that account to use it.'**
  String get teamErrorWrongAccount;

  /// No description provided for @teamErrorNoSeats.
  ///
  /// In en, this message translates to:
  /// **'This business has no free seat right now. Ask its owner to make room.'**
  String get teamErrorNoSeats;

  /// No description provided for @teamErrorTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait a while and try again.'**
  String get teamErrorTooMany;

  /// No description provided for @teamErrorBadInput.
  ///
  /// In en, this message translates to:
  /// **'Check what you entered and try again.'**
  String get teamErrorBadInput;

  /// No description provided for @teamErrorRefused.
  ///
  /// In en, this message translates to:
  /// **'You can’t make this change.'**
  String get teamErrorRefused;

  /// No description provided for @teamErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn’t work. Try again.'**
  String get teamErrorFailed;

  /// No description provided for @haveInviteCode.
  ///
  /// In en, this message translates to:
  /// **'I have an invitation code'**
  String get haveInviteCode;

  /// No description provided for @haveInviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Join a business someone invited you to.'**
  String get haveInviteCodeHint;

  /// No description provided for @joinRoleAdminHint.
  ///
  /// In en, this message translates to:
  /// **'You’ll run every cashbook and can invite staff and viewers.'**
  String get joinRoleAdminHint;

  /// No description provided for @joinRoleStaffHint.
  ///
  /// In en, this message translates to:
  /// **'You’ll work in the cashbooks the owner or an admin opens to you.'**
  String get joinRoleStaffHint;

  /// No description provided for @joinRoleViewerHint.
  ///
  /// In en, this message translates to:
  /// **'You’ll see every cashbook but won’t change anything.'**
  String get joinRoleViewerHint;

  /// No description provided for @noCashbooksForStaff.
  ///
  /// In en, this message translates to:
  /// **'No cashbooks are open to you yet. Ask the owner or an admin to give you access.'**
  String get noCashbooksForStaff;

  /// No description provided for @roleChangeManagersOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner or an admin can change this role.'**
  String get roleChangeManagersOnly;

  /// No description provided for @seatsNone.
  ///
  /// In en, this message translates to:
  /// **'No team seats on this plan'**
  String get seatsNone;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get historyTitle;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Who changed what, and when'**
  String get historyHint;

  /// No description provided for @historyOfEntry.
  ///
  /// In en, this message translates to:
  /// **'History of this entry'**
  String get historyOfEntry;

  /// No description provided for @historyTheirChanges.
  ///
  /// In en, this message translates to:
  /// **'See their changes'**
  String get historyTheirChanges;

  /// No description provided for @historyTheirChangesHint.
  ///
  /// In en, this message translates to:
  /// **'Everything {name} added, edited or deleted'**
  String historyTheirChangesHint(String name);

  /// No description provided for @historyChangesBy.
  ///
  /// In en, this message translates to:
  /// **'Changes by {name}'**
  String historyChangesBy(String name);

  /// No description provided for @historyNobody.
  ///
  /// In en, this message translates to:
  /// **'Spendroo'**
  String get historyNobody;

  /// No description provided for @historySomeone.
  ///
  /// In en, this message translates to:
  /// **'someone'**
  String get historySomeone;

  /// No description provided for @historyChanged.
  ///
  /// In en, this message translates to:
  /// **'Made a change'**
  String get historyChanged;

  /// No description provided for @historyEntryCreated.
  ///
  /// In en, this message translates to:
  /// **'Added an entry'**
  String get historyEntryCreated;

  /// No description provided for @historyEntryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Edited an entry'**
  String get historyEntryUpdated;

  /// No description provided for @historyEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted an entry'**
  String get historyEntryDeleted;

  /// No description provided for @historyEntryRestored.
  ///
  /// In en, this message translates to:
  /// **'Brought back an entry'**
  String get historyEntryRestored;

  /// No description provided for @historyCashbookCreated.
  ///
  /// In en, this message translates to:
  /// **'Created a cashbook'**
  String get historyCashbookCreated;

  /// No description provided for @historyCashbookUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changed a cashbook'**
  String get historyCashbookUpdated;

  /// No description provided for @historyCashbookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted a cashbook'**
  String get historyCashbookDeleted;

  /// No description provided for @historyCashbookRestored.
  ///
  /// In en, this message translates to:
  /// **'Brought back a cashbook'**
  String get historyCashbookRestored;

  /// No description provided for @historyCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Added a category'**
  String get historyCategoryCreated;

  /// No description provided for @historyCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changed a category'**
  String get historyCategoryUpdated;

  /// No description provided for @historyCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Removed a category'**
  String get historyCategoryDeleted;

  /// No description provided for @historyCategoryRestored.
  ///
  /// In en, this message translates to:
  /// **'Brought back a category'**
  String get historyCategoryRestored;

  /// No description provided for @historyMethodCreated.
  ///
  /// In en, this message translates to:
  /// **'Added a payment method'**
  String get historyMethodCreated;

  /// No description provided for @historyMethodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changed a payment method'**
  String get historyMethodUpdated;

  /// No description provided for @historyMethodDeleted.
  ///
  /// In en, this message translates to:
  /// **'Removed a payment method'**
  String get historyMethodDeleted;

  /// No description provided for @historyMethodRestored.
  ///
  /// In en, this message translates to:
  /// **'Brought back a payment method'**
  String get historyMethodRestored;

  /// No description provided for @historyAccessGiven.
  ///
  /// In en, this message translates to:
  /// **'Gave {name} access'**
  String historyAccessGiven(String name);

  /// No description provided for @historyAccessChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed {name}’s access'**
  String historyAccessChanged(String name);

  /// No description provided for @historyAccessTaken.
  ///
  /// In en, this message translates to:
  /// **'Took away {name}’s access'**
  String historyAccessTaken(String name);

  /// No description provided for @historyMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'Brought {name} into the team'**
  String historyMemberJoined(String name);

  /// No description provided for @historyMemberRole.
  ///
  /// In en, this message translates to:
  /// **'Changed {name}’s role'**
  String historyMemberRole(String name);

  /// No description provided for @historyMemberLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} is no longer on the team'**
  String historyMemberLeft(String name);

  /// No description provided for @historyFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get historyFieldAmount;

  /// No description provided for @historyFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get historyFieldType;

  /// No description provided for @historyFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyFieldDate;

  /// No description provided for @historyFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get historyFieldTitle;

  /// No description provided for @historyFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get historyFieldNote;

  /// No description provided for @historyFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get historyFieldCategory;

  /// No description provided for @historyFieldMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get historyFieldMethod;

  /// No description provided for @historyFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get historyFieldName;

  /// No description provided for @historyFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get historyFieldDescription;

  /// No description provided for @historyFieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get historyFieldCurrency;

  /// No description provided for @historyFieldColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get historyFieldColour;

  /// No description provided for @historyFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get historyFieldRole;

  /// No description provided for @historyFieldAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get historyFieldAccess;

  /// No description provided for @historyEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get historyEmptyValue;

  /// No description provided for @historyAnyBook.
  ///
  /// In en, this message translates to:
  /// **'All cashbooks'**
  String get historyAnyBook;

  /// No description provided for @historyAnyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get historyAnyone;

  /// No description provided for @historyAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get historyAnyTime;

  /// No description provided for @historyPickBook.
  ///
  /// In en, this message translates to:
  /// **'Show changes in'**
  String get historyPickBook;

  /// No description provided for @historyPickPerson.
  ///
  /// In en, this message translates to:
  /// **'Show changes by'**
  String get historyPickPerson;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAll;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has changed yet. Every entry your team adds, edits or deletes will show up here.'**
  String get historyEmpty;

  /// No description provided for @historyEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No changes match these filters.'**
  String get historyEmptyFiltered;

  /// No description provided for @historyEmptyEntry.
  ///
  /// In en, this message translates to:
  /// **'This entry hasn’t reached the server yet. Its history shows once it syncs.'**
  String get historyEmptyEntry;

  /// No description provided for @historyTheStart.
  ///
  /// In en, this message translates to:
  /// **'That’s everything'**
  String get historyTheStart;

  /// No description provided for @historyMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load more.'**
  String get historyMoreFailed;

  /// No description provided for @historyOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the business owner can see the edit history.'**
  String get historyOwnerOnly;

  /// No description provided for @historyBusinessOnly.
  ///
  /// In en, this message translates to:
  /// **'Edit history is kept for businesses.'**
  String get historyBusinessOnly;

  /// No description provided for @historyLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'See who changed what, and when'**
  String get historyLockedTitle;

  /// No description provided for @historyLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your team accountable with a full record of every change in your business.'**
  String get historyLockedBody;

  /// No description provided for @historyLockedPoint1.
  ///
  /// In en, this message translates to:
  /// **'Every edit, with before and after'**
  String get historyLockedPoint1;

  /// No description provided for @historyLockedPoint2.
  ///
  /// In en, this message translates to:
  /// **'Filter by cashbook, person or date'**
  String get historyLockedPoint2;

  /// No description provided for @historyLockedPoint3.
  ///
  /// In en, this message translates to:
  /// **'Deleted entries never vanish from view'**
  String get historyLockedPoint3;

  /// No description provided for @historyBackToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to the newest'**
  String get historyBackToTop;

  /// No description provided for @historyChangeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change} other{{count} changes}}'**
  String historyChangeCount(int count);

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @billsHint.
  ///
  /// In en, this message translates to:
  /// **'Keep a photo or PDF of the receipt with this entry.'**
  String get billsHint;

  /// No description provided for @billAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach bill'**
  String get billAttach;

  /// No description provided for @billTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get billTakePhoto;

  /// No description provided for @billTakePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Snap a paper receipt. It\'s kept sharp and small.'**
  String get billTakePhotoHint;

  /// No description provided for @billChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get billChoosePhoto;

  /// No description provided for @billChoosePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'A photo or screenshot already on your phone'**
  String get billChoosePhotoHint;

  /// No description provided for @billChoosePdf.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF'**
  String get billChoosePdf;

  /// No description provided for @billChoosePdfHint.
  ///
  /// In en, this message translates to:
  /// **'Invoices and statements that came as a PDF'**
  String get billChoosePdfHint;

  /// No description provided for @billPerFile.
  ///
  /// In en, this message translates to:
  /// **'Up to {size} per bill'**
  String billPerFile(String size);

  /// No description provided for @billRoomLeft.
  ///
  /// In en, this message translates to:
  /// **'{size} left'**
  String billRoomLeft(String size);

  /// No description provided for @billStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} used'**
  String billStorageUsed(String used, String total);

  /// No description provided for @billStaged.
  ///
  /// In en, this message translates to:
  /// **'Attached when you save'**
  String get billStaged;

  /// No description provided for @billWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get billWaiting;

  /// No description provided for @billUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String billUploading(int percent);

  /// No description provided for @billFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t attach'**
  String get billFailed;

  /// No description provided for @billRefused.
  ///
  /// In en, this message translates to:
  /// **'No room on your plan'**
  String get billRefused;

  /// No description provided for @billRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get billRetry;

  /// No description provided for @billRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove bill'**
  String get billRemove;

  /// No description provided for @billRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this bill? The file is deleted for everyone in this business.'**
  String get billRemoveConfirm;

  /// No description provided for @billRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bill removed'**
  String get billRemoved;

  /// No description provided for @billAdded.
  ///
  /// In en, this message translates to:
  /// **'Bill attached. It uploads in the background.'**
  String get billAdded;

  /// No description provided for @billShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get billShare;

  /// No description provided for @billOpenElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Open in another app'**
  String get billOpenElsewhere;

  /// No description provided for @billPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String billPages(int count);

  /// No description provided for @billCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill} other{{count} bills}}'**
  String billCount(int count);

  /// No description provided for @billOf.
  ///
  /// In en, this message translates to:
  /// **'{index} of {total}'**
  String billOf(int index, int total);

  /// No description provided for @billOpenOffline.
  ///
  /// In en, this message translates to:
  /// **'This bill isn\'t saved on this phone yet. Connect to the internet to open it.'**
  String get billOpenOffline;

  /// No description provided for @billGone.
  ///
  /// In en, this message translates to:
  /// **'This bill is no longer available.'**
  String get billGone;

  /// No description provided for @billOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The bill couldn\'t be opened. Try again.'**
  String get billOpenFailed;

  /// No description provided for @billErrorType.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a photo or a PDF.'**
  String get billErrorType;

  /// No description provided for @billErrorUnsafe.
  ///
  /// In en, this message translates to:
  /// **'This file has scripts or hidden content in it, so it can\'t be kept.'**
  String get billErrorUnsafe;

  /// No description provided for @billErrorCorrupt.
  ///
  /// In en, this message translates to:
  /// **'This file is damaged and can\'t be opened.'**
  String get billErrorCorrupt;

  /// No description provided for @billErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large to attach.'**
  String get billErrorTooLarge;

  /// No description provided for @billErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add bills to this entry.'**
  String get billErrorForbidden;

  /// No description provided for @billErrorGone.
  ///
  /// In en, this message translates to:
  /// **'This entry isn\'t on the server any more.'**
  String get billErrorGone;

  /// No description provided for @billErrorMissing.
  ///
  /// In en, this message translates to:
  /// **'The file is no longer on this phone. Remove it and attach it again.'**
  String get billErrorMissing;

  /// No description provided for @billErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'The bill couldn\'t be attached.'**
  String get billErrorGeneric;

  /// No description provided for @billViewOnly.
  ///
  /// In en, this message translates to:
  /// **'You can view these bills but not change them.'**
  String get billViewOnly;

  /// No description provided for @entryDetails.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get entryDetails;

  /// No description provided for @limitStorage.
  ///
  /// In en, this message translates to:
  /// **'Your {plan} plan keeps up to {size} of bills and receipts. Remove some, or upgrade for more room.'**
  String limitStorage(String plan, String size);

  /// No description provided for @limitBillSize.
  ///
  /// In en, this message translates to:
  /// **'On your {plan} plan, one file can be up to {size}.'**
  String limitBillSize(String plan, String size);

  /// No description provided for @featureStorageFile.
  ///
  /// In en, this message translates to:
  /// **'Largest file'**
  String get featureStorageFile;

  /// No description provided for @featureStoragePdf.
  ///
  /// In en, this message translates to:
  /// **'Attaching PDFs'**
  String get featureStoragePdf;

  /// No description provided for @fieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get fieldsTitle;

  /// No description provided for @fieldsIntro.
  ///
  /// In en, this message translates to:
  /// **'Add the details your business tracks to every entry in this book. They show on entries and in reports.'**
  String get fieldsIntro;

  /// No description provided for @fieldsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} fields'**
  String fieldsCount(int count, int max);

  /// No description provided for @fieldsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Track what matters to your business'**
  String get fieldsEmptyTitle;

  /// No description provided for @fieldsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add fields like an invoice number or the party you paid. They appear on every entry in this book and in its reports.'**
  String get fieldsEmptyBody;

  /// No description provided for @fieldsTryOne.
  ///
  /// In en, this message translates to:
  /// **'Start with one of these'**
  String get fieldsTryOne;

  /// No description provided for @fieldsExampleInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice no'**
  String get fieldsExampleInvoice;

  /// No description provided for @fieldsExampleParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get fieldsExampleParty;

  /// No description provided for @fieldsExampleDue.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get fieldsExampleDue;

  /// No description provided for @fieldNew.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get fieldNew;

  /// No description provided for @fieldEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get fieldEdit;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get fieldName;

  /// No description provided for @fieldNameNeeded.
  ///
  /// In en, this message translates to:
  /// **'Give the field a name.'**
  String get fieldNameNeeded;

  /// No description provided for @fieldNameTaken.
  ///
  /// In en, this message translates to:
  /// **'This book already has a field called that.'**
  String get fieldNameTaken;

  /// No description provided for @fieldKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldKind;

  /// No description provided for @fieldKindText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldKindText;

  /// No description provided for @fieldKindNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldKindNumber;

  /// No description provided for @fieldKindDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldKindDate;

  /// No description provided for @fieldKindChoice.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get fieldKindChoice;

  /// No description provided for @fieldKindTextHint.
  ///
  /// In en, this message translates to:
  /// **'Codes, names, notes'**
  String get fieldKindTextHint;

  /// No description provided for @fieldKindNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Quantities, weights'**
  String get fieldKindNumberHint;

  /// No description provided for @fieldKindDateHint.
  ///
  /// In en, this message translates to:
  /// **'Due or delivery dates'**
  String get fieldKindDateHint;

  /// No description provided for @fieldKindChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Pick from a list'**
  String get fieldKindChoiceHint;

  /// No description provided for @fieldKindFixed.
  ///
  /// In en, this message translates to:
  /// **'The type can\'t change once the field is made.'**
  String get fieldKindFixed;

  /// No description provided for @fieldOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get fieldOptions;

  /// No description provided for @fieldOptionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add an option'**
  String get fieldOptionAdd;

  /// No description provided for @fieldOptionsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add at least one option.'**
  String get fieldOptionsNeeded;

  /// No description provided for @fieldOptionsFull.
  ///
  /// In en, this message translates to:
  /// **'A field can offer up to {max} options.'**
  String fieldOptionsFull(int max);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fieldRequiredDetail.
  ///
  /// In en, this message translates to:
  /// **'New entries can\'t be saved without it.'**
  String get fieldRequiredDetail;

  /// No description provided for @fieldShowInList.
  ///
  /// In en, this message translates to:
  /// **'Show on entry list'**
  String get fieldShowInList;

  /// No description provided for @fieldShowInListDetail.
  ///
  /// In en, this message translates to:
  /// **'Shown under each entry in this book. Only one field can be.'**
  String get fieldShowInListDetail;

  /// No description provided for @fieldPreview.
  ///
  /// In en, this message translates to:
  /// **'How it looks on an entry'**
  String get fieldPreview;

  /// No description provided for @fieldDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete field'**
  String get fieldDelete;

  /// No description provided for @fieldDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this field? Values already filled in stay with the entries but are no longer shown.'**
  String get fieldDeleteConfirm;

  /// No description provided for @fieldsFull.
  ///
  /// In en, this message translates to:
  /// **'A book can have up to {max} fields.'**
  String fieldsFull(int max);

  /// No description provided for @fieldPinned.
  ///
  /// In en, this message translates to:
  /// **'On list'**
  String get fieldPinned;

  /// No description provided for @fieldsReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag to change the order.'**
  String get fieldsReorderHint;

  /// No description provided for @fieldOptionsMore.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String fieldOptionsMore(int count);

  /// No description provided for @fieldsDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get fieldsDetails;

  /// No description provided for @fieldFillIn.
  ///
  /// In en, this message translates to:
  /// **'Fill this in.'**
  String get fieldFillIn;

  /// No description provided for @fieldNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, like 1250 or 12.5.'**
  String get fieldNeedsNumber;

  /// No description provided for @fieldPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get fieldPickDate;

  /// No description provided for @fieldClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get fieldClear;

  /// No description provided for @fieldsHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your own fields'**
  String get fieldsHintTitle;

  /// No description provided for @fieldsHintBody.
  ///
  /// In en, this message translates to:
  /// **'Track invoice numbers, parties and more on every entry.'**
  String get fieldsHintBody;

  /// No description provided for @fieldsLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields come with Business'**
  String get fieldsLockedTitle;

  /// No description provided for @fieldsLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Add your own fields to entries and see them on the list and in reports. Fields and values you already have stay as they are.'**
  String get fieldsLockedBody;

  /// No description provided for @fieldsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Your plan keeps these values as they are. Upgrade to change them.'**
  String get fieldsReadOnly;

  /// No description provided for @historyFieldCreated.
  ///
  /// In en, this message translates to:
  /// **'Added a custom field'**
  String get historyFieldCreated;

  /// No description provided for @historyFieldUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changed a custom field'**
  String get historyFieldUpdated;

  /// No description provided for @historyFieldDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted a custom field'**
  String get historyFieldDeleted;

  /// No description provided for @historyFieldRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored a custom field'**
  String get historyFieldRestored;

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

  /// No description provided for @booksTab.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksTab;

  /// No description provided for @entriesTab.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entriesTab;

  /// No description provided for @featureBusinessInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced business insights'**
  String get featureBusinessInsights;

  /// No description provided for @insNetFlow.
  ///
  /// In en, this message translates to:
  /// **'Net cash flow'**
  String get insNetFlow;

  /// No description provided for @insClosingBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance at the end'**
  String get insClosingBalance;

  /// No description provided for @insNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period yet'**
  String get insNoActivity;

  /// No description provided for @insNoActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Entries added here turn into charts and insights.'**
  String get insNoActivityHint;

  /// No description provided for @insNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period'**
  String get insNothingHere;

  /// No description provided for @insWhereMoneyWent.
  ///
  /// In en, this message translates to:
  /// **'Where the money went'**
  String get insWhereMoneyWent;

  /// No description provided for @insWhereMoneyCame.
  ///
  /// In en, this message translates to:
  /// **'Where the money came from'**
  String get insWhereMoneyCame;

  /// No description provided for @insPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get insPaymentMethods;

  /// No description provided for @insNoPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'No payment method'**
  String get insNoPaymentMethod;

  /// No description provided for @insIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get insIn;

  /// No description provided for @insOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get insOut;

  /// No description provided for @insBalanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Balance over time'**
  String get insBalanceTrend;

  /// No description provided for @insOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get insOpening;

  /// No description provided for @insClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing'**
  String get insClosing;

  /// No description provided for @insLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get insLowest;

  /// No description provided for @insActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get insActivity;

  /// No description provided for @insTapDay.
  ///
  /// In en, this message translates to:
  /// **'Tap a day for details'**
  String get insTapDay;

  /// No description provided for @insLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get insLess;

  /// No description provided for @insMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get insMore;

  /// No description provided for @insHealth.
  ///
  /// In en, this message translates to:
  /// **'Cash health'**
  String get insHealth;

  /// No description provided for @insOutRatio.
  ///
  /// In en, this message translates to:
  /// **'Cash out against cash in'**
  String get insOutRatio;

  /// No description provided for @insOutRatioNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing came in this period.'**
  String get insOutRatioNone;

  /// No description provided for @insOutRatioKept.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of what came in is still here.'**
  String insOutRatioKept(String percent);

  /// No description provided for @insOutRatioOver.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more went out than came in.'**
  String insOutRatioOver(String percent);

  /// No description provided for @insAvgDailyOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out a day'**
  String get insAvgDailyOut;

  /// No description provided for @insRunway.
  ///
  /// In en, this message translates to:
  /// **'Lasts'**
  String get insRunway;

  /// No description provided for @insRunwayDetail.
  ///
  /// In en, this message translates to:
  /// **'at this rate'**
  String get insRunwayDetail;

  /// No description provided for @insRunwaySafe.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get insRunwaySafe;

  /// No description provided for @insRunwaySafeDetail.
  ///
  /// In en, this message translates to:
  /// **'more in than out'**
  String get insRunwaySafeDetail;

  /// No description provided for @insDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String insDays(int count);

  /// No description provided for @insBusiestDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest day'**
  String get insBusiestDay;

  /// No description provided for @insAvgEntry.
  ///
  /// In en, this message translates to:
  /// **'Average entry'**
  String get insAvgEntry;

  /// No description provided for @insActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get insActiveDays;

  /// No description provided for @insActiveDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{active} of {days}'**
  String insActiveDaysValue(String active, String days);

  /// No description provided for @insTopEntries.
  ///
  /// In en, this message translates to:
  /// **'Biggest entries'**
  String get insTopEntries;

  /// No description provided for @insTeam.
  ///
  /// In en, this message translates to:
  /// **'Team activity'**
  String get insTeam;

  /// No description provided for @insYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get insYou;

  /// No description provided for @insSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get insSomeone;

  /// No description provided for @insMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get insMostActive;

  /// No description provided for @insStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get insStreak;

  /// No description provided for @insPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get insPeople;

  /// No description provided for @insBills.
  ///
  /// In en, this message translates to:
  /// **'Bills kept'**
  String get insBills;

  /// No description provided for @insBillsShare.
  ///
  /// In en, this message translates to:
  /// **'{kept} of {total} cash outs have a bill'**
  String insBillsShare(String kept, String total);

  /// No description provided for @insBillsAll.
  ///
  /// In en, this message translates to:
  /// **'Every cash out has its bill.'**
  String get insBillsAll;

  /// No description provided for @insBillsMissing.
  ///
  /// In en, this message translates to:
  /// **'{amount} has no bill yet.'**
  String insBillsMissing(String amount);

  /// No description provided for @insByField.
  ///
  /// In en, this message translates to:
  /// **'By your own field'**
  String get insByField;

  /// No description provided for @insFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'No values for this field in this period.'**
  String get insFieldEmpty;

  /// No description provided for @insBookLeague.
  ///
  /// In en, this message translates to:
  /// **'Books compared'**
  String get insBookLeague;

  /// No description provided for @insShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of all'**
  String insShare(String percent);

  /// No description provided for @insOtherCurrencies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book in another currency is not counted here.} other{{count} books in other currencies are not counted here.}}'**
  String insOtherCurrencies(int count);

  /// No description provided for @insBusinessChip.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get insBusinessChip;

  /// No description provided for @insUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Running balance, activity calendar, cash health, team, bills and comparing books come with the Business plan.'**
  String get insUnlockBody;

  /// No description provided for @insUnlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Business'**
  String get insUnlockAction;

  /// No description provided for @insMoreWithBusiness.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more chart with Business} other{{count} more charts with Business}}'**
  String insMoreWithBusiness(int count);

  /// No description provided for @insPeriodTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get insPeriodTotal;

  /// No description provided for @insPeakDay.
  ///
  /// In en, this message translates to:
  /// **'Peak day'**
  String get insPeakDay;

  /// No description provided for @insQuietDays.
  ///
  /// In en, this message translates to:
  /// **'Quiet days'**
  String get insQuietDays;

  /// No description provided for @insWeekRhythm.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get insWeekRhythm;

  /// No description provided for @insBusiestOn.
  ///
  /// In en, this message translates to:
  /// **'Busiest on {day}'**
  String insBusiestOn(String day);

  /// No description provided for @insTimesAverage.
  ///
  /// In en, this message translates to:
  /// **'{times}× a usual day'**
  String insTimesAverage(String times);

  /// No description provided for @insAvgIn.
  ///
  /// In en, this message translates to:
  /// **'Usual month in'**
  String get insAvgIn;

  /// No description provided for @insAvgOut.
  ///
  /// In en, this message translates to:
  /// **'Usual month out'**
  String get insAvgOut;

  /// No description provided for @insBestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best month'**
  String get insBestMonth;

  /// No description provided for @insAboveUsual.
  ///
  /// In en, this message translates to:
  /// **'Better than usual'**
  String get insAboveUsual;

  /// No description provided for @insBelowUsual.
  ///
  /// In en, this message translates to:
  /// **'Below usual'**
  String get insBelowUsual;

  /// No description provided for @insKept.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of cash in kept'**
  String insKept(String percent);

  /// No description provided for @insOverspent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more went out than came in'**
  String insOverspent(String percent);

  /// No description provided for @insActiveDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String insActiveDaysCount(int count);

  /// No description provided for @featureBusinessWidget.
  ///
  /// In en, this message translates to:
  /// **'Business home-screen widgets'**
  String get featureBusinessWidget;

  /// No description provided for @bizWidgetSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get bizWidgetSevenDays;

  /// No description provided for @bizWidgetVsYesterday.
  ///
  /// In en, this message translates to:
  /// **'vs yesterday'**
  String get bizWidgetVsYesterday;

  /// No description provided for @bizWidgetVsPrevious7.
  ///
  /// In en, this message translates to:
  /// **'vs previous 7 days'**
  String get bizWidgetVsPrevious7;

  /// No description provided for @bizWidgetVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get bizWidgetVsLastMonth;

  /// No description provided for @bizWidgetBooks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cashbooks} =1{1 cashbook} other{{count} cashbooks}}'**
  String bizWidgetBooks(int count);

  /// No description provided for @bizWidgetOtherCurrency.
  ///
  /// In en, this message translates to:
  /// **'+{count} in {currency}'**
  String bizWidgetOtherCurrency(int count, String currency);

  /// No description provided for @bizWidgetUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'See where your business stands'**
  String get bizWidgetUnlockTitle;

  /// No description provided for @bizWidgetUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Today, 7 days and the month, a 14-day cash chart and smart insights'**
  String get bizWidgetUnlockBody;

  /// No description provided for @bizWidgetChooseBusiness.
  ///
  /// In en, this message translates to:
  /// **'Choose a business'**
  String get bizWidgetChooseBusiness;

  /// No description provided for @bizWidgetChooseBook.
  ///
  /// In en, this message translates to:
  /// **'Choose a cashbook'**
  String get bizWidgetChooseBook;

  /// No description provided for @bizWidgetChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick what this widget shows'**
  String get bizWidgetChooseBody;

  /// No description provided for @bizWidgetGoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No longer available'**
  String get bizWidgetGoneTitle;

  /// No description provided for @bizWidgetGoneBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose another'**
  String get bizWidgetGoneBody;

  /// No description provided for @bizWidgetSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Your business at a glance will show here'**
  String get bizWidgetSignInBody;

  /// No description provided for @bizWidgetBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashbooks'**
  String get bizWidgetBooksTitle;

  /// No description provided for @bizWidgetRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get bizWidgetRecentTitle;

  /// No description provided for @bizWidgetNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Tap Cash in or Cash out to start.'**
  String get bizWidgetNoEntries;

  /// No description provided for @bizWidgetQuietChart.
  ///
  /// In en, this message translates to:
  /// **'Nothing in or out in the last 14 days'**
  String get bizWidgetQuietChart;

  /// No description provided for @bizWidgetNoBooks.
  ///
  /// In en, this message translates to:
  /// **'No cashbooks yet. Open the business to add one.'**
  String get bizWidgetNoBooks;

  /// No description provided for @bizWidgetNextInsight.
  ///
  /// In en, this message translates to:
  /// **'Next insight'**
  String get bizWidgetNextInsight;

  /// No description provided for @bizWidgetRefresh.
  ///
  /// In en, this message translates to:
  /// **'Open and refresh'**
  String get bizWidgetRefresh;

  /// No description provided for @bizWidgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Change period'**
  String get bizWidgetPeriod;

  /// No description provided for @bizWidgetPickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No businesses yet. Create one in Spendroo first.'**
  String get bizWidgetPickerEmpty;

  /// No description provided for @bizWidgetPickerBooksEmpty.
  ///
  /// In en, this message translates to:
  /// **'This business has no cashbooks yet.'**
  String get bizWidgetPickerBooksEmpty;

  /// No description provided for @bizWidgetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business widgets'**
  String get bizWidgetSettingsTitle;

  /// No description provided for @bizWidgetSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'A whole business or one cashbook on your home screen'**
  String get bizWidgetSettingsBody;

  /// No description provided for @bizWidgetAddBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business widget'**
  String get bizWidgetAddBusiness;

  /// No description provided for @bizWidgetAddBusinessBody.
  ///
  /// In en, this message translates to:
  /// **'Balance, cash in and out, and insights across every cashbook'**
  String get bizWidgetAddBusinessBody;

  /// No description provided for @bizWidgetAddBook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook widget'**
  String get bizWidgetAddBook;

  /// No description provided for @bizWidgetAddBookBody.
  ///
  /// In en, this message translates to:
  /// **'One cashbook, with one-tap Cash in and Cash out'**
  String get bizWidgetAddBookBody;

  /// No description provided for @bizChooseBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to which cashbook?'**
  String get bizChooseBookTitle;

  /// No description provided for @bizChooseBookNone.
  ///
  /// In en, this message translates to:
  /// **'You can only view this business\'s cashbooks.'**
  String get bizChooseBookNone;

  /// No description provided for @bizInsightNegative.
  ///
  /// In en, this message translates to:
  /// **'Balance is {amount} below zero'**
  String bizInsightNegative(String amount);

  /// No description provided for @bizInsightNegativeMasked.
  ///
  /// In en, this message translates to:
  /// **'Balance is below zero'**
  String get bizInsightNegativeMasked;

  /// No description provided for @bizInsightNegativeBook.
  ///
  /// In en, this message translates to:
  /// **'{book} is {amount} below zero'**
  String bizInsightNegativeBook(String book, String amount);

  /// No description provided for @bizInsightNegativeBookMasked.
  ///
  /// In en, this message translates to:
  /// **'{book} is below zero'**
  String bizInsightNegativeBookMasked(String book);

  /// No description provided for @bizInsightIdle.
  ///
  /// In en, this message translates to:
  /// **'No entries since {date}'**
  String bizInsightIdle(String date);

  /// No description provided for @bizInsightOutUp.
  ///
  /// In en, this message translates to:
  /// **'Cash out is up {percent} on last month'**
  String bizInsightOutUp(String percent);

  /// No description provided for @bizInsightOutDown.
  ///
  /// In en, this message translates to:
  /// **'Cash out is down {percent} on last month'**
  String bizInsightOutDown(String percent);

  /// No description provided for @bizInsightInUp.
  ///
  /// In en, this message translates to:
  /// **'Cash in is up {percent} on last month'**
  String bizInsightInUp(String percent);

  /// No description provided for @bizInsightInDown.
  ///
  /// In en, this message translates to:
  /// **'Cash in is down {percent} on last month'**
  String bizInsightInDown(String percent);

  /// No description provided for @bizInsightTopCategory.
  ///
  /// In en, this message translates to:
  /// **'{category} is {percent} of this month\'s cash out'**
  String bizInsightTopCategory(String category, String percent);

  /// No description provided for @bizInsightBiggestOut.
  ///
  /// In en, this message translates to:
  /// **'Biggest cash out this week: {label}, {amount}'**
  String bizInsightBiggestOut(String label, String amount);

  /// No description provided for @bizInsightBiggestOutMasked.
  ///
  /// In en, this message translates to:
  /// **'Biggest cash out this week: {label}'**
  String bizInsightBiggestOutMasked(String label);

  /// No description provided for @bizInsightStreak.
  ///
  /// In en, this message translates to:
  /// **'Cash in beat cash out {days} days running'**
  String bizInsightStreak(String days);

  /// No description provided for @bizInsightProjection.
  ///
  /// In en, this message translates to:
  /// **'At this pace, {month} ends at {amount}'**
  String bizInsightProjection(String month, String amount);

  /// No description provided for @bizInsightProjectionAhead.
  ///
  /// In en, this message translates to:
  /// **'At this pace, {month} ends ahead'**
  String bizInsightProjectionAhead(String month);

  /// No description provided for @bizInsightProjectionBehind.
  ///
  /// In en, this message translates to:
  /// **'At this pace, {month} ends behind'**
  String bizInsightProjectionBehind(String month);

  /// No description provided for @bizInsightLeadBook.
  ///
  /// In en, this message translates to:
  /// **'{book} leads this month at {amount}'**
  String bizInsightLeadBook(String book, String amount);

  /// No description provided for @bizInsightLeadBookMasked.
  ///
  /// In en, this message translates to:
  /// **'{book} leads this month'**
  String bizInsightLeadBookMasked(String book);

  /// No description provided for @bizInsightLosingBook.
  ///
  /// In en, this message translates to:
  /// **'{book} is at {amount} this month'**
  String bizInsightLosingBook(String book, String amount);

  /// No description provided for @bizInsightLosingBookMasked.
  ///
  /// In en, this message translates to:
  /// **'{book} is losing money this month'**
  String bizInsightLosingBookMasked(String book);

  /// No description provided for @bizInsightQuietMonth.
  ///
  /// In en, this message translates to:
  /// **'No entries yet this month'**
  String get bizInsightQuietMonth;

  /// No description provided for @bizInsightEmptyBook.
  ///
  /// In en, this message translates to:
  /// **'Add the first entry to see insights here'**
  String get bizInsightEmptyBook;

  /// No description provided for @bizInsightSteady.
  ///
  /// In en, this message translates to:
  /// **'Cash in and out are close to last month'**
  String get bizInsightSteady;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant / payee'**
  String get merchant;

  /// No description provided for @party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get party;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagName;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get editTag;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Put tags on transactions and entries to group them your own way.'**
  String get noTags;

  /// No description provided for @removeTag.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeTag(String name);

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? {count, plural, =0{Nothing carries it yet.} =1{It comes off 1 transaction or entry.} other{It comes off {count} transactions and entries.}}'**
  String deleteTagConfirm(String name, int count);

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Labels for transactions and entries'**
  String get tagsHint;

  /// No description provided for @searchEntries.
  ///
  /// In en, this message translates to:
  /// **'Search entries'**
  String get searchEntries;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @receiptsHint.
  ///
  /// In en, this message translates to:
  /// **'Keep a photo or PDF of the receipt with this transaction.'**
  String get receiptsHint;

  /// No description provided for @receiptAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt'**
  String get receiptAttach;

  /// No description provided for @receiptPerFile.
  ///
  /// In en, this message translates to:
  /// **'Up to {size} per receipt'**
  String receiptPerFile(String size);

  /// No description provided for @receiptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt'**
  String get receiptRemove;

  /// No description provided for @receiptRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this receipt? The file is deleted from all your devices.'**
  String get receiptRemoveConfirm;

  /// No description provided for @receiptRemoved.
  ///
  /// In en, this message translates to:
  /// **'Receipt removed'**
  String get receiptRemoved;

  /// No description provided for @receiptAdded.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached. It uploads in the background.'**
  String get receiptAdded;

  /// No description provided for @receiptCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 receipt} other{{count} receipts}}'**
  String receiptCount(int count);

  /// No description provided for @receiptOpenOffline.
  ///
  /// In en, this message translates to:
  /// **'This receipt isn\'t saved on this phone yet. Connect to the internet to open it.'**
  String get receiptOpenOffline;

  /// No description provided for @receiptGone.
  ///
  /// In en, this message translates to:
  /// **'This receipt is no longer available.'**
  String get receiptGone;

  /// No description provided for @receiptOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The receipt couldn\'t be opened. Try again.'**
  String get receiptOpenFailed;

  /// No description provided for @receiptErrorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add receipts to this transaction.'**
  String get receiptErrorForbidden;

  /// No description provided for @receiptErrorGone.
  ///
  /// In en, this message translates to:
  /// **'This transaction isn\'t on the server any more.'**
  String get receiptErrorGone;

  /// No description provided for @receiptErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'The receipt couldn\'t be attached.'**
  String get receiptErrorGeneric;

  /// No description provided for @receiptErrorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only expenses and income can have a receipt.'**
  String get receiptErrorNotAllowed;

  /// No description provided for @filterReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get filterReceipt;

  /// No description provided for @filterWithReceipt.
  ///
  /// In en, this message translates to:
  /// **'With receipt'**
  String get filterWithReceipt;

  /// No description provided for @filterWithoutReceipt.
  ///
  /// In en, this message translates to:
  /// **'Without receipt'**
  String get filterWithoutReceipt;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
