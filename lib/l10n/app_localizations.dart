import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

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
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kid Guard'**
  String get appTitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My Children'**
  String get myChildren;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme & colors'**
  String get appearanceSubtitle;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @redeemRewards.
  ///
  /// In en, this message translates to:
  /// **'Redeem Rewards'**
  String get redeemRewards;

  /// No description provided for @pointHistory.
  ///
  /// In en, this message translates to:
  /// **'Point History'**
  String get pointHistory;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity today'**
  String get noActivity;

  /// No description provided for @homework.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get homework;

  /// No description provided for @chores.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get chores;

  /// No description provided for @goodBehavior.
  ///
  /// In en, this message translates to:
  /// **'Good Behavior'**
  String get goodBehavior;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @iceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get iceCream;

  /// No description provided for @gameTime.
  ///
  /// In en, this message translates to:
  /// **'Game Time'**
  String get gameTime;

  /// No description provided for @movie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get movie;

  /// No description provided for @newToy.
  ///
  /// In en, this message translates to:
  /// **'New Toy'**
  String get newToy;

  /// No description provided for @stayUp.
  ///
  /// In en, this message translates to:
  /// **'Stay Up Late'**
  String get stayUp;

  /// No description provided for @parkTrip.
  ///
  /// In en, this message translates to:
  /// **'Park Trip'**
  String get parkTrip;

  /// No description provided for @needMorePoints.
  ///
  /// In en, this message translates to:
  /// **'Need {amount} more points'**
  String needMorePoints(Object amount);

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @redeemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Redeem {reward}?'**
  String redeemConfirm(Object reward);

  /// No description provided for @redeemCost.
  ///
  /// In en, this message translates to:
  /// **'Use {cost} points'**
  String redeemCost(Object cost);

  /// No description provided for @redeemNow.
  ///
  /// In en, this message translates to:
  /// **'Redeem Now'**
  String get redeemNow;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @earnedReward.
  ///
  /// In en, this message translates to:
  /// **'{child} earned {reward}'**
  String earnedReward(Object child, Object reward);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{amount} points for {reason}'**
  String pointsEarned(Object amount, Object reason);

  /// No description provided for @redeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed: {reward}'**
  String redeemed(Object reward);

  /// No description provided for @editChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Child Profile'**
  String get editChildProfile;

  /// No description provided for @addChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Child Profile'**
  String get addChildProfile;

  /// No description provided for @updateProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your child\'s profile settings.'**
  String get updateProfileDesc;

  /// No description provided for @createProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a profile for your child to manage their device usage.'**
  String get createProfileDesc;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Name'**
  String get childName;

  /// No description provided for @childAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get childAge;

  /// No description provided for @dailyTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Time Limit'**
  String get dailyTimeLimit;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @selectMode.
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get selectMode;

  /// No description provided for @strictMode.
  ///
  /// In en, this message translates to:
  /// **'Strict Mode'**
  String get strictMode;

  /// No description provided for @strictModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Block all apps except allowed ones.'**
  String get strictModeDesc;

  /// No description provided for @flexibleMode.
  ///
  /// In en, this message translates to:
  /// **'Flexible Mode'**
  String get flexibleMode;

  /// No description provided for @flexibleModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow all apps except blocked ones.'**
  String get flexibleModeDesc;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get enterValidAge;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @profileCreated.
  ///
  /// In en, this message translates to:
  /// **'Profile for {name} created successfully!'**
  String profileCreated(Object name);

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(Object error);

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get accountProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @displayNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name to be displayed in app'**
  String get displayNameDesc;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @cannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Cannot be changed'**
  String get cannotBeChanged;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get changePasswordDesc;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter display name'**
  String get enterDisplayName;

  /// No description provided for @nameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameLengthError;

  /// No description provided for @displayNameChanged.
  ///
  /// In en, this message translates to:
  /// **'Your display name has been changed to \"{name}\".'**
  String displayNameChanged(Object name);

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update successful'**
  String get updateSuccess;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get updateError;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchError;

  /// No description provided for @securityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get securityAlert;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordChangeSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangeSuccessMsg;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @parentAccount.
  ///
  /// In en, this message translates to:
  /// **'Parent Account'**
  String get parentAccount;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @childAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Child Added'**
  String get childAddedTitle;

  /// No description provided for @childAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} has been added to your family.'**
  String childAddedMessage(Object name);

  /// No description provided for @profileUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdatedTitle;

  /// No description provided for @profileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile has been updated.'**
  String profileUpdatedMessage(Object name);

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

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notificationDismissed.
  ///
  /// In en, this message translates to:
  /// **'Notification dismissed'**
  String get notificationDismissed;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @themeChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Changed'**
  String get themeChangedTitle;

  /// No description provided for @themeChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'App theme has been updated to {theme}.'**
  String themeChangedMessage(Object theme);

  /// No description provided for @languageChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChangedTitle;

  /// No description provided for @languageChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'App language has been updated to {language}.'**
  String languageChangedMessage(Object language);

  /// No description provided for @settingsUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings Updated'**
  String get settingsUpdatedTitle;

  /// No description provided for @settingsUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your preferences have been saved.'**
  String get settingsUpdatedMessage;

  /// No description provided for @feedbackSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback Sent'**
  String get feedbackSentTitle;

  /// No description provided for @feedbackSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackSentMessage;

  /// No description provided for @customRewards.
  ///
  /// In en, this message translates to:
  /// **'Custom Rewards'**
  String get customRewards;

  /// No description provided for @addReward.
  ///
  /// In en, this message translates to:
  /// **'Add Reward'**
  String get addReward;

  /// No description provided for @editReward.
  ///
  /// In en, this message translates to:
  /// **'Edit Reward'**
  String get editReward;

  /// No description provided for @deleteReward.
  ///
  /// In en, this message translates to:
  /// **'Delete Reward'**
  String get deleteReward;

  /// No description provided for @rewardName.
  ///
  /// In en, this message translates to:
  /// **'Reward Name'**
  String get rewardName;

  /// No description provided for @rewardCost.
  ///
  /// In en, this message translates to:
  /// **'Points Required'**
  String get rewardCost;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @rewardAdded.
  ///
  /// In en, this message translates to:
  /// **'Reward added!'**
  String get rewardAdded;

  /// No description provided for @rewardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reward updated!'**
  String get rewardUpdated;

  /// No description provided for @rewardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reward deleted'**
  String get rewardDeleted;

  /// No description provided for @deleteRewardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reward?'**
  String get deleteRewardConfirm;

  /// No description provided for @noRewardsYet.
  ///
  /// In en, this message translates to:
  /// **'No custom rewards yet. Tap + to add one!'**
  String get noRewardsYet;

  /// No description provided for @enterRewardName.
  ///
  /// In en, this message translates to:
  /// **'Please enter reward name'**
  String get enterRewardName;

  /// No description provided for @enterValidCost.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid points'**
  String get enterValidCost;

  /// No description provided for @defaultRewards.
  ///
  /// In en, this message translates to:
  /// **'Default Rewards'**
  String get defaultRewards;

  /// No description provided for @myRewards.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get myRewards;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @activityTab.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts'**
  String get manageAlerts;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @viewTutorialAgain.
  ///
  /// In en, this message translates to:
  /// **'View Tutorial again'**
  String get viewTutorialAgain;

  /// No description provided for @faqAndGuides.
  ///
  /// In en, this message translates to:
  /// **'FAQ & guides'**
  String get faqAndGuides;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report issues'**
  String get reportIssues;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @connectionPin.
  ///
  /// In en, this message translates to:
  /// **'Connection PIN'**
  String get connectionPin;

  /// No description provided for @linkChildDevicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this to link child devices'**
  String get linkChildDevicesDesc;

  /// No description provided for @copyPin.
  ///
  /// In en, this message translates to:
  /// **'Copy PIN'**
  String get copyPin;

  /// No description provided for @pinCopied.
  ///
  /// In en, this message translates to:
  /// **'PIN copied to clipboard'**
  String get pinCopied;

  /// No description provided for @logOutOfYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account'**
  String get logOutOfYourAccount;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screen time & app usage insights'**
  String get activitySubtitle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get weeklyOverview;

  /// No description provided for @appUsed.
  ///
  /// In en, this message translates to:
  /// **'{count} apps used'**
  String appUsed(Object count);

  /// No description provided for @noAppUsageData.
  ///
  /// In en, this message translates to:
  /// **'No app usage data'**
  String get noAppUsageData;

  /// No description provided for @noAppUsageDataDesc.
  ///
  /// In en, this message translates to:
  /// **'App usage will appear after the child\nuses their device on this day'**
  String get noAppUsageDataDesc;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show {count} more'**
  String showMore(Object count);

  /// No description provided for @mostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get mostUsed;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @noChildrenAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildrenAddedYet;

  /// No description provided for @addChildToSeeActivityData.
  ///
  /// In en, this message translates to:
  /// **'Add a child to see activity data'**
  String get addChildToSeeActivityData;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @unlockRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Unlock request sent'**
  String get unlockRequestSent;

  /// No description provided for @failedToSendUnlockRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to send unlock request: {error}'**
  String failedToSendUnlockRequest(Object error);

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimit;

  /// No description provided for @setLimits.
  ///
  /// In en, this message translates to:
  /// **'Set limits'**
  String get setLimits;

  /// No description provided for @appBlock.
  ///
  /// In en, this message translates to:
  /// **'App Block'**
  String get appBlock;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @instantPause.
  ///
  /// In en, this message translates to:
  /// **'Instant Pause'**
  String get instantPause;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @appControl.
  ///
  /// In en, this message translates to:
  /// **'App Control'**
  String get appControl;

  /// No description provided for @appControlWithChild.
  ///
  /// In en, this message translates to:
  /// **'App Control - {name}'**
  String appControlWithChild(Object name);

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps...'**
  String get searchApps;

  /// No description provided for @totalApps.
  ///
  /// In en, this message translates to:
  /// **'Total Apps'**
  String get totalApps;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'How to connect a child device?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'1. Open the app on your child\'s device and select \"Child\".\n2. Enter the 6-digit PIN from the Parent Settings page.\n3. Select or create a child profile.\n4. Turn on Child Mode.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'Why can blocked apps still be opened?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Please ensure that:\n• Accessibility Service is enabled.\n• Child Mode is turned on.\n• Kid Guard app is running in the background.\n\nIf it still doesn\'t work, try force stopping Kid Guard and opening it again.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'How to set a time limit?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'1. Go to Dashboard > Time Limit.\n2. Select a child profile.\n3. Set your desired time limits.\n4. Save changes.\n\nThe child\'s screen will be locked when the limit is reached.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'How to view child\'s location?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'1. Go to Dashboard > Location.\n2. Select a child profile.\n3. The location will be displayed on the map.\n\nNote: Location Permission must be enabled on the child\'s device.'**
  String get faq4Answer;

  /// No description provided for @faq5Question.
  ///
  /// In en, this message translates to:
  /// **'What to do if I lost my PIN?'**
  String get faq5Question;

  /// No description provided for @faq5Answer.
  ///
  /// In en, this message translates to:
  /// **'1. Go to Settings > Connection.\n2. Tap \"Regenerate\" to create a new PIN.\n3. Use the new PIN to connect.\n\nNote: Already connected devices do not need the new PIN.'**
  String get faq5Answer;

  /// No description provided for @faq6Question.
  ///
  /// In en, this message translates to:
  /// **'How to delete a child profile?'**
  String get faq6Question;

  /// No description provided for @faq6Answer.
  ///
  /// In en, this message translates to:
  /// **'1. Open the app on the child\'s device.\n2. Select \"Connect with Parent\".\n3. Press and hold the profile you want to delete.\n4. Confirm deletion.'**
  String get faq6Answer;

  /// No description provided for @faq7Question.
  ///
  /// In en, this message translates to:
  /// **'How does the Rewards system work?'**
  String get faq7Question;

  /// No description provided for @faq7Answer.
  ///
  /// In en, this message translates to:
  /// **'You can award points to your child for tasks like homework or chores. They can use these points to redeem custom rewards (e.g., extra game time) from the Rewards section.'**
  String get faq7Answer;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions and guides'**
  String get helpCenterSubtitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us at support@kidguard.app'**
  String get contactSupportSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appProtection.
  ///
  /// In en, this message translates to:
  /// **'App Protection'**
  String get appProtection;

  /// No description provided for @appProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Prevent app uninstallation'**
  String get appProtectionDesc;

  /// No description provided for @appProtectionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get appProtectionEnabled;

  /// No description provided for @appProtectionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Not protected'**
  String get appProtectionDisabled;

  /// No description provided for @enableAppProtection.
  ///
  /// In en, this message translates to:
  /// **'Enable Protection'**
  String get enableAppProtection;

  /// No description provided for @enableAppProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Activate to prevent children from uninstalling KidGuard'**
  String get enableAppProtectionDesc;

  /// No description provided for @disableAppProtection.
  ///
  /// In en, this message translates to:
  /// **'Disable Protection'**
  String get disableAppProtection;

  /// No description provided for @enterPinToDisable.
  ///
  /// In en, this message translates to:
  /// **'Enter parent PIN to disable protection'**
  String get enterPinToDisable;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @appProtectionActivated.
  ///
  /// In en, this message translates to:
  /// **'App protection activated'**
  String get appProtectionActivated;

  /// No description provided for @appProtectionDeactivated.
  ///
  /// In en, this message translates to:
  /// **'App protection deactivated'**
  String get appProtectionDeactivated;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;
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
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
