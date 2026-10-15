// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Spendroo';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'New password';

  @override
  String get logIn => 'Log in';

  @override
  String get signUp => 'Create account';

  @override
  String get noAccount => 'New here? Create an account';

  @override
  String get haveAccount => 'Already have an account? Log in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInFailed => 'Could not sign in with Google. Try again.';

  @override
  String get tagline => 'Your money and your shop, in one app.';

  @override
  String get enterEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Use at least 8 characters';

  @override
  String get verifyEmailTitle => 'Check your email';

  @override
  String codeSentTo(String email) {
    return 'We sent a code to $email. Enter it below.';
  }

  @override
  String get code => 'Code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Send the code again';

  @override
  String get codeResent => 'A new code is on its way.';

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordHint =>
      'Enter your email and we will send you a code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get setNewPassword => 'Set new password';

  @override
  String get passwordChanged => 'Password changed. Log in with the new one.';

  @override
  String get offlineError => 'No connection. Try again when you are online.';

  @override
  String get welcomeTitle => 'How will you use Spendroo?';

  @override
  String get forMyself => 'For myself';

  @override
  String get forMyselfHint => 'Track accounts, spending and budgets.';

  @override
  String get forMyBusiness => 'For my business';

  @override
  String get forMyBusinessHint => 'Keep a cashbook for a shop or business.';

  @override
  String get tryDemo => 'Try a demo business';

  @override
  String get tryDemoHint => 'A sample shop with a few weeks of entries.';

  @override
  String get businessName => 'Business name';

  @override
  String get createBusiness => 'Create business';

  @override
  String get needsConnection => 'This needs an internet connection.';

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Business';

  @override
  String get demo => 'Demo';

  @override
  String get switchWorkspace => 'Switch workspace';

  @override
  String get newBusiness => 'New business';

  @override
  String get deleteWorkspace => 'Delete this business';

  @override
  String get deleteWorkspaceConfirm =>
      'Delete this business and all its cashbooks?';

  @override
  String get overview => 'Overview';

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get accounts => 'Accounts';

  @override
  String get cashbooks => 'Cashbooks';

  @override
  String get settings => 'Settings';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get thisMonth => 'This month';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get noSpendingYet => 'No spending this month yet.';

  @override
  String get uncategorised => 'Uncategorised';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get noTransactions => 'No transactions yet. Add your first one.';

  @override
  String get amount => 'Amount';

  @override
  String get amountInvalid => 'Enter an amount greater than zero';

  @override
  String get account => 'Account';

  @override
  String get fromAccount => 'From account';

  @override
  String get toAccount => 'To account';

  @override
  String get category => 'Category';

  @override
  String get none => 'None';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteConfirm => 'Delete this?';

  @override
  String get sameAccountError => 'Choose two different accounts';

  @override
  String get currencyMismatch => 'Both accounts must use the same currency';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountName => 'Account name';

  @override
  String get accountKind => 'Type';

  @override
  String get kindCash => 'Cash';

  @override
  String get kindBank => 'Bank';

  @override
  String get kindSavings => 'Savings';

  @override
  String get kindMobileMoney => 'Mobile money';

  @override
  String get kindCard => 'Card';

  @override
  String get currency => 'Currency';

  @override
  String get defaultCurrency => 'Default currency';

  @override
  String get defaultCurrencyHint =>
      'New accounts, cashbooks and budgets start in it, and totals are shown in it. What you already have keeps its own.';

  @override
  String get currencyFixedHint =>
      'The currency cannot be changed after this is created.';

  @override
  String get keypadClear => 'Clear';

  @override
  String get keypadBackspace => 'Delete last';

  @override
  String get keypadDone => 'Done';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get archive => 'Archive';

  @override
  String get archived => 'Archived';

  @override
  String get addBudget => 'Add budget';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get noBudgets => 'No budgets yet. Set a monthly limit for a category.';

  @override
  String spentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get overBudget => 'Over budget';

  @override
  String get newCategory => 'New category';

  @override
  String get categoryName => 'Category name';

  @override
  String get addCashbook => 'Add cashbook';

  @override
  String get cashbookName => 'Cashbook name';

  @override
  String get noCashbooks =>
      'No cashbooks yet. Add one to start recording cash.';

  @override
  String get balance => 'Balance';

  @override
  String get cashIn => 'Cash in';

  @override
  String get cashOut => 'Cash out';

  @override
  String get totalIn => 'Total in';

  @override
  String get totalOut => 'Total out';

  @override
  String get noEntries => 'No entries yet. Use Cash in or Cash out below.';

  @override
  String get title => 'Title';

  @override
  String get remarks => 'Remarks';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get newPaymentMethod => 'New payment method';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get rename => 'Rename';

  @override
  String get report => 'Report';

  @override
  String get byCategory => 'By category';

  @override
  String get byPaymentMethod => 'By payment method';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'No entries',
    );
    return '$_temp0';
  }

  @override
  String get readOnly => 'You can view this cashbook but not change it.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sync => 'Sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String get allSynced => 'Everything is saved to the cloud';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get offlineStatus =>
      'Offline. Changes are kept on this device and sync later.';

  @override
  String syncError(String message) {
    return 'Sync problem: $message';
  }

  @override
  String get notSynced => 'Not synced';

  @override
  String get notSyncedHint =>
      'The server refused these changes and they were undone on this device.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirm =>
      'Log out? Data on this device is removed; everything already synced stays in your account.';

  @override
  String logOutUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes have not synced and will be lost.',
      one: '1 change has not synced and will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get budgetThisMonth => 'Budget this month';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get dailyAllowance => 'Daily allowance';

  @override
  String perDay(String amount) {
    return '$amount a day';
  }

  @override
  String get thisMonthOnly => 'This month only';

  @override
  String get thisMonthOnlyHint => 'Other months keep the usual limit.';

  @override
  String usualLimit(String amount) {
    return 'Usual limit: $amount';
  }

  @override
  String get useUsualLimit => 'Use usual limit';

  @override
  String get noTransactionsOnDay => 'Nothing recorded on this day.';

  @override
  String get categories => 'Categories';

  @override
  String get noCategories => 'No categories yet.';

  @override
  String get editCategory => 'Edit category';

  @override
  String get colour => 'Colour';

  @override
  String get automaticColour => 'Automatic';

  @override
  String get customColour => 'Custom colour';

  @override
  String get colourHue => 'Hue';

  @override
  String get colourShade => 'Shade';

  @override
  String deleteCategoryConfirm(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count transactions stay, without a category, and its budgets are removed.',
      one:
          '1 transaction stays, without a category, and its budgets are removed.',
      zero: 'Its budgets are removed.',
    );
    return 'Delete \"$name\"? $_temp0';
  }

  @override
  String get net => 'Net';

  @override
  String get netRemaining => 'Net remaining balance';

  @override
  String get lastSixMonths => 'Last 6 months';

  @override
  String changeVsLastMonth(String percent) {
    return '$percent% vs last month';
  }

  @override
  String get newThisMonth => 'New this month';

  @override
  String changeVsPeriodBefore(String percent) {
    return '$percent% vs the period before';
  }

  @override
  String get newThisPeriod => 'New this period';

  @override
  String get accountBalances => 'Account balances';

  @override
  String get shareOfTotalBalance =>
      'Percentages show each account’s share of the total balance.';

  @override
  String get server => 'Server';

  @override
  String get serverHint =>
      'Address of the Spendroo API this test build talks to.';

  @override
  String get serverChangeConfirm =>
      'Switch server? You will be logged out and data on this device is removed.';

  @override
  String get serverInvalid =>
      'Enter an address starting with http:// or https://';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get sendFeedbackHint => 'Tell us what works and what does not.';

  @override
  String get needsConnectionRetry =>
      'This needs an internet connection. Try again when you are online.';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get searchTransactions => 'Search by note, category or amount';

  @override
  String get searchOrCreate => 'Search or type a new name';

  @override
  String get filterAll => 'All';

  @override
  String noResultsFor(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get noMatches => 'Nothing matches.';

  @override
  String createNamed(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String paceLeft(String amount) {
    return '$amount left to spend';
  }

  @override
  String paceOver(String amount) {
    return '$amount over budget';
  }

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get enterEmailOrUsername => 'Enter your email or username';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get passwordSameAsCurrent =>
      'Choose a password different from your current one';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get changePassword => 'Change password';

  @override
  String get setPassword => 'Set a password';

  @override
  String get setPasswordHint =>
      'You signed in with Google. Set a password to also log in with your email or username.';

  @override
  String get profile => 'Profile';

  @override
  String get profileHint => 'Photo, username and password';

  @override
  String get profileDetails => 'Details';

  @override
  String get signInAndSecurity => 'Sign-in and security';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get bio => 'About you';

  @override
  String get phone => 'Phone';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'You can log in with it instead of your email.';

  @override
  String get usernameChecking => 'Checking…';

  @override
  String get usernameAvailable => 'Available';

  @override
  String get usernameTaken => 'Already taken';

  @override
  String get usernameInvalid => 'Use letters, numbers and . _ + - only';

  @override
  String get usernameYours => 'This is your username';

  @override
  String get usernameSuggestions => 'Free ones like it:';

  @override
  String get changeUsername => 'Change username';

  @override
  String get usernameChanged => 'Username changed.';

  @override
  String get confirmWithPassword =>
      'Enter your password to confirm this change.';

  @override
  String get confirmChange => 'Confirm';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get cropPhoto => 'Crop photo';

  @override
  String get photoUpdated => 'Profile photo updated.';

  @override
  String get photoRemoved => 'Profile photo removed.';

  @override
  String get plan => 'Plan';

  @override
  String get planYours => 'Your plan';

  @override
  String planUntil(String date) {
    return 'Until $date';
  }

  @override
  String get planGraceNote =>
      'Your payment is late. The plan stays on for a few more days.';

  @override
  String get planSeePlans => 'See plans';

  @override
  String get planUsage => 'What you are using';

  @override
  String planCountOf(int count, int limit) {
    return '$count of $limit';
  }

  @override
  String get planUnlimited => 'Unlimited';

  @override
  String planResetsOn(String date) {
    return 'Starts again on $date';
  }

  @override
  String get planRedeem => 'Redeem a code';

  @override
  String get planRedeemHint => 'Have a promo code? Enter it here.';

  @override
  String planCodeApplied(String plan) {
    return 'Code applied. You are on the $plan plan.';
  }

  @override
  String get planThrottled => 'Too many tries. Wait a while and try again.';

  @override
  String get planUpgradeTitle => 'Get more from Spendroo';

  @override
  String get planBuySoon =>
      'Buying a plan in the app is coming soon. If you have a code, use it below.';

  @override
  String get planSimulate => 'Simulate purchase (test build)';

  @override
  String get planSimulateExpire => 'End my plan now (test build)';

  @override
  String get planLoadFailed =>
      'Could not load the plans. Check your connection.';

  @override
  String get planOffers => 'Offers';

  @override
  String get planUpgrade => 'Upgrade';

  @override
  String planEverythingIn(String plan) {
    return 'Everything in $plan, and:';
  }

  @override
  String limitAccounts(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit accounts',
      one: '1 account',
    );
    return 'Your $plan plan allows $_temp0.';
  }

  @override
  String limitCategories(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit categories',
      one: '1 category',
    );
    return 'Your $plan plan allows $_temp0 of your own.';
  }

  @override
  String limitCashbooks(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit cashbooks',
      one: '1 cashbook',
    );
    return 'Your $plan plan allows $_temp0 in a business.';
  }

  @override
  String limitWorkspaces(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit businesses',
      one: '1 business',
      zero: 'no business',
    );
    return 'Your $plan plan allows $_temp0.';
  }

  @override
  String limitGeneric(String plan) {
    return 'Your $plan plan does not allow more of this.';
  }

  @override
  String limitFeature(String feature, String plan) {
    return '$feature is not part of your $plan plan.';
  }

  @override
  String limitLocked(String plan) {
    return 'This is read-only on your $plan plan. Upgrade, or choose what to keep.';
  }

  @override
  String limitQuota(String feature) {
    return 'This month\'s allowance is used up: $feature.';
  }

  @override
  String get featureAccounts => 'Accounts';

  @override
  String get featureCustomCategories => 'Categories of your own';

  @override
  String get featureBudgetMonthOverride => 'A different budget for one month';

  @override
  String get featureInsightsCustomRange => 'Insights for any dates';

  @override
  String get featureYearReview => 'Year in review';

  @override
  String get featureTrendMonths => 'Months of trends';

  @override
  String get featureRecurring => 'Recurring transactions and reminders';

  @override
  String get featureSavingsGoals => 'Savings goals';

  @override
  String get featureHomeWidget => 'Home screen widget';

  @override
  String get featureBusinesses => 'Businesses';

  @override
  String get featureCashbooks => 'Cashbooks in a business';

  @override
  String get featureTeamSeats => 'Team members';

  @override
  String get featureReportRange =>
      'Custom reports: any dates, types and categories';

  @override
  String get featureReportExport => 'Reports as Excel';

  @override
  String get featureAuditTrail => 'History of every change';

  @override
  String get featureCustomFields => 'Extra fields on entries';

  @override
  String get featureStorage => 'Storage for bills, in MB';

  @override
  String get featureAiCredits => 'AI credits a month';

  @override
  String get featurePdfPages => 'Statement pages read a month';

  @override
  String get featureDevices => 'Devices';

  @override
  String get featureNoAds => 'No ads';

  @override
  String get keepTitle => 'Choose what to keep';

  @override
  String get keepIntro =>
      'Your plan now allows fewer than you have. Choose the ones to go on editing. The rest stay safe and readable; nothing is deleted.';

  @override
  String keepChosen(int chosen, int limit) {
    return '$chosen of $limit chosen';
  }

  @override
  String get keepSave => 'Keep these';

  @override
  String get keepSaved => 'Saved. The others are read-only.';

  @override
  String keepChangeFrom(String date) {
    return 'You can change this again from $date.';
  }

  @override
  String get keepPendingNote =>
      'Until you choose, the oldest ones stay editable.';

  @override
  String get keepOnceNote =>
      'Choose with care: after saving, this cannot be changed for a while.';

  @override
  String get keepNothing =>
      'Nothing is locked. Everything you have fits your plan.';

  @override
  String keepIn(String feature, String workspace) {
    return '$feature in $workspace';
  }

  @override
  String keepLockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are read-only',
      one: '1 item is read-only',
    );
    return '$_temp0';
  }

  @override
  String get keepOffline => 'Connect to the internet to change this.';

  @override
  String get defaultTag => 'Default';

  @override
  String customCount(int count, int limit) {
    return 'Your own: $count of $limit';
  }

  @override
  String offerEnds(String date) {
    return 'Ends $date';
  }

  @override
  String get offerClaim => 'Get it';

  @override
  String get offerClaimed => 'It is yours now. Enjoy!';

  @override
  String get offerActive => 'On for you';

  @override
  String get lockedTag => 'Locked';

  @override
  String spendInsightTop(String name, String percent) {
    return '$name takes $percent% of what you spent.';
  }

  @override
  String spendInsightRise(String name, String percent) {
    return '$name is up $percent% on last month.';
  }

  @override
  String spendInsightRisePeriod(String name, String percent) {
    return '$name is up $percent% on the period before.';
  }

  @override
  String get spendTapHint => 'Tap a category for details';

  @override
  String shareOfSpending(String percent) {
    return '$percent% of spending';
  }

  @override
  String get statAverage => 'Average';

  @override
  String get statLargest => 'Largest';

  @override
  String moreCategories(String count) {
    return '$count more';
  }

  @override
  String get showLess => 'Show less';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodLast3Months => '3 months';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodAllTime => 'All time';

  @override
  String get periodCustom => 'Custom';

  @override
  String get chooseDates => 'Choose dates';

  @override
  String get backToMonths => 'Back to months';

  @override
  String get filters => 'Filters';

  @override
  String get applyFilters => 'Apply';

  @override
  String get resetFilters => 'Reset';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get insights => 'Insights';

  @override
  String get transfersIn => 'Transfers in';

  @override
  String get transfersOut => 'Transfers out';

  @override
  String transferTo(String account) {
    return 'To $account';
  }

  @override
  String transferFrom(String account) {
    return 'From $account';
  }

  @override
  String get closingBalance => 'Closing balance';

  @override
  String get balanceOverTime => 'Balance over time';

  @override
  String get cashInAndOut => 'Cash in and out';

  @override
  String get whereItWent => 'Where it went';

  @override
  String get whereItCameFrom => 'Where it came from';

  @override
  String get averagePerDay => 'Average per day';

  @override
  String get largestExpense => 'Largest expense';

  @override
  String get accountGone => 'This account is no longer here.';

  @override
  String get nothingInPeriod => 'Nothing in this period.';

  @override
  String get inAndOutDetails => 'In and out, in detail';

  @override
  String get reportDownload => 'Download report';

  @override
  String get reportTitlePersonal => 'Personal report';

  @override
  String get reportTitleAccount => 'Account statement';

  @override
  String get reportTitleCashbook => 'Cashbook report';

  @override
  String get reportTitleBusiness => 'Business report';

  @override
  String get reportCoversPersonal => 'All your personal accounts together.';

  @override
  String reportCoversAccount(String name) {
    return 'Only the account $name.';
  }

  @override
  String reportCoversCashbook(String name) {
    return 'Only the cashbook $name.';
  }

  @override
  String reportCoversBusiness(String name) {
    return 'Every cashbook of $name together.';
  }

  @override
  String get reportInside => 'What\'s inside';

  @override
  String get reportInsidePersonal1 =>
      'Opening and closing balance of every account';

  @override
  String get reportInsidePersonal2 => 'Income and spending by category';

  @override
  String get reportInsidePersonal3 =>
      'Every transaction, with transfers listed on their own';

  @override
  String get reportInsideAccount1 => 'Opening and closing balance';

  @override
  String get reportInsideAccount2 => 'Spending and income by category';

  @override
  String get reportInsideAccount3 =>
      'Every transaction, with the balance after it';

  @override
  String get reportInsideCashbook1 => 'Opening and closing balance';

  @override
  String get reportInsideCashbook2 =>
      'Totals by category and by payment method';

  @override
  String get reportInsideCashbook3 => 'Every entry, with the balance after it';

  @override
  String get reportInsideBusiness1 => 'Your cashbooks side by side';

  @override
  String get reportInsideBusiness2 =>
      'Totals by category and by payment method';

  @override
  String get reportInsideBusiness3 => 'Every entry of every cashbook';

  @override
  String get reportPeriod => 'Period';

  @override
  String get reportFileType => 'File type';

  @override
  String get reportPdfHint => 'Ready to read, print or share';

  @override
  String get reportExcelHint => 'A spreadsheet you can sort and add up';

  @override
  String get reportFree => 'Free';

  @override
  String get reportPaid => 'Paid plan';

  @override
  String get reportDownloadPdf => 'Download PDF';

  @override
  String get reportDownloadExcel => 'Download Excel';

  @override
  String get reportHint => 'Made online from everything you have saved.';

  @override
  String get reportOffline => 'Connect to the internet to download a report.';

  @override
  String reportTooLarge(int limit) {
    return 'This period has too many lines for one file (up to $limit). Choose a shorter period.';
  }

  @override
  String get reportFailed => 'The report could not be made. Try again.';

  @override
  String get reportThrottled =>
      'Too many downloads. Try again in a little while.';

  @override
  String get reportReady => 'Your report is ready';

  @override
  String reportReference(String reference) {
    return 'Reference $reference';
  }

  @override
  String get reportOpen => 'Open';

  @override
  String get reportShare => 'Share';

  @override
  String get reportNoApp =>
      'No app on this phone can open this file. Use Share or save.';

  @override
  String get reportAnother => 'Download another';

  @override
  String get reportCustomTitle => 'Custom report';

  @override
  String get reportCustomDates => 'Dates';

  @override
  String get reportCustomTypes => 'Type';

  @override
  String get reportCustomAllHint => 'Choose none to include all.';

  @override
  String get reportCustomNote =>
      'A filtered report adds up only the lines that match. It shows money in, money out and the difference, without opening or closing balances.';

  @override
  String reportSavedTo(String folder) {
    return 'Saved on your phone in $folder';
  }

  @override
  String get reportNotSaved =>
      'This phone has no Downloads folder the app can save to. Use Share to keep a copy.';

  @override
  String get edit => 'Edit';

  @override
  String savedPercent(String percent) {
    return 'Saved $percent%';
  }

  @override
  String get spendingPace => 'Spending pace';

  @override
  String spentSoFar(String amount) {
    return '$amount spent';
  }

  @override
  String paceLess(String amount) {
    return '$amount less than at this point the month before';
  }

  @override
  String paceMore(String amount) {
    return '$amount more than at this point the month before';
  }

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get monthEndForecast => 'By month end';

  @override
  String get biggestDay => 'Biggest day';

  @override
  String get noSpendDays => 'No-spend days';

  @override
  String get budgetEvenPace => 'Budget, spread evenly';

  @override
  String thatDay(String amount) {
    return '$amount that day';
  }

  @override
  String soFar(String amount) {
    return '$amount so far';
  }

  @override
  String get tapDayHint => 'Tap a day to see its transactions';

  @override
  String get budgetHealth => 'Budget health';

  @override
  String percentUsed(String percent) {
    return '$percent% used';
  }

  @override
  String get usedLabel => 'used';

  @override
  String get safePerDay => 'Safe per day';

  @override
  String get daysLeft => 'Days left';

  @override
  String keepsWithin(String amount) {
    return '$amount a day keeps you within it';
  }

  @override
  String keepsWithinBudget(String amount) {
    return '$amount a day keeps you within budget this month';
  }

  @override
  String get allBudgets => 'All budgets';

  @override
  String spentShare(String percent) {
    return 'Spent · $percent%';
  }

  @override
  String leftShare(String percent) {
    return 'Left · $percent%';
  }

  @override
  String overShare(String percent) {
    return 'Over · $percent%';
  }

  @override
  String limitAmount(String amount) {
    return 'Limit $amount';
  }

  @override
  String get verdictOnTrack => 'On track. Spending is behind the calendar.';

  @override
  String get verdictAhead => 'Spending is running ahead of the calendar.';

  @override
  String get verdictWithin => 'You stayed within the budget.';

  @override
  String get legendWithin => 'Within allowance';

  @override
  String get legendNear => 'A little over';

  @override
  String get legendOver => 'Far over';

  @override
  String get notBudgeted => 'No limit set';

  @override
  String get setLimit => 'Set limit';

  @override
  String get dayByDay => 'Day by day';

  @override
  String get seeTransactions => 'See transactions';

  @override
  String get noTransactionsHere => 'Nothing recorded here.';

  @override
  String get cashFlow => 'Cash flow';

  @override
  String savedInMonths(String saved, String months) {
    return 'Income beat spending in $saved of $months months.';
  }

  @override
  String get tapMonthHint => 'Tap a month for details';

  @override
  String goToMonth(String month) {
    return 'Go to $month';
  }

  @override
  String keptOfIncome(String percent) {
    return '$percent% of income kept';
  }

  @override
  String get spentMoreThanEarned => 'Spent more than came in';

  @override
  String get splitTitle => 'Split';

  @override
  String get splitAction => 'Split into categories';

  @override
  String get splitRemove => 'Remove split';

  @override
  String get splitAddPart => 'Add a part';

  @override
  String get splitEvenly => 'Share equally';

  @override
  String get splitDone => 'All of it is filed';

  @override
  String splitLeft(String amount) {
    return '$amount left to file';
  }

  @override
  String splitOver(String amount) {
    return '$amount more than the amount';
  }

  @override
  String splitMismatch(String amount) {
    return 'The parts must add up to $amount.';
  }

  @override
  String get splitNeedsAmounts => 'Give every part an amount.';

  @override
  String splitInParts(String count) {
    return 'Split in $count';
  }

  @override
  String get recurring => 'Recurring';

  @override
  String get recurringEmpty =>
      'Nothing repeats yet. Rent, salary, a bill: set it once and it comes round by itself.';

  @override
  String get newRecurring => 'Recurring transaction';

  @override
  String get newReminder => 'Reminder';

  @override
  String get editRecurring => 'Edit recurring transaction';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get repeatThis => 'Make this repeat';

  @override
  String get ruleTitle => 'Title';

  @override
  String get ruleTitleRequired => 'Give it a title.';

  @override
  String get repeats => 'Repeats';

  @override
  String get freqOptOnce => 'Does not repeat';

  @override
  String get freqOptDaily => 'Daily';

  @override
  String get freqOptWeekly => 'Weekly';

  @override
  String get freqOptMonthly => 'Monthly';

  @override
  String get freqOptYearly => 'Yearly';

  @override
  String get repeatEvery => 'Every';

  @override
  String get unitDays => 'days';

  @override
  String get unitWeeks => 'weeks';

  @override
  String get unitMonths => 'months';

  @override
  String get unitYears => 'years';

  @override
  String get freqOnce => 'Once';

  @override
  String get freqDaily => 'Every day';

  @override
  String freqDailyN(String n) {
    return 'Every $n days';
  }

  @override
  String get freqWeekly => 'Every week';

  @override
  String freqWeeklyN(String n) {
    return 'Every $n weeks';
  }

  @override
  String get freqMonthly => 'Every month';

  @override
  String freqMonthlyN(String n) {
    return 'Every $n months';
  }

  @override
  String get freqYearly => 'Every year';

  @override
  String freqYearlyN(String n) {
    return 'Every $n years';
  }

  @override
  String get monthlyOn => 'Falls on';

  @override
  String onDayOfMonth(String n) {
    return 'Day $n';
  }

  @override
  String get onLastDay => 'The last day';

  @override
  String get onWeekdayOfMonth => 'A weekday of the month';

  @override
  String theNthWeekday(String ordinal, String weekday) {
    return 'The $ordinal $weekday';
  }

  @override
  String get whichOne => 'Which';

  @override
  String get weekday => 'Weekday';

  @override
  String get ordinalFirst => 'first';

  @override
  String get ordinalSecond => 'second';

  @override
  String get ordinalThird => 'third';

  @override
  String get ordinalFourth => 'fourth';

  @override
  String get ordinalLast => 'last';

  @override
  String get startsOn => 'Starts on';

  @override
  String get ends => 'Ends';

  @override
  String get endsNever => 'Never';

  @override
  String get endsOnDate => 'On a date';

  @override
  String get endsAfterTimes => 'After a number of times';

  @override
  String get endsOn => 'Ends on';

  @override
  String get timesCount => 'How many times';

  @override
  String get numberRequired => 'Enter a number above zero.';

  @override
  String nextDates(String dates) {
    return 'Next: $dates';
  }

  @override
  String get noMoreDates => 'No date falls on this schedule.';

  @override
  String get recordAutomatically => 'Record automatically';

  @override
  String get recordAutomaticallyHint =>
      'Without it you are asked first, and can change the amount.';

  @override
  String get remindMe => 'Remind me';

  @override
  String get remindOnTheDay => 'On the day';

  @override
  String get remindDayBefore => 'The day before';

  @override
  String remindDaysBefore(String n) {
    return '$n days before';
  }

  @override
  String get remindAt => 'At';

  @override
  String get usualTime => 'The usual time';

  @override
  String get paused => 'Paused';

  @override
  String get pausedHint => 'Nothing falls due while it is paused.';

  @override
  String get ended => 'Ended';

  @override
  String nextOn(String date) {
    return 'Next: $date';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get waitingForYou => 'Waiting for you';

  @override
  String get comingUp => 'Coming up';

  @override
  String get everythingThatRepeats => 'Everything that repeats';

  @override
  String get recordIt => 'Record';

  @override
  String get skipIt => 'Skip';

  @override
  String get laterIt => 'Later';

  @override
  String get doneIt => 'Done';

  @override
  String get snoozeTomorrow => 'Tomorrow';

  @override
  String get snoozeThreeDays => 'In 3 days';

  @override
  String get snoozeWeek => 'In a week';

  @override
  String get deleteRuleConfirm =>
      'Delete this? What it has already recorded stays.';

  @override
  String get recordsItself => 'Recorded automatically';

  @override
  String get asksFirst => 'Asks first';

  @override
  String get weekStartsOn => 'Week starts on';

  @override
  String splitKept(String count) {
    return 'Split in $count, as in the transaction';
  }

  @override
  String get featureReminders => 'Reminders';

  @override
  String limitReminders(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit reminders',
      one: '1 reminder',
    );
    return 'Your $plan plan allows $_temp0 at a time.';
  }

  @override
  String get seeAllRecurring => 'See all';

  @override
  String get addRecurring => 'Add';

  @override
  String get inbox => 'Reminders';

  @override
  String get inboxEmpty =>
      'Nothing to tell you yet. What falls due, what was recorded for you and how your budgets are doing will show up here.';

  @override
  String get inboxEarlier => 'Earlier';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String inboxUpcoming(String title, String days) {
    return '$title is due in $days days';
  }

  @override
  String inboxUpcomingTomorrow(String title) {
    return '$title is due tomorrow';
  }

  @override
  String inboxDue(String title) {
    return '$title is due today';
  }

  @override
  String inboxOverdue(String title) {
    return '$title is still waiting';
  }

  @override
  String inboxPosted(String title) {
    return '$title was recorded';
  }

  @override
  String inboxIncomeComing(String title, String days) {
    return '$title is expected in $days days';
  }

  @override
  String inboxIncomeTomorrow(String title) {
    return '$title is expected tomorrow';
  }

  @override
  String inboxIncomeDue(String title) {
    return 'Has $title come in?';
  }

  @override
  String inboxBlocked(String title) {
    return '$title could not be recorded. Check its account.';
  }

  @override
  String inboxBudget80(String title, String percent) {
    return '$title: $percent% of the budget is spent';
  }

  @override
  String inboxBudgetOver(String title) {
    return '$title is over its budget';
  }

  @override
  String inboxBudgetDetail(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get untitledRule => 'A recurring transaction';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifAllow => 'Allow notifications';

  @override
  String get notifBlocked =>
      'This phone is not letting Spendroo show notifications.';

  @override
  String get notifBlockedHint =>
      'If nothing happens, allow them for Spendroo in the phone\'s settings.';

  @override
  String get notifPush => 'Push notifications';

  @override
  String get notifPushHint =>
      'Reminders reach this phone even when the app is closed.';

  @override
  String get notifWhat => 'What to tell you';

  @override
  String get notifBills => 'Bills and reminders';

  @override
  String get notifBillsHint => 'Coming up, due today and still waiting';

  @override
  String get notifIncome => 'Expected income';

  @override
  String get notifRecorded => 'Recorded for you';

  @override
  String get notifRecordedHint =>
      'When a recurring transaction is recorded, or could not be';

  @override
  String get notifBudgets => 'Budget alerts';

  @override
  String get notifBudgetsHint => 'At 80% of a budget, and when it is passed';

  @override
  String get notifNudge => 'Daily nudge';

  @override
  String get notifNudgeHint => 'On days you have written nothing down';

  @override
  String get notifNudgeTime => 'Nudge at';

  @override
  String get notifWhen => 'When';

  @override
  String get notifReminderTime => 'Remind me at';

  @override
  String get notifReminderTimeHint =>
      'For recurring transactions without a time of their own.';

  @override
  String get notifQuiet => 'Quiet hours';

  @override
  String get notifQuietHint =>
      'Nothing is sent between these hours. It waits until they end.';

  @override
  String get notifQuietFrom => 'From';

  @override
  String get notifQuietTo => 'Until';

  @override
  String get notifTest => 'Send a test notification';

  @override
  String get notifTestSent => 'Sent. It should arrive in a moment.';

  @override
  String get notifTestNoDevice =>
      'This phone is not registered for notifications yet. Check the connection and try again.';

  @override
  String get notifTestNotSetUp =>
      'The server is not set up to send notifications yet.';

  @override
  String get notifTestFailed => 'It could not be sent. Try again in a while.';

  @override
  String get nudgeTitle => 'Did you spend anything today?';

  @override
  String get nudgeBody => 'Write it down while you remember.';

  @override
  String get available => 'Available to spend';

  @override
  String get inGoals => 'In goals';

  @override
  String get netWorth => 'Net worth';

  @override
  String get goals => 'Savings goals';

  @override
  String get goalKind => 'Savings goal';

  @override
  String toGoal(String goal) {
    return 'To goal: $goal';
  }

  @override
  String fromGoal(String goal) {
    return 'From goal: $goal';
  }

  @override
  String get intoGoal => 'Saves into goal';

  @override
  String limitGoals(String plan, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit savings goals',
      one: '1 savings goal',
    );
    return 'Your $plan plan allows $_temp0 at a time. Archive one, or upgrade for more.';
  }

  @override
  String get notifGoals => 'Savings goals';

  @override
  String get notifGoalsHint =>
      'Each quarter of the way, falling behind, and a month with nothing saved';

  @override
  String get goalTemplateEmergency => 'Emergency fund';

  @override
  String get goalTemplateGadget => 'Gadget';

  @override
  String get goalTemplateTrip => 'Trip';

  @override
  String get goalTemplateFestival => 'Eid & festivals';

  @override
  String get goalTemplateEducation => 'Education';

  @override
  String get goalTemplateWedding => 'Wedding';

  @override
  String get goalTemplateVehicle => 'Vehicle';

  @override
  String get goalTemplateHome => 'Home';

  @override
  String get goalTemplateGift => 'Gift';

  @override
  String get goalTemplateCustom => 'Something else';

  @override
  String get goalOnTrack => 'On track';

  @override
  String get goalAhead => 'Ahead';

  @override
  String get goalBehind => 'Behind';

  @override
  String get goalNoDate => 'No date';

  @override
  String get goalReached => 'Reached';

  @override
  String get goalNew => 'New goal';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get goalCreate => 'Start saving';

  @override
  String get goalWhatFor => 'What are you saving for?';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalTarget => 'Target amount';

  @override
  String get goalHasDate => 'Set a target date';

  @override
  String get goalHasDateHint =>
      'Goals with a date are reached more often: you see each month what it takes';

  @override
  String get goalTargetDate => 'Reach it by';

  @override
  String get goalColour => 'Colour';

  @override
  String get goalPreviewNoDate => 'Add a date to see what it takes each month';

  @override
  String goalPreviewPace(String month, String week, String day) {
    return '≈ $month/month · $week/week · $day/day';
  }

  @override
  String goalEmergencySuggestion(String amount) {
    return 'Suggested: $amount, three months of your spending';
  }

  @override
  String goalSavedOf(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String goalOfTarget(String target) {
    return 'of $target';
  }

  @override
  String goalToGo(String amount) {
    return '$amount to go';
  }

  @override
  String goalLeft(String amount) {
    return '$amount left';
  }

  @override
  String goalBy(String date) {
    return 'by $date';
  }

  @override
  String goalPerWeekNeeded(String amount) {
    return '$amount/week needed';
  }

  @override
  String goalNextMilestone(String mark, String amount) {
    return 'Next: $mark% · $amount away';
  }

  @override
  String goalDaysEarly(String days) {
    return '$days days ahead';
  }

  @override
  String goalDaysLate(String days) {
    return '$days days behind';
  }

  @override
  String get goalAddMoney => 'Add money';

  @override
  String goalAddMoneyTo(String goal) {
    return 'Add money to $goal';
  }

  @override
  String get goalWithdraw => 'Withdraw';

  @override
  String get goalUseMoney => 'Use the money';

  @override
  String get goalKeepSaving => 'Keep saving';

  @override
  String get goalAutoSave => 'Auto-save';

  @override
  String goalAutoSaveTitle(String goal) {
    return 'Save for $goal';
  }

  @override
  String get goalAuto => 'Auto-saved';

  @override
  String get goalRestore => 'Bring back';

  @override
  String get goalGone => 'This goal no longer exists.';

  @override
  String get goalDeleteHasMoney =>
      'Take the money out first, so none of it is lost from sight.';

  @override
  String goalDeleteConfirm(String goal) {
    return 'Delete $goal? Its history goes with it.';
  }

  @override
  String get goalLockedNote =>
      'Your plan keeps this goal read-only: nothing more goes in, but you can always take the money out.';

  @override
  String goalNoAccountInCurrency(String currency) {
    return 'You have no account in $currency to move money with.';
  }

  @override
  String goalMoreThanBalance(String account) {
    return 'That is more than $account holds; its balance goes below zero.';
  }

  @override
  String get goalQuickNeeded => 'This month\'s share';

  @override
  String get goalQuickTenth => '10% of income';

  @override
  String get goalQuickRest => 'All that\'s left';

  @override
  String get goalEnterAmount => 'Enter an amount';

  @override
  String get goalTrajectory => 'How it is going';

  @override
  String get goalTargetLine => 'Target';

  @override
  String get goalLegendSaved => 'Saved';

  @override
  String get goalLegendSteady => 'Steady pace';

  @override
  String get goalLegendForecast => 'At your pace';

  @override
  String get goalLegendMilestone => 'Milestones';

  @override
  String get goalPace => 'Pace';

  @override
  String get goalNeededMonthly => 'Needed / month';

  @override
  String get goalYourAverage => 'You average';

  @override
  String get goalSoFar => 'So far';

  @override
  String get goalPaceTooEarly =>
      'After a month of saving, this shows when you\'ll get there.';

  @override
  String get goalForecast => 'You\'ll finish';

  @override
  String get goalPaceNothingYet =>
      'Once money goes in, this shows when you\'ll get there.';

  @override
  String goalPaceEarly(String date) {
    return 'At your pace you get there around $date, in time.';
  }

  @override
  String goalPaceLate(String date, String needed) {
    return 'At your pace you get there around $date, after your date. $needed a month makes it in time.';
  }

  @override
  String goalPaceNoDate(String amount, String date) {
    return 'At $amount a month you get there around $date.';
  }

  @override
  String get goalWhatIf => 'What if I saved…';

  @override
  String goalWhatIfResult(String amount, String date) {
    return '$amount a month → done by $date';
  }

  @override
  String get goalWhatIfNever => 'Move the slider to see when you\'d get there.';

  @override
  String get goalWhatIfAutoSave => 'Save this every month';

  @override
  String get goalMonthly => 'Month by month';

  @override
  String goalStreak(String months) {
    return '$months months in a row';
  }

  @override
  String get goalMilestones => 'Milestones';

  @override
  String get goalSources => 'Where it came from';

  @override
  String get goalHistory => 'History';

  @override
  String get goalNoMoves => 'Nothing saved yet. The first step is the biggest.';

  @override
  String goalMoveIn(String account) {
    return 'From $account';
  }

  @override
  String goalMoveOut(String account) {
    return 'To $account';
  }

  @override
  String get goalUndoMove =>
      'Take this back? Both sides of the transfer are deleted.';

  @override
  String goalHalfway(String goal) {
    return 'Halfway to $goal!';
  }

  @override
  String goalMilestoneReached(String mark, String goal) {
    return '$mark% of the way to $goal!';
  }

  @override
  String get goalReachedTitle => 'Goal reached!';

  @override
  String goalReachedBody(String goal, String amount) {
    return 'You saved $amount for $goal.';
  }

  @override
  String get goalReachedDays => 'Days it took';

  @override
  String get goalReachedTimes => 'Times you saved';

  @override
  String goalsSummary(String saved, String target, String count) {
    return '$saved of $target across $count goals';
  }

  @override
  String goalsThisMonth(String amount) {
    return '$amount this month';
  }

  @override
  String goalsSavingRate(String percent) {
    return 'You save $percent% of income';
  }

  @override
  String get goalsHeaderEmpty => 'Money you set aside shows here.';

  @override
  String get goalsReachedSection => 'Reached';

  @override
  String goalsArchivedSection(String count) {
    return 'Archived ($count)';
  }

  @override
  String get goalsEmptyTitle => 'Give your money a job';

  @override
  String get goalsEmptyBody =>
      'Set money aside for what matters. It leaves what you can spend, so you are not tempted, and it is yours to take back anytime.';

  @override
  String get goalsHowTitle => 'How goals work';

  @override
  String get goalsHowSetAside => 'Money is set aside';

  @override
  String get goalsHowSetAsideBody =>
      'Adding money moves it out of an account into the goal. It is no longer in \'Available to spend\', but it still counts in your net worth.';

  @override
  String get goalsHowDate => 'A date makes it real';

  @override
  String get goalsHowDateBody =>
      'With a date you see what each month needs, and whether you are on track.';

  @override
  String get goalsHowFirst => 'Pay yourself first';

  @override
  String get goalsHowFirstBody =>
      'Saving right after payday, on a schedule, works better than saving what is left at the month\'s end.';

  @override
  String get goalsHowWithdraw => 'Yours, anytime';

  @override
  String get goalsHowWithdrawBody =>
      'To spend goal money, take it out into an account first. It is never locked away, just one deliberate step further.';

  @override
  String insightBehind(String goal, String amount, String perWeek) {
    return '$goal is $amount behind. Adding $perWeek a week gets it back on track.';
  }

  @override
  String insightStreak(String months, String goal) {
    return 'You saved for $goal $months months in a row. Keep the streak going!';
  }

  @override
  String insightCutBack(
    String category,
    String amount,
    String goal,
    int count,
    String weeks,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$weeks weeks',
      one: 'a week',
    );
    return 'You spent $amount on $category this month. Half of that would bring $goal $_temp0 sooner.';
  }

  @override
  String insightPayday(String goal) {
    return 'You usually save for $goal right after payday. Let it happen on its own every month?';
  }

  @override
  String insightBestMonth(String amount) {
    return 'You moved $amount into goals this month, your best month yet.';
  }

  @override
  String get insightEmergency =>
      'No emergency fund yet. Most advice says to keep three to six months of spending for the unexpected.';

  @override
  String get insightEmergencyAction => 'Start one';

  @override
  String withdrawTitle(String goal) {
    return 'Take money out of $goal?';
  }

  @override
  String get withdrawReachedTitle => 'Use the money 🎉';

  @override
  String withdrawFinishMoves(String from, String to) {
    return 'Your finish date moves from $from to $to.';
  }

  @override
  String withdrawSetsBack(String amount) {
    return 'This sets your goal back by $amount.';
  }

  @override
  String withdrawAll(String amount) {
    return 'All of it: $amount';
  }

  @override
  String get withdrawWhy => 'Why? (optional)';

  @override
  String get withdrawEmergency => 'Emergency';

  @override
  String get withdrawReached => 'Reached my goal';

  @override
  String get withdrawChangedPlans => 'Changed plans';

  @override
  String get withdrawOther => 'Other';

  @override
  String withdrawConfirm(String amount) {
    return 'Withdraw $amount';
  }

  @override
  String withdrawMove(String amount) {
    return 'Move $amount to the account';
  }

  @override
  String withdrawTooMuch(String amount) {
    return 'The goal holds $amount.';
  }

  @override
  String withdrawNote(String percent) {
    return 'You are $percent% of the way. The money goes back as a transfer you can see in both places.';
  }

  @override
  String inboxGoalMilestone(String percent, String title) {
    return '$percent% of the way to $title';
  }

  @override
  String inboxGoalReached(String title) {
    return 'You reached $title!';
  }

  @override
  String inboxGoalBehind(String title) {
    return '$title is falling behind';
  }

  @override
  String inboxGoalIdle(String title, String days) {
    return 'Nothing put into $title for $days days';
  }

  @override
  String inboxGoalDetail(String saved, String target) {
    return '$saved of $target saved';
  }

  @override
  String inboxGoalNeeded(String amount) {
    return '$amount a month gets it back on track';
  }

  @override
  String get planner => 'Planner';

  @override
  String get goalsShort => 'Goals';

  @override
  String get saveKind => 'Save';

  @override
  String get goalPick => 'Choose a goal';

  @override
  String get goalStartFirst => 'Start your first goal';

  @override
  String get goalNewShort => 'New';

  @override
  String goalsBehindCount(String count) {
    return '$count behind';
  }

  @override
  String goalsSavedTotal(String amount) {
    return '$amount saved';
  }

  @override
  String get goalsInviteBody =>
      'Set money aside for something that matters. Tap to start a goal.';

  @override
  String goalsKeptAside(int n, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$count goals, kept apart from what you spend',
      one: '1 goal, kept apart from what you spend',
    );
    return '$_temp0';
  }

  @override
  String goalsShareOfWorth(String percent) {
    return '$percent of what you own is set aside for goals';
  }

  @override
  String get goalAccountLocked =>
      'This account is read-only on your plan. Choose another to save from.';
}
