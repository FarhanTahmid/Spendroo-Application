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
  /// **'Search by note, category or amount'**
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
  /// **'Extra fields on entries'**
  String get featureCustomFields;

  /// No description provided for @featureStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage for bills, in MB'**
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
