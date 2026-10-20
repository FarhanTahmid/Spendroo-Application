// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'স্পেন্ড্রু';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get newPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get logIn => 'লগ ইন';

  @override
  String get signUp => 'অ্যাকাউন্ট খুলুন';

  @override
  String get noAccount => 'নতুন এসেছেন? অ্যাকাউন্ট খুলুন';

  @override
  String get haveAccount => 'আগে থেকেই অ্যাকাউন্ট আছে? লগ ইন করুন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get continueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get googleSignInFailed =>
      'Google দিয়ে সাইন ইন করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get tagline => 'আপনার টাকা আর আপনার দোকান, এক অ্যাপে।';

  @override
  String get enterEmail => 'সঠিক ইমেইল লিখুন';

  @override
  String get passwordTooShort => 'কমপক্ষে ৮টি অক্ষর দিন';

  @override
  String get verifyEmailTitle => 'আপনার ইমেইল দেখুন';

  @override
  String codeSentTo(String email) {
    return '$email ঠিকানায় একটি কোড পাঠানো হয়েছে। নিচে লিখুন।';
  }

  @override
  String get code => 'কোড';

  @override
  String get verify => 'যাচাই করুন';

  @override
  String get resendCode => 'কোড আবার পাঠান';

  @override
  String get codeResent => 'নতুন কোড পাঠানো হয়েছে।';

  @override
  String get useAnotherAccount => 'অন্য অ্যাকাউন্ট ব্যবহার করুন';

  @override
  String get resetPasswordTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get resetPasswordHint => 'আপনার ইমেইল লিখুন, আমরা একটি কোড পাঠাব।';

  @override
  String get sendCode => 'কোড পাঠান';

  @override
  String get setNewPassword => 'নতুন পাসওয়ার্ড দিন';

  @override
  String get passwordChanged =>
      'পাসওয়ার্ড বদলানো হয়েছে। নতুন পাসওয়ার্ড দিয়ে লগ ইন করুন।';

  @override
  String get offlineError =>
      'ইন্টারনেট সংযোগ নেই। অনলাইনে এসে আবার চেষ্টা করুন।';

  @override
  String get welcomeTitle => 'স্পেন্ড্রু কীভাবে ব্যবহার করবেন?';

  @override
  String get forMyself => 'নিজের জন্য';

  @override
  String get forMyselfHint => 'অ্যাকাউন্ট, খরচ আর বাজেটের হিসাব রাখুন।';

  @override
  String get forMyBusiness => 'ব্যবসার জন্য';

  @override
  String get forMyBusinessHint => 'দোকান বা ব্যবসার ক্যাশবুক রাখুন।';

  @override
  String get tryDemo => 'ডেমো ব্যবসা দেখুন';

  @override
  String get tryDemoHint => 'কয়েক সপ্তাহের হিসাবসহ একটি নমুনা দোকান।';

  @override
  String get businessName => 'ব্যবসার নাম';

  @override
  String get createBusiness => 'ব্যবসা তৈরি করুন';

  @override
  String get needsConnection => 'এর জন্য ইন্টারনেট সংযোগ লাগবে।';

  @override
  String get personal => 'ব্যক্তিগত';

  @override
  String get business => 'ব্যবসা';

  @override
  String get demo => 'ডেমো';

  @override
  String get switchWorkspace => 'ওয়ার্কস্পেস বদলান';

  @override
  String get newBusiness => 'নতুন ব্যবসা';

  @override
  String get deleteWorkspace => 'এই ব্যবসা মুছুন';

  @override
  String get deleteWorkspaceConfirm =>
      'এই ব্যবসা ও এর সব ক্যাশবুক মুছে ফেলবেন?';

  @override
  String get overview => 'সারসংক্ষেপ';

  @override
  String get transactions => 'লেনদেন';

  @override
  String get budgets => 'বাজেট';

  @override
  String get accounts => 'অ্যাকাউন্ট';

  @override
  String get cashbooks => 'ক্যাশবুক';

  @override
  String get settings => 'সেটিংস';

  @override
  String get totalBalance => 'মোট ব্যালেন্স';

  @override
  String get thisMonth => 'এই মাস';

  @override
  String get income => 'আয়';

  @override
  String get expense => 'খরচ';

  @override
  String get transfer => 'স্থানান্তর';

  @override
  String get spendingByCategory => 'খাত অনুযায়ী খরচ';

  @override
  String get noSpendingYet => 'এই মাসে এখনো কোনো খরচ নেই।';

  @override
  String get uncategorised => 'খাত ছাড়া';

  @override
  String get addTransaction => 'লেনদেন যোগ করুন';

  @override
  String get editTransaction => 'লেনদেন সম্পাদনা';

  @override
  String get noTransactions => 'এখনো কোনো লেনদেন নেই। প্রথমটি যোগ করুন।';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get amountInvalid => 'শূন্যের বেশি পরিমাণ লিখুন';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get fromAccount => 'যে অ্যাকাউন্ট থেকে';

  @override
  String get toAccount => 'যে অ্যাকাউন্টে';

  @override
  String get category => 'খাত';

  @override
  String get none => 'নেই';

  @override
  String get date => 'তারিখ';

  @override
  String get note => 'নোট';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get deleteConfirm => 'এটি মুছে ফেলবেন?';

  @override
  String get sameAccountError => 'দুটি আলাদা অ্যাকাউন্ট বেছে নিন';

  @override
  String get currencyMismatch => 'দুই অ্যাকাউন্টের মুদ্রা একই হতে হবে';

  @override
  String get addAccount => 'অ্যাকাউন্ট যোগ করুন';

  @override
  String get editAccount => 'অ্যাকাউন্ট সম্পাদনা';

  @override
  String get accountName => 'অ্যাকাউন্টের নাম';

  @override
  String get accountKind => 'ধরন';

  @override
  String get kindCash => 'নগদ';

  @override
  String get kindBank => 'ব্যাংক';

  @override
  String get kindSavings => 'সঞ্চয়';

  @override
  String get kindMobileMoney => 'মোবাইল ব্যাংকিং';

  @override
  String get kindCard => 'কার্ড';

  @override
  String get currency => 'মুদ্রা';

  @override
  String get defaultCurrency => 'ডিফল্ট মুদ্রা';

  @override
  String get defaultCurrencyHint =>
      'নতুন অ্যাকাউন্ট, ক্যাশবুক ও বাজেট এই মুদ্রায় শুরু হবে, মোট হিসাবও এতে দেখাবে। আগের গুলো নিজের মুদ্রায় থাকবে।';

  @override
  String get currencyFixedHint => 'তৈরি করার পর মুদ্রা আর বদলানো যাবে না।';

  @override
  String get keypadClear => 'মুছুন';

  @override
  String get keypadBackspace => 'শেষেরটি মুছুন';

  @override
  String get keypadDone => 'হয়ে গেছে';

  @override
  String get openingBalance => 'প্রারম্ভিক ব্যালেন্স';

  @override
  String get nameRequired => 'নাম লিখুন';

  @override
  String get archive => 'আর্কাইভ';

  @override
  String get archived => 'আর্কাইভ করা';

  @override
  String get addBudget => 'বাজেট যোগ করুন';

  @override
  String get monthlyLimit => 'মাসিক সীমা';

  @override
  String get noBudgets =>
      'এখনো কোনো বাজেট নেই। কোনো খাতের মাসিক সীমা ঠিক করুন।';

  @override
  String spentOf(String spent, String limit) {
    return '$limit এর মধ্যে $spent';
  }

  @override
  String get overBudget => 'বাজেট ছাড়িয়েছে';

  @override
  String get newCategory => 'নতুন খাত';

  @override
  String get categoryName => 'খাতের নাম';

  @override
  String get addCashbook => 'ক্যাশবুক যোগ করুন';

  @override
  String get cashbookName => 'ক্যাশবুকের নাম';

  @override
  String get noCashbooks =>
      'এখনো কোনো ক্যাশবুক নেই। নগদের হিসাব শুরু করতে একটি যোগ করুন।';

  @override
  String get balance => 'ব্যালেন্স';

  @override
  String get cashIn => 'জমা';

  @override
  String get cashOut => 'খরচ';

  @override
  String get totalIn => 'মোট জমা';

  @override
  String get totalOut => 'মোট খরচ';

  @override
  String get noEntries =>
      'এখনো কোনো এন্ট্রি নেই। নিচের জমা বা খরচ বোতাম ব্যবহার করুন।';

  @override
  String get title => 'শিরোনাম';

  @override
  String get remarks => 'মন্তব্য';

  @override
  String get paymentMethod => 'পরিশোধের মাধ্যম';

  @override
  String get newPaymentMethod => 'নতুন পরিশোধের মাধ্যম';

  @override
  String get editEntry => 'এন্ট্রি সম্পাদনা';

  @override
  String get rename => 'নাম বদলান';

  @override
  String get report => 'রিপোর্ট';

  @override
  String get byCategory => 'খাত অনুযায়ী';

  @override
  String get byPaymentMethod => 'পরিশোধের মাধ্যম অনুযায়ী';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি এন্ট্রি',
      zero: 'কোনো এন্ট্রি নেই',
    );
    return '$_temp0';
  }

  @override
  String get readOnly => 'আপনি এই ক্যাশবুক দেখতে পারবেন, বদলাতে পারবেন না।';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get sync => 'সিঙ্ক';

  @override
  String get syncNow => 'এখনই সিঙ্ক করুন';

  @override
  String get syncing => 'সিঙ্ক হচ্ছে…';

  @override
  String get allSynced => 'সবকিছু ক্লাউডে সংরক্ষিত আছে';

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিবর্তন সিঙ্কের অপেক্ষায়',
    );
    return '$_temp0';
  }

  @override
  String get offlineStatus =>
      'অফলাইন। পরিবর্তনগুলো এই ডিভাইসে রাখা আছে, পরে সিঙ্ক হবে।';

  @override
  String syncError(String message) {
    return 'সিঙ্কে সমস্যা: $message';
  }

  @override
  String get notSynced => 'সিঙ্ক হয়নি';

  @override
  String get notSyncedHint =>
      'সার্ভার এই পরিবর্তনগুলো গ্রহণ করেনি, তাই এই ডিভাইসে সেগুলো বাতিল করা হয়েছে।';

  @override
  String get dismiss => 'সরান';

  @override
  String get logOut => 'লগ আউট';

  @override
  String get logOutConfirm =>
      'লগ আউট করবেন? এই ডিভাইসের তথ্য মুছে যাবে; যা সিঙ্ক হয়েছে তা আপনার অ্যাকাউন্টে থাকবে।';

  @override
  String logOutUnsynced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পরিবর্তন সিঙ্ক হয়নি এবং হারিয়ে যাবে।',
    );
    return '$_temp0';
  }

  @override
  String get previousMonth => 'আগের মাস';

  @override
  String get nextMonth => 'পরের মাস';

  @override
  String get budgetThisMonth => 'এই মাসের বাজেট';

  @override
  String get spent => 'খরচ হয়েছে';

  @override
  String get remaining => 'বাকি';

  @override
  String get dailyAllowance => 'দৈনিক সীমা';

  @override
  String perDay(String amount) {
    return 'দিনে $amount';
  }

  @override
  String get thisMonthOnly => 'শুধু এই মাসে';

  @override
  String get thisMonthOnlyHint => 'অন্য মাসে সাধারণ সীমাই থাকবে।';

  @override
  String usualLimit(String amount) {
    return 'সাধারণ সীমা: $amount';
  }

  @override
  String get useUsualLimit => 'সাধারণ সীমা ব্যবহার করুন';

  @override
  String get noTransactionsOnDay => 'এই দিনে কিছু লেখা নেই।';

  @override
  String get categories => 'খাতসমূহ';

  @override
  String get noCategories => 'এখনো কোনো খাত নেই।';

  @override
  String get editCategory => 'খাত সম্পাদনা';

  @override
  String get colour => 'রং';

  @override
  String get automaticColour => 'স্বয়ংক্রিয়';

  @override
  String get customColour => 'নিজের রং';

  @override
  String get colourHue => 'রঙের ধরন';

  @override
  String get colourShade => 'গাঢ়তা';

  @override
  String deleteCategoryConfirm(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি লেনদেন খাত ছাড়া থেকে যাবে, আর এর বাজেট মুছে যাবে।',
      zero: 'এর বাজেটও মুছে যাবে।',
    );
    return '\"$name\" মুছবেন? $_temp0';
  }

  @override
  String get net => 'নিট';

  @override
  String get netRemaining => 'নিট অবশিষ্ট ব্যালেন্স';

  @override
  String lastMonthsCount(int count) {
    return 'গত $count মাস';
  }

  @override
  String monthsShort(String count) {
    return '$count মাস';
  }

  @override
  String get trendLength => 'যত মাস দেখানো হচ্ছে';

  @override
  String showingLatestMonths(String months) {
    return 'সর্বশেষ $months মাস দেখানো হচ্ছে। আগের মাসগুলো দেখতে আপগ্রেড করুন।';
  }

  @override
  String changeVsLastMonth(String percent) {
    return 'গত মাসের তুলনায় $percent%';
  }

  @override
  String get newThisMonth => 'এই মাসে নতুন';

  @override
  String changeVsPeriodBefore(String percent) {
    return 'আগের সময়ের তুলনায় $percent%';
  }

  @override
  String get newThisPeriod => 'এই সময়ে নতুন';

  @override
  String get accountBalances => 'অ্যাকাউন্টের ব্যালেন্স';

  @override
  String get shareOfTotalBalance =>
      'শতাংশ দেখায় মোট ব্যালেন্সের কত অংশ প্রতিটি অ্যাকাউন্টে আছে।';

  @override
  String get server => 'সার্ভার';

  @override
  String get serverHint =>
      'এই টেস্ট বিল্ড যে স্পেন্ড্রু সার্ভারের সাথে কথা বলে তার ঠিকানা।';

  @override
  String get serverChangeConfirm =>
      'সার্ভার বদলাবেন? আপনি লগ আউট হবেন এবং এই ডিভাইসের তথ্য মুছে যাবে।';

  @override
  String get serverInvalid =>
      'http:// বা https:// দিয়ে শুরু হওয়া ঠিকানা লিখুন';

  @override
  String get resetToDefault => 'আগের অবস্থায় ফেরান';

  @override
  String version(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get sendFeedback => 'মতামত পাঠান';

  @override
  String get sendFeedbackHint => 'কী ভালো লাগছে আর কী লাগছে না, জানান।';

  @override
  String get needsConnectionRetry =>
      'এর জন্য ইন্টারনেট সংযোগ লাগবে। অনলাইনে এসে আবার চেষ্টা করুন।';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get search => 'খুঁজুন';

  @override
  String get searchTransactions => 'নোট, খাত বা পরিমাণ দিয়ে খুঁজুন';

  @override
  String get searchOrCreate => 'খুঁজুন বা নতুন নাম লিখুন';

  @override
  String get filterAll => 'সব';

  @override
  String noResultsFor(String query) {
    return '\"$query\" এর সাথে কিছু মেলেনি।';
  }

  @override
  String get noMatches => 'কিছু মেলেনি।';

  @override
  String createNamed(String name) {
    return '\"$name\" তৈরি করুন';
  }

  @override
  String get today => 'আজ';

  @override
  String get yesterday => 'গতকাল';

  @override
  String paceLeft(String amount) {
    return 'খরচের জন্য বাকি $amount';
  }

  @override
  String paceOver(String amount) {
    return 'বাজেটের চেয়ে $amount বেশি';
  }

  @override
  String get emailOrUsername => 'ইমেইল বা ইউজারনেম';

  @override
  String get enterEmailOrUsername => 'আপনার ইমেইল বা ইউজারনেম দিন';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get confirmNewPassword => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get passwordsDontMatch => 'পাসওয়ার্ড দুটি মেলেনি';

  @override
  String get currentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get enterCurrentPassword => 'আপনার বর্তমান পাসওয়ার্ড দিন';

  @override
  String get passwordSameAsCurrent =>
      'বর্তমান পাসওয়ার্ড থেকে আলাদা একটি পাসওয়ার্ড বেছে নিন';

  @override
  String get passwordUpdated => 'পাসওয়ার্ড হালনাগাদ হয়েছে।';

  @override
  String get changePassword => 'পাসওয়ার্ড বদলান';

  @override
  String get setPassword => 'পাসওয়ার্ড সেট করুন';

  @override
  String get setPasswordHint =>
      'আপনি Google দিয়ে সাইন ইন করেছেন। ইমেইল বা ইউজারনেম দিয়েও লগ ইন করতে একটি পাসওয়ার্ড সেট করুন।';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get profileHint => 'ছবি, ইউজারনেম ও পাসওয়ার্ড';

  @override
  String get profileDetails => 'বিবরণ';

  @override
  String get signInAndSecurity => 'সাইন-ইন ও নিরাপত্তা';

  @override
  String get firstName => 'নামের প্রথম অংশ';

  @override
  String get lastName => 'নামের শেষ অংশ';

  @override
  String get bio => 'আপনার সম্পর্কে';

  @override
  String get phone => 'ফোন';

  @override
  String get profileSaved => 'প্রোফাইল সংরক্ষণ হয়েছে।';

  @override
  String get username => 'ইউজারনেম';

  @override
  String get usernameHint => 'ইমেইলের বদলে এটি দিয়েও লগ ইন করতে পারবেন।';

  @override
  String get usernameChecking => 'যাচাই করা হচ্ছে…';

  @override
  String get usernameAvailable => 'পাওয়া যাচ্ছে';

  @override
  String get usernameTaken => 'আগেই কেউ নিয়েছে';

  @override
  String get usernameInvalid => 'শুধু অক্ষর, সংখ্যা এবং . _ + - ব্যবহার করুন';

  @override
  String get usernameYours => 'এটি আপনার ইউজারনেম';

  @override
  String get usernameSuggestions => 'এর মতো খালি ইউজারনেম:';

  @override
  String get changeUsername => 'ইউজারনেম বদলান';

  @override
  String get usernameChanged => 'ইউজারনেম বদলানো হয়েছে।';

  @override
  String get confirmWithPassword =>
      'এই পরিবর্তন নিশ্চিত করতে আপনার পাসওয়ার্ড দিন।';

  @override
  String get confirmChange => 'নিশ্চিত করুন';

  @override
  String get changePhoto => 'ছবি বদলান';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get removePhoto => 'ছবি সরান';

  @override
  String get cropPhoto => 'ছবি ক্রপ করুন';

  @override
  String get photoUpdated => 'প্রোফাইল ছবি হালনাগাদ হয়েছে।';

  @override
  String get photoRemoved => 'প্রোফাইল ছবি সরানো হয়েছে।';

  @override
  String get plan => 'প্ল্যান';

  @override
  String get planYours => 'আপনার প্ল্যান';

  @override
  String planUntil(String date) {
    return '$date পর্যন্ত';
  }

  @override
  String get planGraceNote =>
      'পেমেন্ট বাকি আছে। প্ল্যানটি আর কয়েক দিন চালু থাকবে।';

  @override
  String get planSeePlans => 'প্ল্যানগুলো দেখুন';

  @override
  String get planUsage => 'আপনি যা ব্যবহার করছেন';

  @override
  String planCountOf(int count, int limit) {
    return '$limit-এর মধ্যে $count';
  }

  @override
  String get planUnlimited => 'সীমাহীন';

  @override
  String planResetsOn(String date) {
    return '$date তারিখে নতুন করে শুরু';
  }

  @override
  String get planRedeem => 'কোড ব্যবহার করুন';

  @override
  String get planRedeemHint => 'প্রোমো কোড আছে? এখানে লিখুন।';

  @override
  String planCodeApplied(String plan) {
    return 'কোড যোগ হয়েছে। আপনি $plan প্ল্যানে আছেন।';
  }

  @override
  String get planThrottled =>
      'অনেকবার চেষ্টা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';

  @override
  String get planUpgradeTitle => 'Spendroo থেকে আরও বেশি নিন';

  @override
  String get planBuySoon =>
      'অ্যাপ থেকে প্ল্যান কেনার সুবিধা শিগগিরই আসছে। কোড থাকলে নিচে ব্যবহার করুন।';

  @override
  String get planSimulate => 'কেনার পরীক্ষা (টেস্ট বিল্ড)';

  @override
  String get planSimulateExpire => 'আমার প্ল্যান এখনই শেষ করুন (টেস্ট বিল্ড)';

  @override
  String get planLoadFailed =>
      'প্ল্যানগুলো আনা যায়নি। ইন্টারনেট সংযোগ দেখে নিন।';

  @override
  String get planOffers => 'অফার';

  @override
  String get planUpgrade => 'আপগ্রেড';

  @override
  String planEverythingIn(String plan) {
    return '$plan প্ল্যানের সবকিছু, সঙ্গে:';
  }

  @override
  String limitAccounts(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে $limitটি অ্যাকাউন্ট রাখা যায়।';
  }

  @override
  String limitCategories(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে নিজের $limitটি খাত রাখা যায়।';
  }

  @override
  String limitCashbooks(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে একটি ব্যবসায় $limitটি ক্যাশবুক রাখা যায়।';
  }

  @override
  String limitWorkspaces(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে $limitটি ব্যবসা রাখা যায়।';
  }

  @override
  String limitGeneric(String plan) {
    return 'আপনার $plan প্ল্যানে এটি আর বাড়ানো যায় না।';
  }

  @override
  String limitFeature(String feature, String plan) {
    return '$feature আপনার $plan প্ল্যানে নেই।';
  }

  @override
  String limitLocked(String plan) {
    return 'আপনার $plan প্ল্যানে এটি শুধু দেখা যায়। আপগ্রেড করুন, অথবা কোনগুলো রাখবেন তা বেছে নিন।';
  }

  @override
  String limitQuota(String feature) {
    return 'এ মাসের বরাদ্দ শেষ: $feature।';
  }

  @override
  String get featureAccounts => 'অ্যাকাউন্ট';

  @override
  String get featureCustomCategories => 'নিজের খাত';

  @override
  String get featureBudgetMonthOverride => 'এক মাসের জন্য আলাদা বাজেট';

  @override
  String get featureInsightsCustomRange => 'যেকোনো তারিখের বিশ্লেষণ';

  @override
  String get featureYearReview => 'বছরের সারসংক্ষেপ';

  @override
  String get featureTrendMonths => 'যত মাসের ধারা দেখা যায়';

  @override
  String get featureRecurring => 'নিয়মিত লেনদেন ও রিমাইন্ডার';

  @override
  String get featureSavingsGoals => 'সঞ্চয়ের লক্ষ্য';

  @override
  String get featureHomeWidget => 'হোম স্ক্রিন উইজেট';

  @override
  String get featureBusinesses => 'ব্যবসার সংখ্যা';

  @override
  String get featureCashbooks => 'প্রতি ব্যবসায় ক্যাশবুক';

  @override
  String get featureTeamSeats => 'দলের সদস্য';

  @override
  String get featureReportRange =>
      'কাস্টম রিপোর্ট: যেকোনো তারিখ, ধরন ও ক্যাটাগরি';

  @override
  String get featureReportExport => 'Excel রিপোর্ট';

  @override
  String get featureAuditTrail => 'প্রতিটি পরিবর্তনের ইতিহাস';

  @override
  String get featureCustomFields => 'এন্ট্রিতে বাড়তি ঘর';

  @override
  String get featureStorage => 'বিল রাখার জায়গা, MB';

  @override
  String get featureAiCredits => 'মাসে AI ক্রেডিট';

  @override
  String get featurePdfPages => 'মাসে স্টেটমেন্টের যত পাতা পড়া যায়';

  @override
  String get featureDevices => 'ডিভাইস';

  @override
  String get featureNoAds => 'বিজ্ঞাপন নেই';

  @override
  String get keepTitle => 'কোনগুলো রাখবেন বেছে নিন';

  @override
  String get keepIntro =>
      'আপনার প্ল্যানে এখন আপনার যা আছে তার চেয়ে কম রাখা যায়। যেগুলোতে কাজ চালিয়ে যাবেন সেগুলো বেছে নিন। বাকিগুলো নিরাপদ থাকবে ও দেখা যাবে; কিছুই মুছে যাবে না।';

  @override
  String keepChosen(int chosen, int limit) {
    return '$limit-এর মধ্যে $chosenটি বাছা হয়েছে';
  }

  @override
  String get keepSave => 'এগুলো রাখুন';

  @override
  String get keepSaved => 'সেভ হয়েছে। বাকিগুলো শুধু দেখা যাবে।';

  @override
  String keepChangeFrom(String date) {
    return '$date থেকে আবার বদলাতে পারবেন।';
  }

  @override
  String get keepPendingNote =>
      'আপনি না বাছা পর্যন্ত সবচেয়ে পুরোনোগুলোতে কাজ করা যাবে।';

  @override
  String get keepOnceNote =>
      'ভেবে বাছুন: সেভ করার পর কিছুদিন এটি বদলানো যাবে না।';

  @override
  String get keepNothing => 'কিছুই লক নেই। আপনার সবকিছু প্ল্যানের মধ্যেই আছে।';

  @override
  String keepIn(String feature, String workspace) {
    return '$workspace: $feature';
  }

  @override
  String keepLockedCount(int count) {
    return '$countটি শুধু দেখা যাচ্ছে';
  }

  @override
  String get keepOffline => 'এটি বদলাতে ইন্টারনেটে যুক্ত হোন।';

  @override
  String get defaultTag => 'ডিফল্ট';

  @override
  String customCount(int count, int limit) {
    return 'নিজের: $limit-এর মধ্যে $count';
  }

  @override
  String offerEnds(String date) {
    return '$date তারিখে শেষ';
  }

  @override
  String get offerClaim => 'নিয়ে নিন';

  @override
  String get offerClaimed => 'এখন এটি আপনার। উপভোগ করুন!';

  @override
  String get offerActive => 'আপনার জন্য চালু';

  @override
  String get lockedTag => 'লক করা';

  @override
  String spendInsightTop(String name, String percent) {
    return 'আপনার খরচের $percent% গেছে $name খাতে।';
  }

  @override
  String spendInsightRise(String name, String percent) {
    return 'গত মাসের তুলনায় $name খাতে খরচ $percent% বেড়েছে।';
  }

  @override
  String spendInsightRisePeriod(String name, String percent) {
    return 'আগের সময়ের তুলনায় $name খাতে খরচ $percent% বেড়েছে।';
  }

  @override
  String get spendTapHint => 'বিস্তারিত দেখতে কোনো খাতে ট্যাপ করুন';

  @override
  String shareOfSpending(String percent) {
    return 'মোট খরচের $percent%';
  }

  @override
  String get statAverage => 'গড়';

  @override
  String get statLargest => 'সর্বোচ্চ';

  @override
  String moreCategories(String count) {
    return 'আরও $countটি খাত';
  }

  @override
  String get showLess => 'কম দেখান';

  @override
  String get currentBalance => 'বর্তমান ব্যালেন্স';

  @override
  String get periodLastMonth => 'গত মাস';

  @override
  String get periodLast3Months => '৩ মাস';

  @override
  String get periodThisYear => 'এই বছর';

  @override
  String get periodAllTime => 'সব সময়';

  @override
  String get periodCustom => 'নিজে বাছুন';

  @override
  String get chooseDates => 'তারিখ বেছে নিন';

  @override
  String get backToMonths => 'মাসে ফিরে যান';

  @override
  String get filters => 'ফিল্টার';

  @override
  String get applyFilters => 'প্রয়োগ করুন';

  @override
  String get resetFilters => 'মুছে দিন';

  @override
  String get clearFilters => 'ফিল্টার সরান';

  @override
  String get insights => 'বিশ্লেষণ';

  @override
  String get transfersIn => 'স্থানান্তর হয়ে এসেছে';

  @override
  String get transfersOut => 'স্থানান্তর হয়ে গেছে';

  @override
  String transferTo(String account) {
    return '$account-এ';
  }

  @override
  String transferFrom(String account) {
    return '$account থেকে';
  }

  @override
  String get closingBalance => 'সমাপনী ব্যালেন্স';

  @override
  String get balanceOverTime => 'সময়ের সাথে ব্যালেন্স';

  @override
  String get cashInAndOut => 'জমা ও খরচ';

  @override
  String get whereItWent => 'কোথায় গেল';

  @override
  String get whereItCameFrom => 'কোথা থেকে এল';

  @override
  String get averagePerDay => 'দৈনিক গড়';

  @override
  String get largestExpense => 'সবচেয়ে বড় খরচ';

  @override
  String get accountGone => 'এই অ্যাকাউন্টটি আর নেই।';

  @override
  String get nothingInPeriod => 'এই সময়ে কোনো লেনদেন নেই।';

  @override
  String get inAndOutDetails => 'জমা ও খরচের বিস্তারিত';

  @override
  String get reportDownload => 'রিপোর্ট ডাউনলোড';

  @override
  String get reportTitlePersonal => 'ব্যক্তিগত রিপোর্ট';

  @override
  String get reportTitleAccount => 'অ্যাকাউন্ট স্টেটমেন্ট';

  @override
  String get reportTitleCashbook => 'ক্যাশবুক রিপোর্ট';

  @override
  String get reportTitleBusiness => 'ব্যবসার রিপোর্ট';

  @override
  String get reportCoversPersonal => 'আপনার সব ব্যক্তিগত অ্যাকাউন্ট একসাথে।';

  @override
  String reportCoversAccount(String name) {
    return 'শুধু $name অ্যাকাউন্ট।';
  }

  @override
  String reportCoversCashbook(String name) {
    return 'শুধু $name ক্যাশবুক।';
  }

  @override
  String reportCoversBusiness(String name) {
    return '$name-এর সব ক্যাশবুক একসাথে।';
  }

  @override
  String get reportInside => 'যা যা থাকবে';

  @override
  String get reportInsidePersonal1 =>
      'প্রতিটি অ্যাকাউন্টের শুরুর ও শেষ ব্যালেন্স';

  @override
  String get reportInsidePersonal2 => 'ক্যাটাগরি অনুযায়ী আয় ও খরচ';

  @override
  String get reportInsidePersonal3 => 'সব লেনদেন, ট্রান্সফার আলাদা করে';

  @override
  String get reportInsideAccount1 => 'শুরুর ও শেষ ব্যালেন্স';

  @override
  String get reportInsideAccount2 => 'ক্যাটাগরি অনুযায়ী খরচ ও আয়';

  @override
  String get reportInsideAccount3 => 'সব লেনদেন, প্রতিটির পরের ব্যালেন্সসহ';

  @override
  String get reportInsideCashbook1 => 'শুরুর ও শেষ ব্যালেন্স';

  @override
  String get reportInsideCashbook2 => 'ক্যাটাগরি ও পেমেন্ট পদ্ধতি অনুযায়ী মোট';

  @override
  String get reportInsideCashbook3 => 'সব এন্ট্রি, প্রতিটির পরের ব্যালেন্সসহ';

  @override
  String get reportInsideBusiness1 => 'আপনার ক্যাশবুকগুলো পাশাপাশি';

  @override
  String get reportInsideBusiness2 => 'ক্যাটাগরি ও পেমেন্ট পদ্ধতি অনুযায়ী মোট';

  @override
  String get reportInsideBusiness3 => 'প্রতিটি ক্যাশবুকের সব এন্ট্রি';

  @override
  String get reportPeriod => 'সময়কাল';

  @override
  String get reportFileType => 'ফাইলের ধরন';

  @override
  String get reportPdfHint => 'পড়া, প্রিন্ট বা শেয়ার করার জন্য তৈরি';

  @override
  String get reportExcelHint => 'স্প্রেডশিট, যা সাজানো ও যোগ করা যায়';

  @override
  String get reportFree => 'ফ্রি';

  @override
  String get reportPaid => 'পেইড প্ল্যান';

  @override
  String get reportDownloadPdf => 'PDF ডাউনলোড';

  @override
  String get reportDownloadExcel => 'Excel ডাউনলোড';

  @override
  String get reportHint => 'আপনার সেভ করা সব তথ্য থেকে অনলাইনে তৈরি হয়।';

  @override
  String get reportOffline => 'রিপোর্ট ডাউনলোড করতে ইন্টারনেটে যুক্ত হোন।';

  @override
  String reportTooLarge(int limit) {
    return 'এই সময়কালে এক ফাইলের জন্য অনেক বেশি লাইন (সর্বোচ্চ $limit)। আরও ছোট সময়কাল বেছে নিন।';
  }

  @override
  String get reportFailed => 'রিপোর্ট তৈরি করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get reportThrottled =>
      'অনেকবার ডাউনলোড হয়েছে। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get reportReady => 'আপনার রিপোর্ট তৈরি';

  @override
  String reportReference(String reference) {
    return 'রেফারেন্স $reference';
  }

  @override
  String get reportOpen => 'খুলুন';

  @override
  String get reportShare => 'শেয়ার';

  @override
  String get reportNoApp =>
      'এই ফোনের কোনো অ্যাপ ফাইলটি খুলতে পারছে না। শেয়ার বা সেভ ব্যবহার করুন।';

  @override
  String get reportAnother => 'আরেকটি ডাউনলোড';

  @override
  String get reportCustomTitle => 'কাস্টম রিপোর্ট';

  @override
  String get reportCustomDates => 'তারিখ';

  @override
  String get reportCustomTypes => 'ধরন';

  @override
  String get reportCustomAllHint => 'সব রাখতে কোনোটি বেছে নেবেন না।';

  @override
  String get reportCustomNote =>
      'ফিল্টার করা রিপোর্টে শুধু যে লাইনগুলো মেলে সেগুলো যোগ হয়। এতে টাকা এসেছে, টাকা গেছে ও পার্থক্য দেখায়, শুরুর বা শেষ ব্যালেন্স থাকে না।';

  @override
  String reportSavedTo(String folder) {
    return 'আপনার ফোনে $folder ফোল্ডারে সেভ হয়েছে';
  }

  @override
  String get reportNotSaved =>
      'এই ফোনে অ্যাপ সেভ করতে পারে এমন Downloads ফোল্ডার নেই। কপি রাখতে শেয়ার ব্যবহার করুন।';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String savedPercent(String percent) {
    return 'সঞ্চয় $percent%';
  }

  @override
  String get spendingPace => 'খরচের গতি';

  @override
  String spentSoFar(String amount) {
    return '$amount খরচ হয়েছে';
  }

  @override
  String paceLess(String amount) {
    return 'আগের মাসের এই সময়ের চেয়ে $amount কম';
  }

  @override
  String paceMore(String amount) {
    return 'আগের মাসের এই সময়ের চেয়ে $amount বেশি';
  }

  @override
  String get dailyAverage => 'দৈনিক গড়';

  @override
  String get monthEndForecast => 'মাস শেষে';

  @override
  String get biggestDay => 'সবচেয়ে বেশি খরচের দিন';

  @override
  String get noSpendDays => 'খরচহীন দিন';

  @override
  String get budgetEvenPace => 'বাজেট, সমানভাবে ভাগ করা';

  @override
  String thatDay(String amount) {
    return 'সেদিন $amount';
  }

  @override
  String soFar(String amount) {
    return 'এ পর্যন্ত $amount';
  }

  @override
  String get tapDayHint => 'লেনদেন দেখতে একটি দিনে চাপ দিন';

  @override
  String get budgetHealth => 'বাজেটের অবস্থা';

  @override
  String percentUsed(String percent) {
    return '$percent% ব্যবহৃত';
  }

  @override
  String get usedLabel => 'ব্যবহৃত';

  @override
  String get safePerDay => 'দিনপ্রতি নিরাপদ';

  @override
  String get daysLeft => 'বাকি দিন';

  @override
  String keepsWithin(String amount) {
    return 'দিনে $amount খরচ করলে সীমার মধ্যে থাকবেন';
  }

  @override
  String keepsWithinBudget(String amount) {
    return 'এ মাসে দিনে $amount খরচ করলে বাজেটের মধ্যে থাকবেন';
  }

  @override
  String get allBudgets => 'সব বাজেট';

  @override
  String spentShare(String percent) {
    return 'খরচ · $percent%';
  }

  @override
  String leftShare(String percent) {
    return 'বাকি · $percent%';
  }

  @override
  String overShare(String percent) {
    return 'অতিরিক্ত · $percent%';
  }

  @override
  String limitAmount(String amount) {
    return 'সীমা $amount';
  }

  @override
  String get verdictOnTrack => 'ঠিক পথে আছেন। খরচ মাসের গতির চেয়ে কম।';

  @override
  String get verdictAhead => 'খরচ মাসের গতির চেয়ে দ্রুত হচ্ছে।';

  @override
  String get verdictWithin => 'আপনি বাজেটের মধ্যে ছিলেন।';

  @override
  String get legendWithin => 'বরাদ্দের মধ্যে';

  @override
  String get legendNear => 'কিছুটা বেশি';

  @override
  String get legendOver => 'অনেক বেশি';

  @override
  String get notBudgeted => 'সীমা নেই';

  @override
  String get setLimit => 'সীমা দিন';

  @override
  String get dayByDay => 'দিন অনুযায়ী';

  @override
  String get seeTransactions => 'লেনদেন দেখুন';

  @override
  String get noTransactionsHere => 'এখানে কিছু লেখা হয়নি।';

  @override
  String get cashFlow => 'আয়-ব্যয়ের ধারা';

  @override
  String savedInMonths(String saved, String months) {
    return '$months মাসের মধ্যে $saved মাসে আয় খরচের চেয়ে বেশি ছিল।';
  }

  @override
  String get tapMonthHint => 'বিস্তারিত দেখতে একটি মাসে চাপ দিন';

  @override
  String goToMonth(String month) {
    return '$month-এ যান';
  }

  @override
  String keptOfIncome(String percent) {
    return 'আয়ের $percent% জমা আছে';
  }

  @override
  String get spentMoreThanEarned => 'আয়ের চেয়ে খরচ বেশি';

  @override
  String get splitTitle => 'ভাগ';

  @override
  String get splitAction => 'কয়েকটি ক্যাটাগরিতে ভাগ করুন';

  @override
  String get splitRemove => 'ভাগ বাদ দিন';

  @override
  String get splitAddPart => 'আরেকটি অংশ';

  @override
  String get splitEvenly => 'সমান ভাগ';

  @override
  String get splitDone => 'পুরোটা ভাগ হয়েছে';

  @override
  String splitLeft(String amount) {
    return '$amount ভাগ করা বাকি';
  }

  @override
  String splitOver(String amount) {
    return 'মোট টাকার চেয়ে $amount বেশি';
  }

  @override
  String splitMismatch(String amount) {
    return 'অংশগুলোর যোগফল $amount হতে হবে।';
  }

  @override
  String get splitNeedsAmounts => 'প্রতিটি অংশে টাকার পরিমাণ দিন।';

  @override
  String splitInParts(String count) {
    return '$count ভাগে';
  }

  @override
  String get recurring => 'নিয়মিত';

  @override
  String get recurringEmpty =>
      'এখনও কিছু নিয়মিত নেই। ভাড়া, বেতন, বিল: একবার ঠিক করে দিন, সময়মতো নিজেই চলে আসবে।';

  @override
  String get newRecurring => 'নিয়মিত লেনদেন';

  @override
  String get newReminder => 'রিমাইন্ডার';

  @override
  String get editRecurring => 'নিয়মিত লেনদেন বদলান';

  @override
  String get editReminder => 'রিমাইন্ডার বদলান';

  @override
  String get repeatThis => 'এটি নিয়মিত করুন';

  @override
  String get ruleTitle => 'শিরোনাম';

  @override
  String get ruleTitleRequired => 'একটি শিরোনাম দিন।';

  @override
  String get repeats => 'কত দিন পরপর';

  @override
  String get freqOptOnce => 'একবারই';

  @override
  String get freqOptDaily => 'প্রতিদিন';

  @override
  String get freqOptWeekly => 'প্রতি সপ্তাহে';

  @override
  String get freqOptMonthly => 'প্রতি মাসে';

  @override
  String get freqOptYearly => 'প্রতি বছরে';

  @override
  String get repeatEvery => 'প্রতি';

  @override
  String get unitDays => 'দিন';

  @override
  String get unitWeeks => 'সপ্তাহ';

  @override
  String get unitMonths => 'মাস';

  @override
  String get unitYears => 'বছর';

  @override
  String get freqOnce => 'একবার';

  @override
  String get freqDaily => 'প্রতিদিন';

  @override
  String freqDailyN(String n) {
    return 'প্রতি $n দিনে';
  }

  @override
  String get freqWeekly => 'প্রতি সপ্তাহে';

  @override
  String freqWeeklyN(String n) {
    return 'প্রতি $n সপ্তাহে';
  }

  @override
  String get freqMonthly => 'প্রতি মাসে';

  @override
  String freqMonthlyN(String n) {
    return 'প্রতি $n মাসে';
  }

  @override
  String get freqYearly => 'প্রতি বছরে';

  @override
  String freqYearlyN(String n) {
    return 'প্রতি $n বছরে';
  }

  @override
  String get monthlyOn => 'কোন দিনে';

  @override
  String onDayOfMonth(String n) {
    return '$n তারিখ';
  }

  @override
  String get onLastDay => 'মাসের শেষ দিন';

  @override
  String get onWeekdayOfMonth => 'মাসের একটি বার';

  @override
  String theNthWeekday(String ordinal, String weekday) {
    return '$ordinal $weekday';
  }

  @override
  String get whichOne => 'কোনটি';

  @override
  String get weekday => 'বার';

  @override
  String get ordinalFirst => 'প্রথম';

  @override
  String get ordinalSecond => 'দ্বিতীয়';

  @override
  String get ordinalThird => 'তৃতীয়';

  @override
  String get ordinalFourth => 'চতুর্থ';

  @override
  String get ordinalLast => 'শেষ';

  @override
  String get startsOn => 'শুরু';

  @override
  String get ends => 'শেষ হবে';

  @override
  String get endsNever => 'কখনও না';

  @override
  String get endsOnDate => 'একটি তারিখে';

  @override
  String get endsAfterTimes => 'নির্দিষ্ট সংখ্যক বারের পর';

  @override
  String get endsOn => 'শেষ তারিখ';

  @override
  String get timesCount => 'কত বার';

  @override
  String get numberRequired => 'শূন্যের বেশি একটি সংখ্যা দিন।';

  @override
  String nextDates(String dates) {
    return 'এরপর: $dates';
  }

  @override
  String get noMoreDates => 'এই নিয়মে কোনো তারিখ পড়ে না।';

  @override
  String get recordAutomatically => 'নিজে থেকেই লিখে রাখুন';

  @override
  String get recordAutomaticallyHint =>
      'এটি বন্ধ থাকলে আগে আপনাকে জিজ্ঞেস করা হবে, আর পরিমাণ বদলানো যাবে।';

  @override
  String get remindMe => 'মনে করিয়ে দিন';

  @override
  String get remindOnTheDay => 'সেই দিনে';

  @override
  String get remindDayBefore => 'আগের দিন';

  @override
  String remindDaysBefore(String n) {
    return '$n দিন আগে';
  }

  @override
  String get remindAt => 'সময়';

  @override
  String get usualTime => 'সাধারণ সময়ে';

  @override
  String get paused => 'বন্ধ রাখা';

  @override
  String get pausedHint => 'বন্ধ থাকা অবস্থায় কিছুই আসবে না।';

  @override
  String get ended => 'শেষ হয়েছে';

  @override
  String nextOn(String date) {
    return 'এরপর: $date';
  }

  @override
  String dueOn(String date) {
    return 'তারিখ $date';
  }

  @override
  String get waitingForYou => 'আপনার অপেক্ষায়';

  @override
  String get comingUp => 'সামনে আসছে';

  @override
  String get everythingThatRepeats => 'যা যা নিয়মিত';

  @override
  String get recordIt => 'লিখে রাখুন';

  @override
  String get skipIt => 'বাদ দিন';

  @override
  String get laterIt => 'পরে';

  @override
  String get doneIt => 'হয়ে গেছে';

  @override
  String get snoozeTomorrow => 'আগামীকাল';

  @override
  String get snoozeThreeDays => '৩ দিন পর';

  @override
  String get snoozeWeek => 'এক সপ্তাহ পর';

  @override
  String get deleteRuleConfirm =>
      'এটি মুছবেন? আগে যা লেখা হয়েছে তা থেকে যাবে।';

  @override
  String get recordsItself => 'নিজে থেকেই লেখা হয়';

  @override
  String get asksFirst => 'আগে জিজ্ঞেস করে';

  @override
  String get weekStartsOn => 'সপ্তাহ শুরু';

  @override
  String splitKept(String count) {
    return 'লেনদেনের মতোই $count ভাগে';
  }

  @override
  String get featureReminders => 'রিমাইন্ডারসমূহ';

  @override
  String limitReminders(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে একসাথে $limitটি রিমাইন্ডার রাখা যায়।';
  }

  @override
  String get seeAllRecurring => 'সব দেখুন';

  @override
  String get addRecurring => 'যোগ করুন';

  @override
  String get inbox => 'রিমাইন্ডার';

  @override
  String get inboxEmpty =>
      'এখনও জানানোর মতো কিছু নেই। কোনটির সময় হয়েছে, আপনার হয়ে কী লেখা হয়েছে আর বাজেটের অবস্থা কেমন, সব এখানে দেখা যাবে।';

  @override
  String get inboxEarlier => 'আগের';

  @override
  String get markAllRead => 'সব পড়া হয়েছে';

  @override
  String inboxUpcoming(String title, String days) {
    return '$title: আর $days দিন বাকি';
  }

  @override
  String inboxUpcomingTomorrow(String title) {
    return '$title: আগামীকাল';
  }

  @override
  String inboxDue(String title) {
    return '$title: আজ দেওয়ার দিন';
  }

  @override
  String inboxOverdue(String title) {
    return '$title এখনও বাকি আছে';
  }

  @override
  String inboxPosted(String title) {
    return '$title লেখা হয়েছে';
  }

  @override
  String inboxIncomeComing(String title, String days) {
    return '$title আসার কথা $days দিন পর';
  }

  @override
  String inboxIncomeTomorrow(String title) {
    return '$title আসার কথা আগামীকাল';
  }

  @override
  String inboxIncomeDue(String title) {
    return '$title কি এসেছে?';
  }

  @override
  String inboxBlocked(String title) {
    return '$title লেখা যায়নি। এর অ্যাকাউন্টটি দেখুন।';
  }

  @override
  String inboxBudget80(String title, String percent) {
    return '$title: বাজেটের $percent% খরচ হয়েছে';
  }

  @override
  String inboxBudgetOver(String title) {
    return '$title: বাজেট পেরিয়ে গেছে';
  }

  @override
  String inboxBudgetDetail(String spent, String limit) {
    return '$limit-এর মধ্যে $spent';
  }

  @override
  String get untitledRule => 'একটি নিয়মিত লেনদেন';

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get notifAllow => 'নোটিফিকেশনের অনুমতি দিন';

  @override
  String get notifBlocked => 'এই ফোন Spendroo-কে নোটিফিকেশন দেখাতে দিচ্ছে না।';

  @override
  String get notifBlockedHint =>
      'কিছু না হলে ফোনের সেটিংস থেকে Spendroo-র নোটিফিকেশন চালু করুন।';

  @override
  String get notifPush => 'পুশ নোটিফিকেশন';

  @override
  String get notifPushHint => 'অ্যাপ বন্ধ থাকলেও রিমাইন্ডার এই ফোনে পৌঁছাবে।';

  @override
  String get notifWhat => 'কী জানাব';

  @override
  String get notifBills => 'বিল ও রিমাইন্ডার';

  @override
  String get notifBillsHint => 'সামনে আসছে, আজ দেওয়ার দিন আর এখনও বাকি';

  @override
  String get notifIncome => 'প্রত্যাশিত আয়';

  @override
  String get notifRecorded => 'আপনার হয়ে লেখা';

  @override
  String get notifRecordedHint => 'নিয়মিত লেনদেন লেখা হলে, বা লেখা না গেলে';

  @override
  String get notifBudgets => 'বাজেট সতর্কতা';

  @override
  String get notifBudgetsHint => 'বাজেটের ৮০% খরচ হলে, আর পেরিয়ে গেলে';

  @override
  String get notifNudge => 'প্রতিদিনের তাগাদা';

  @override
  String get notifNudgeHint => 'যেদিন কিছুই লেখা হয়নি';

  @override
  String get notifNudgeTime => 'তাগাদার সময়';

  @override
  String get notifWhen => 'কখন';

  @override
  String get notifReminderTime => 'মনে করানোর সময়';

  @override
  String get notifReminderTimeHint =>
      'যে নিয়মিত লেনদেনের নিজের সময় ঠিক করা নেই, তার জন্য।';

  @override
  String get notifQuiet => 'নীরব সময়';

  @override
  String get notifQuietHint =>
      'এই সময়ের মধ্যে কিছু পাঠানো হয় না। সময় শেষ হলে পাঠানো হয়।';

  @override
  String get notifQuietFrom => 'থেকে';

  @override
  String get notifQuietTo => 'পর্যন্ত';

  @override
  String get notifTest => 'পরীক্ষামূলক নোটিফিকেশন পাঠান';

  @override
  String get notifTestSent => 'পাঠানো হয়েছে। একটু পরেই পৌঁছানোর কথা।';

  @override
  String get notifTestNoDevice =>
      'এই ফোন এখনও নোটিফিকেশনের জন্য নিবন্ধিত হয়নি। সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get notifTestNotSetUp =>
      'সার্ভার এখনও নোটিফিকেশন পাঠানোর জন্য প্রস্তুত নয়।';

  @override
  String get notifTestFailed => 'পাঠানো যায়নি। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get nudgeTitle => 'আজ কিছু খরচ করেছেন?';

  @override
  String get nudgeBody => 'মনে থাকতে থাকতে লিখে রাখুন।';

  @override
  String get available => 'খরচযোগ্য';

  @override
  String get inGoals => 'লক্ষ্যে জমা';

  @override
  String get netWorth => 'মোট সম্পদ';

  @override
  String get goals => 'সঞ্চয়ের লক্ষ্য';

  @override
  String get goalKind => 'সঞ্চয়ের লক্ষ্য';

  @override
  String toGoal(String goal) {
    return 'লক্ষ্যে জমা: $goal';
  }

  @override
  String fromGoal(String goal) {
    return 'লক্ষ্য থেকে: $goal';
  }

  @override
  String get intoGoal => 'যে লক্ষ্যে জমা হবে';

  @override
  String limitGoals(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে একসাথে $limitটি সঞ্চয়ের লক্ষ্য রাখা যায়। একটি আর্কাইভ করুন, বা আরও পেতে আপগ্রেড করুন।';
  }

  @override
  String limitTrendMonths(String plan, int limit) {
    return 'আপনার $plan প্ল্যানে গত $limit মাসের ধারা দেখা যায়। আরও আগের মাস দেখতে আপগ্রেড করুন।';
  }

  @override
  String get notifGoals => 'সঞ্চয়ের লক্ষ্য';

  @override
  String get notifGoalsHint =>
      'প্রতি চার ভাগের এক ভাগ পূরণ, পিছিয়ে পড়া, আর এক মাস কিছু না জমালে';

  @override
  String get goalTemplateEmergency => 'জরুরি তহবিল';

  @override
  String get goalTemplateGadget => 'গ্যাজেট';

  @override
  String get goalTemplateTrip => 'ভ্রমণ';

  @override
  String get goalTemplateFestival => 'ঈদ ও উৎসব';

  @override
  String get goalTemplateEducation => 'পড়াশোনা';

  @override
  String get goalTemplateWedding => 'বিয়ে';

  @override
  String get goalTemplateVehicle => 'যানবাহন';

  @override
  String get goalTemplateHome => 'বাড়ি';

  @override
  String get goalTemplateGift => 'উপহার';

  @override
  String get goalTemplateCustom => 'অন্য কিছু';

  @override
  String get goalOnTrack => 'ঠিক পথে';

  @override
  String get goalAhead => 'এগিয়ে';

  @override
  String get goalBehind => 'পিছিয়ে';

  @override
  String get goalNoDate => 'তারিখ নেই';

  @override
  String get goalReached => 'পূরণ হয়েছে';

  @override
  String get goalNew => 'নতুন লক্ষ্য';

  @override
  String get goalEdit => 'লক্ষ্য বদলান';

  @override
  String get goalCreate => 'জমানো শুরু করুন';

  @override
  String get goalWhatFor => 'কীসের জন্য জমাচ্ছেন?';

  @override
  String get goalName => 'লক্ষ্যের নাম';

  @override
  String get goalTarget => 'লক্ষ্যের পরিমাণ';

  @override
  String get goalHasDate => 'লক্ষ্যের তারিখ দিন';

  @override
  String get goalHasDateHint =>
      'তারিখসহ লক্ষ্য বেশি পূরণ হয়: প্রতি মাসে কত লাগবে তা দেখা যায়';

  @override
  String get goalTargetDate => 'যে তারিখের মধ্যে';

  @override
  String get goalColour => 'রং';

  @override
  String get goalPreviewNoDate => 'প্রতি মাসে কত লাগবে দেখতে তারিখ দিন';

  @override
  String goalPreviewPace(String month, String week, String day) {
    return '≈ মাসে $month · সপ্তাহে $week · দিনে $day';
  }

  @override
  String goalEmergencySuggestion(String amount) {
    return 'পরামর্শ: $amount, আপনার তিন মাসের খরচ';
  }

  @override
  String goalSavedOf(String saved, String target) {
    return '$target-এর মধ্যে $saved';
  }

  @override
  String goalOfTarget(String target) {
    return '$target-এর মধ্যে';
  }

  @override
  String goalToGo(String amount) {
    return 'আর $amount বাকি';
  }

  @override
  String goalLeft(String amount) {
    return '$amount বাকি';
  }

  @override
  String goalBy(String date) {
    return '$date-এর মধ্যে';
  }

  @override
  String goalPerWeekNeeded(String amount) {
    return 'সপ্তাহে $amount দরকার';
  }

  @override
  String goalNextMilestone(String mark, String amount) {
    return 'পরের ধাপ: $mark% · আর $amount';
  }

  @override
  String goalDaysEarly(String days) {
    return '$days দিন এগিয়ে';
  }

  @override
  String goalDaysLate(String days) {
    return '$days দিন পিছিয়ে';
  }

  @override
  String get goalAddMoney => 'টাকা জমান';

  @override
  String goalAddMoneyTo(String goal) {
    return '$goal-এ টাকা জমান';
  }

  @override
  String get goalWithdraw => 'তুলুন';

  @override
  String get goalUseMoney => 'টাকাটা কাজে লাগান';

  @override
  String get goalKeepSaving => 'জমানো চালিয়ে যান';

  @override
  String get goalAutoSave => 'নিয়মিত জমা';

  @override
  String goalAutoSaveTitle(String goal) {
    return '$goal-এর জন্য জমা';
  }

  @override
  String get goalAuto => 'নিজে থেকে জমা';

  @override
  String get goalRestore => 'ফিরিয়ে আনুন';

  @override
  String get goalGone => 'এই লক্ষ্যটি আর নেই।';

  @override
  String get goalDeleteHasMoney =>
      'আগে টাকাটা তুলে নিন, যাতে কোনো টাকা চোখের আড়ালে না যায়।';

  @override
  String goalDeleteConfirm(String goal) {
    return '$goal মুছবেন? এর ইতিহাসও মুছে যাবে।';
  }

  @override
  String get goalLockedNote =>
      'আপনার প্ল্যানে এই লক্ষ্যটি শুধু দেখা যায়: নতুন জমা হবে না, তবে টাকা সবসময় তুলতে পারবেন।';

  @override
  String goalNoAccountInCurrency(String currency) {
    return 'টাকা আনা-নেওয়ার জন্য $currency-এ কোনো অ্যাকাউন্ট নেই।';
  }

  @override
  String goalMoreThanBalance(String account) {
    return 'এটা $account-এ যা আছে তার চেয়ে বেশি; ব্যালেন্স শূন্যের নিচে যাবে।';
  }

  @override
  String get goalQuickNeeded => 'এ মাসের ভাগ';

  @override
  String get goalQuickTenth => 'আয়ের ১০%';

  @override
  String get goalQuickRest => 'বাকি সবটা';

  @override
  String get goalEnterAmount => 'পরিমাণ লিখুন';

  @override
  String get goalTrajectory => 'কেমন চলছে';

  @override
  String get goalTargetLine => 'লক্ষ্য';

  @override
  String get goalLegendSaved => 'জমা';

  @override
  String get goalLegendSteady => 'সমান গতিতে';

  @override
  String get goalLegendForecast => 'আপনার গতিতে';

  @override
  String get goalLegendMilestone => 'ধাপ';

  @override
  String get goalPace => 'গতি';

  @override
  String get goalNeededMonthly => 'মাসে দরকার';

  @override
  String get goalYourAverage => 'আপনার গড়';

  @override
  String get goalSoFar => 'এ পর্যন্ত';

  @override
  String get goalPaceTooEarly => 'এক মাস জমানোর পর এখানে দেখাবে কবে পৌঁছাবেন।';

  @override
  String get goalForecast => 'শেষ হবে';

  @override
  String get goalPaceNothingYet =>
      'টাকা জমা শুরু হলে কবে পৌঁছাবেন তা এখানে দেখাবে।';

  @override
  String goalPaceEarly(String date) {
    return 'এই গতিতে আপনি $date নাগাদ পৌঁছাবেন, সময়মতো।';
  }

  @override
  String goalPaceLate(String date, String needed) {
    return 'এই গতিতে আপনি $date নাগাদ পৌঁছাবেন, তারিখের পরে। মাসে $needed জমালে সময়মতো হবে।';
  }

  @override
  String goalPaceNoDate(String amount, String date) {
    return 'মাসে $amount করে জমালে $date নাগাদ পৌঁছাবেন।';
  }

  @override
  String get goalWhatIf => 'যদি জমাই…';

  @override
  String goalWhatIfResult(String amount, String date) {
    return 'মাসে $amount → $date-এর মধ্যে শেষ';
  }

  @override
  String get goalWhatIfNever => 'কবে পৌঁছাবেন দেখতে স্লাইডারটি সরান।';

  @override
  String get goalWhatIfAutoSave => 'প্রতি মাসে এটা জমান';

  @override
  String get goalMonthly => 'মাস অনুযায়ী';

  @override
  String goalStreak(String months) {
    return 'টানা $months মাস';
  }

  @override
  String get goalMilestones => 'ধাপগুলো';

  @override
  String get goalSources => 'কোথা থেকে এসেছে';

  @override
  String get goalHistory => 'ইতিহাস';

  @override
  String get goalNoMoves =>
      'এখনও কিছু জমা হয়নি। প্রথম পদক্ষেপটাই সবচেয়ে বড়।';

  @override
  String goalMoveIn(String account) {
    return '$account থেকে';
  }

  @override
  String goalMoveOut(String account) {
    return '$account-এ';
  }

  @override
  String get goalUndoMove =>
      'এটা ফিরিয়ে নেবেন? ট্রান্সফারের দুই দিকই মুছে যাবে।';

  @override
  String goalHalfway(String goal) {
    return '$goal-এর অর্ধেক পথ পেরিয়েছেন!';
  }

  @override
  String goalMilestoneReached(String mark, String goal) {
    return '$goal-এর $mark% পূরণ!';
  }

  @override
  String get goalReachedTitle => 'লক্ষ্য পূরণ!';

  @override
  String goalReachedBody(String goal, String amount) {
    return '$goal-এর জন্য আপনি $amount জমিয়েছেন।';
  }

  @override
  String get goalReachedDays => 'যত দিন লেগেছে';

  @override
  String get goalReachedTimes => 'যতবার জমিয়েছেন';

  @override
  String goalsSummary(String saved, String target, String count) {
    return '$countটি লক্ষ্যে $target-এর মধ্যে $saved';
  }

  @override
  String goalsThisMonth(String amount) {
    return 'এ মাসে $amount';
  }

  @override
  String goalsSavingRate(String percent) {
    return 'আয়ের $percent% জমাচ্ছেন';
  }

  @override
  String get goalsHeaderEmpty => 'যে টাকা আলাদা করে রাখবেন তা এখানে দেখাবে।';

  @override
  String get goalsReachedSection => 'পূরণ হয়েছে';

  @override
  String goalsArchivedSection(String count) {
    return 'আর্কাইভ করা ($count)';
  }

  @override
  String get goalsEmptyTitle => 'আপনার টাকাকে একটা কাজ দিন';

  @override
  String get goalsEmptyBody =>
      'দরকারি কিছুর জন্য টাকা আলাদা করে রাখুন। এটা খরচযোগ্য টাকা থেকে সরে যায়, তাই খরচের লোভ থাকে না, আর যখন খুশি ফেরত নিতে পারবেন।';

  @override
  String get goalsHowTitle => 'লক্ষ্য কীভাবে কাজ করে';

  @override
  String get goalsHowSetAside => 'টাকা আলাদা থাকে';

  @override
  String get goalsHowSetAsideBody =>
      'টাকা জমালে তা অ্যাকাউন্ট থেকে লক্ষ্যে চলে যায়। তখন তা \'খরচযোগ্য\'-তে থাকে না, তবে মোট সম্পদে ধরা হয়।';

  @override
  String get goalsHowDate => 'তারিখ দিলে লক্ষ্য বাস্তব হয়';

  @override
  String get goalsHowDateBody =>
      'তারিখ দিলে প্রতি মাসে কত লাগবে আর আপনি ঠিক পথে আছেন কি না তা দেখা যায়।';

  @override
  String get goalsHowFirst => 'আগে নিজেকে দিন';

  @override
  String get goalsHowFirstBody =>
      'মাসের শেষে যা থাকে তা জমানোর চেয়ে বেতন পাওয়ার পরপরই নিয়মিত জমানো বেশি কাজ করে।';

  @override
  String get goalsHowWithdraw => 'যখন খুশি, আপনারই';

  @override
  String get goalsHowWithdrawBody =>
      'লক্ষ্যের টাকা খরচ করতে আগে তা অ্যাকাউন্টে তুলুন। টাকা কখনও আটকে থাকে না, শুধু একটা ভেবে-চিন্তে নেওয়া ধাপ বেশি।';

  @override
  String insightBehind(String goal, String amount, String perWeek) {
    return '$goal $amount পিছিয়ে আছে। সপ্তাহে $perWeek জমালে আবার ঠিক পথে আসবে।';
  }

  @override
  String insightStreak(String months, String goal) {
    return 'টানা $months মাস $goal-এর জন্য জমিয়েছেন। ধারাটা ধরে রাখুন!';
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
      other: '$weeks সপ্তাহ',
    );
    return 'এ মাসে $category-এ $amount খরচ হয়েছে। এর অর্ধেক জমালে $goal $_temp0 আগে পূরণ হবে।';
  }

  @override
  String insightPayday(String goal) {
    return 'আপনি সাধারণত বেতনের পরপরই $goal-এর জন্য জমান। প্রতি মাসে নিজে থেকে হোক?';
  }

  @override
  String insightBestMonth(String amount) {
    return 'এ মাসে লক্ষ্যে $amount জমিয়েছেন, এখন পর্যন্ত সেরা মাস।';
  }

  @override
  String get insightEmergency =>
      'এখনও জরুরি তহবিল নেই। অপ্রত্যাশিত খরচের জন্য তিন থেকে ছয় মাসের খরচ রাখার পরামর্শ দেওয়া হয়।';

  @override
  String get insightEmergencyAction => 'শুরু করুন';

  @override
  String withdrawTitle(String goal) {
    return '$goal থেকে টাকা তুলবেন?';
  }

  @override
  String get withdrawReachedTitle => 'টাকাটা কাজে লাগান 🎉';

  @override
  String withdrawFinishMoves(String from, String to) {
    return 'শেষের তারিখ $from থেকে $to-এ সরে যাবে।';
  }

  @override
  String withdrawSetsBack(String amount) {
    return 'এতে আপনার লক্ষ্য $amount পিছিয়ে যাবে।';
  }

  @override
  String withdrawAll(String amount) {
    return 'সবটা: $amount';
  }

  @override
  String get withdrawWhy => 'কেন? (ঐচ্ছিক)';

  @override
  String get withdrawEmergency => 'জরুরি';

  @override
  String get withdrawReached => 'লক্ষ্য পূরণ হয়েছে';

  @override
  String get withdrawChangedPlans => 'পরিকল্পনা বদলেছে';

  @override
  String get withdrawOther => 'অন্য কারণ';

  @override
  String withdrawConfirm(String amount) {
    return '$amount তুলুন';
  }

  @override
  String withdrawMove(String amount) {
    return '$amount অ্যাকাউন্টে নিন';
  }

  @override
  String withdrawTooMuch(String amount) {
    return 'লক্ষ্যে আছে $amount।';
  }

  @override
  String withdrawNote(String percent) {
    return 'আপনি $percent% পথ পেরিয়েছেন। টাকা একটি ট্রান্সফার হিসেবে ফেরত যাবে, যা দুই জায়গাতেই দেখা যাবে।';
  }

  @override
  String inboxGoalMilestone(String percent, String title) {
    return '$title: লক্ষ্যের $percent% পূরণ হয়েছে';
  }

  @override
  String inboxGoalReached(String title) {
    return '$title: লক্ষ্য পূরণ হয়েছে!';
  }

  @override
  String inboxGoalBehind(String title) {
    return '$title সময়ের চেয়ে পিছিয়ে আছে';
  }

  @override
  String inboxGoalIdle(String title, String days) {
    return '$days দিন ধরে $title-এ কিছু জমানো হয়নি';
  }

  @override
  String inboxGoalDetail(String saved, String target) {
    return '$target-এর মধ্যে $saved জমেছে';
  }

  @override
  String inboxGoalNeeded(String amount) {
    return 'মাসে $amount জমালে আবার সময়মতো হবে';
  }

  @override
  String get planner => 'পরিকল্পনা';

  @override
  String get goalsShort => 'লক্ষ্য';

  @override
  String get saveKind => 'জমা';

  @override
  String get goalPick => 'একটি লক্ষ্য বেছে নিন';

  @override
  String get goalStartFirst => 'প্রথম লক্ষ্য শুরু করুন';

  @override
  String get goalNewShort => 'নতুন';

  @override
  String goalsBehindCount(String count) {
    return '$countটি পিছিয়ে';
  }

  @override
  String goalsSavedTotal(String amount) {
    return '$amount জমা';
  }

  @override
  String get goalsInviteBody =>
      'দরকারি কিছুর জন্য টাকা আলাদা রাখুন। লক্ষ্য শুরু করতে চাপুন।';

  @override
  String goalsKeptAside(int n, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$countটি লক্ষ্য, খরচের টাকা থেকে আলাদা',
    );
    return '$_temp0';
  }

  @override
  String goalsShareOfWorth(String percent) {
    return 'আপনার সম্পদের $percent লক্ষ্যের জন্য আলাদা রাখা';
  }

  @override
  String get goalAccountLocked =>
      'আপনার প্ল্যানে এই অ্যাকাউন্টটি শুধু দেখার জন্য। জমাতে অন্য একটি বেছে নিন।';

  @override
  String get reviewTitle => 'বছরের সারসংক্ষেপ';

  @override
  String reviewYearSoFar(String year) {
    return '$year এখন পর্যন্ত';
  }

  @override
  String get reviewPreviousYear => 'আগের বছর';

  @override
  String get reviewNextYear => 'পরের বছর';

  @override
  String get reviewKept => 'আপনি জমিয়েছেন';

  @override
  String get reviewOverspent => 'আয়ের চেয়ে বেশি খরচ হয়েছে';

  @override
  String reviewRate(String percent) {
    return 'আয়ের $percent%';
  }

  @override
  String get reviewCameIn => 'এসেছে';

  @override
  String get reviewWentOut => 'গেছে';

  @override
  String reviewAgainst(String year) {
    return '$year-এর তুলনায়';
  }

  @override
  String reviewChangeOn(String percent, String year) {
    return '$year-এর তুলনায় $percent%';
  }

  @override
  String reviewNothingBefore(String year) {
    return '$year-এ কিছু ছিল না';
  }

  @override
  String get reviewMonthByMonth => 'মাস অনুযায়ী';

  @override
  String get reviewSpentMost => 'সবচেয়ে বেশি খরচ';

  @override
  String get reviewSpentLeast => 'সবচেয়ে কম খরচ';

  @override
  String get reviewMonthHint => 'কোনো মাস খুলতে চাপুন।';

  @override
  String get reviewWhereItWent => 'টাকা কোথায় গেল';

  @override
  String reviewShareOfSpending(String percent) {
    return 'খরচের $percent%';
  }

  @override
  String reviewMoreCategories(String count, String amount) {
    return 'আরও $countটি খাত: $amount';
  }

  @override
  String get reviewHighlights => 'বিশেষ দিক';

  @override
  String get reviewBiggestExpense => 'সবচেয়ে বড় খরচ';

  @override
  String get reviewAverageMonth => 'মাসে গড়ে';

  @override
  String get reviewBestMonth => 'সঞ্চয়ের সেরা মাস';

  @override
  String reviewKeptAmount(String amount) {
    return '$amount জমা';
  }

  @override
  String get reviewMonthsInGreen => 'লাভে থাকা মাস';

  @override
  String reviewMonthsOf(String count, String total) {
    return '$totalটির মধ্যে $countটি';
  }

  @override
  String get reviewGoalsReached => 'পূরণ হওয়া লক্ষ্য';

  @override
  String get reviewShare => 'আপনার বছর শেয়ার করুন';

  @override
  String reviewShareText(String year) {
    return 'Spendroo-তে আমার $year';
  }

  @override
  String get reviewShareFailed =>
      'কার্ডটি শেয়ার করা গেল না। আবার চেষ্টা করুন।';

  @override
  String reviewEmpty(String year) {
    return '$year-এ কিছু লেখা হয়নি। আয় ও খরচ যোগ করুন, আপনার বছর এখানে তৈরি হবে।';
  }

  @override
  String get reviewLocked =>
      'পুরো বছরে ফিরে দেখুন: কী এল, কোথায় গেল, সেরা ও খারাপ মাস, আর আগের বছরের সাথে তুলনা।';

  @override
  String reviewTileTitle(String year) {
    return 'আপনার $year এক নজরে';
  }

  @override
  String get reviewTileBody => 'মোট হিসাব, শীর্ষ খাত আর সেরা মাসগুলো';

  @override
  String get widgetAdd => 'যোগ';

  @override
  String widgetSafePace(String amount) {
    return 'দিনে $amount নিরাপদ';
  }

  @override
  String widgetAveragePace(String amount) {
    return 'গড়ে দিনে $amount';
  }

  @override
  String get widgetBudgetLeft => 'বাজেট বাকি';

  @override
  String get widgetUnlockTitle => 'পুরো মাস এখানেই দেখুন';

  @override
  String get widgetUnlockBody =>
      'আজকের খরচ, বাকি বাজেট, এ মাসে কত বাকি আর দৈনিক খরচের চার্ট';

  @override
  String get widgetUnlockCta => 'প্লাস দিয়ে খুলুন';

  @override
  String get widgetSignInTitle => 'স্পেন্ড্রুতে সাইন ইন করুন';

  @override
  String get widgetSignInBody => 'এই মাসের খরচ এখানে দেখা যাবে';

  @override
  String get widgetEmptyChart =>
      'এই মাসে এখনো কোনো খরচ নেই। খরচ লিখতে + চাপুন।';

  @override
  String get widgetHideAmounts => 'টাকার অঙ্ক লুকান';

  @override
  String get widgetShowAmounts => 'টাকার অঙ্ক দেখান';

  @override
  String widgetUpdated(String time) {
    return 'হালনাগাদ $time';
  }

  @override
  String get widgetSettingsTitle => 'হোম স্ক্রিন উইজেট';

  @override
  String get widgetSettingsBody =>
      'এই মাসের খরচ আর এক ট্যাপে যোগ, সরাসরি হোম স্ক্রিনে';

  @override
  String get widgetAddToHome => 'হোম স্ক্রিনে যোগ করুন';

  @override
  String get widgetPinManual =>
      'হোম স্ক্রিনের ফাঁকা জায়গায় চেপে ধরুন, উইজেট চাপুন আর স্পেন্ড্রু খুঁজে নিন।';

  @override
  String get widgetSpentThisMonth => 'এই মাসের খরচ';

  @override
  String widgetSpentIn(String month) {
    return '$month-এর খরচ';
  }

  @override
  String get widgetLeftThisMonth => 'এ মাসে বাকি';

  @override
  String get featureBusinessWidget => 'ব্যবসার হোম স্ক্রিন উইজেট';

  @override
  String get bizWidgetSevenDays => '৭ দিন';

  @override
  String get bizWidgetVsYesterday => 'গতকালের তুলনায়';

  @override
  String get bizWidgetVsPrevious7 => 'আগের ৭ দিনের তুলনায়';

  @override
  String get bizWidgetVsLastMonth => 'গত মাসের তুলনায়';

  @override
  String bizWidgetBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ক্যাশবুক',
      zero: 'কোনো ক্যাশবুক নেই',
    );
    return '$_temp0';
  }

  @override
  String bizWidgetOtherCurrency(int count, String currency) {
    return '$currency-এ আরও $countটি';
  }

  @override
  String get bizWidgetUnlockTitle => 'আপনার ব্যবসার পুরো চিত্র দেখুন';

  @override
  String get bizWidgetUnlockBody =>
      'আজ, ৭ দিন ও মাসের হিসাব, ১৪ দিনের নগদ চার্ট আর স্মার্ট পরামর্শ';

  @override
  String get bizWidgetChooseBusiness => 'একটি ব্যবসা বেছে নিন';

  @override
  String get bizWidgetChooseBook => 'একটি ক্যাশবুক বেছে নিন';

  @override
  String get bizWidgetChooseBody => 'উইজেটে কী দেখাবে তা বাছতে ট্যাপ করুন';

  @override
  String get bizWidgetGoneTitle => 'আর পাওয়া যাচ্ছে না';

  @override
  String get bizWidgetGoneBody => 'অন্য একটি বাছতে ট্যাপ করুন';

  @override
  String get bizWidgetSignInBody => 'আপনার ব্যবসার এক নজরের হিসাব এখানে দেখাবে';

  @override
  String get bizWidgetBooksTitle => 'ক্যাশবুক';

  @override
  String get bizWidgetRecentTitle => 'সাম্প্রতিক';

  @override
  String get bizWidgetNoEntries =>
      'এখনো কোনো এন্ট্রি নেই। শুরু করতে জমা বা খরচে ট্যাপ করুন।';

  @override
  String get bizWidgetQuietChart => 'গত ১৪ দিনে কোনো জমা-খরচ নেই';

  @override
  String get bizWidgetNoBooks =>
      'এখনো কোনো ক্যাশবুক নেই। যোগ করতে ব্যবসাটি খুলুন।';

  @override
  String get bizWidgetNextInsight => 'পরের পরামর্শ';

  @override
  String get bizWidgetRefresh => 'খুলে হালনাগাদ করুন';

  @override
  String get bizWidgetPeriod => 'সময়কাল বদলান';

  @override
  String get bizWidgetPickerEmpty =>
      'এখনো কোনো ব্যবসা নেই। আগে স্পেন্ড্রুতে একটি তৈরি করুন।';

  @override
  String get bizWidgetPickerBooksEmpty => 'এই ব্যবসায় এখনো কোনো ক্যাশবুক নেই।';

  @override
  String get bizWidgetSettingsTitle => 'ব্যবসার উইজেট';

  @override
  String get bizWidgetSettingsBody =>
      'পুরো ব্যবসা বা একটি ক্যাশবুক, হোম স্ক্রিনেই';

  @override
  String get bizWidgetAddBusiness => 'ব্যবসার উইজেট';

  @override
  String get bizWidgetAddBusinessBody =>
      'সব ক্যাশবুক মিলিয়ে ব্যালেন্স, জমা-খরচ আর পরামর্শ';

  @override
  String get bizWidgetAddBook => 'ক্যাশবুক উইজেট';

  @override
  String get bizWidgetAddBookBody => 'একটি ক্যাশবুক, এক ট্যাপে জমা ও খরচ';

  @override
  String get bizChooseBookTitle => 'কোন ক্যাশবুকে যোগ করবেন?';

  @override
  String get bizChooseBookNone =>
      'এই ব্যবসার ক্যাশবুকগুলো আপনি শুধু দেখতে পারেন।';

  @override
  String bizInsightNegative(String amount) {
    return 'ব্যালেন্স শূন্যের $amount নিচে';
  }

  @override
  String get bizInsightNegativeMasked => 'ব্যালেন্স শূন্যের নিচে';

  @override
  String bizInsightNegativeBook(String book, String amount) {
    return '$book শূন্যের $amount নিচে';
  }

  @override
  String bizInsightNegativeBookMasked(String book) {
    return '$book শূন্যের নিচে';
  }

  @override
  String bizInsightIdle(String date) {
    return '$date-এর পর কোনো এন্ট্রি নেই';
  }

  @override
  String bizInsightOutUp(String percent) {
    return 'গত মাসের চেয়ে খরচ $percent বেশি';
  }

  @override
  String bizInsightOutDown(String percent) {
    return 'গত মাসের চেয়ে খরচ $percent কম';
  }

  @override
  String bizInsightInUp(String percent) {
    return 'গত মাসের চেয়ে জমা $percent বেশি';
  }

  @override
  String bizInsightInDown(String percent) {
    return 'গত মাসের চেয়ে জমা $percent কম';
  }

  @override
  String bizInsightTopCategory(String category, String percent) {
    return 'এ মাসের খরচের $percent $category';
  }

  @override
  String bizInsightBiggestOut(String label, String amount) {
    return 'এ সপ্তাহের সবচেয়ে বড় খরচ: $label, $amount';
  }

  @override
  String bizInsightBiggestOutMasked(String label) {
    return 'এ সপ্তাহের সবচেয়ে বড় খরচ: $label';
  }

  @override
  String bizInsightStreak(String days) {
    return 'টানা $days দিন খরচের চেয়ে জমা বেশি';
  }

  @override
  String bizInsightProjection(String month, String amount) {
    return 'এভাবে চললে $month শেষ হবে $amount-এ';
  }

  @override
  String bizInsightProjectionAhead(String month) {
    return 'এভাবে চললে $month লাভে শেষ হবে';
  }

  @override
  String bizInsightProjectionBehind(String month) {
    return 'এভাবে চললে $month ঘাটতিতে শেষ হবে';
  }

  @override
  String bizInsightLeadBook(String book, String amount) {
    return 'এ মাসে সবার আগে $book, $amount';
  }

  @override
  String bizInsightLeadBookMasked(String book) {
    return 'এ মাসে সবার আগে $book';
  }

  @override
  String bizInsightLosingBook(String book, String amount) {
    return 'এ মাসে $book $amount-এ আছে';
  }

  @override
  String bizInsightLosingBookMasked(String book) {
    return 'এ মাসে $book-এ ঘাটতি চলছে';
  }

  @override
  String get bizInsightQuietMonth => 'এ মাসে এখনো কোনো এন্ট্রি নেই';

  @override
  String get bizInsightEmptyBook => 'পরামর্শ দেখতে প্রথম এন্ট্রিটি যোগ করুন';

  @override
  String get bizInsightSteady => 'জমা-খরচ গত মাসের কাছাকাছি';
}
