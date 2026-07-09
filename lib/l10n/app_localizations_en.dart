// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kid Guard';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get myChildren => 'My Children';

  @override
  String get addChild => 'Add Child';

  @override
  String get seeAll => 'See All';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Theme & colors';

  @override
  String get connection => 'Connection';

  @override
  String get general => 'General';

  @override
  String get support => 'Support';

  @override
  String get account => 'Account';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get about => 'About';

  @override
  String get signOut => 'Sign Out';

  @override
  String get points => 'Points';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get redeemRewards => 'Redeem Rewards';

  @override
  String get pointHistory => 'Point History';

  @override
  String get noActivity => 'No activity today';

  @override
  String get homework => 'Homework';

  @override
  String get chores => 'Chores';

  @override
  String get goodBehavior => 'Good Behavior';

  @override
  String get exercise => 'Exercise';

  @override
  String get iceCream => 'Ice Cream';

  @override
  String get gameTime => 'Game Time';

  @override
  String get movie => 'Movie';

  @override
  String get newToy => 'New Toy';

  @override
  String get stayUp => 'Stay Up Late';

  @override
  String get parkTrip => 'Park Trip';

  @override
  String needMorePoints(Object amount) {
    return 'Need $amount more points';
  }

  @override
  String get redeem => 'Redeem';

  @override
  String get cancel => 'Cancel';

  @override
  String redeemConfirm(Object reward) {
    return 'Redeem $reward?';
  }

  @override
  String redeemCost(Object cost) {
    return 'Use $cost points';
  }

  @override
  String get redeemNow => 'Redeem Now';

  @override
  String get success => 'Success!';

  @override
  String earnedReward(Object child, Object reward) {
    return '$child earned $reward';
  }

  @override
  String get close => 'Close';

  @override
  String pointsEarned(Object amount, Object reason) {
    return '+$amount points for $reason';
  }

  @override
  String redeemed(Object reward) {
    return 'Redeemed: $reward';
  }

  @override
  String get editChildProfile => 'Edit Child Profile';

  @override
  String get addChildProfile => 'Add Child Profile';

  @override
  String get updateProfileDesc => 'Update your child\'s profile settings.';

  @override
  String get createProfileDesc =>
      'Create a profile for your child to manage their device usage.';

  @override
  String get childName => 'Child\'s Name';

  @override
  String get childAge => 'Age';

  @override
  String get dailyTimeLimit => 'Daily Time Limit';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get hours => 'hours';

  @override
  String get selectMode => 'Select Mode';

  @override
  String get strictMode => 'Strict Mode';

  @override
  String get strictModeDesc => 'Block all apps except allowed ones.';

  @override
  String get flexibleMode => 'Flexible Mode';

  @override
  String get flexibleModeDesc => 'Allow all apps except blocked ones.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get enterValidAge => 'Please enter a valid age';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String profileCreated(Object name) {
    return 'Profile for $name created successfully!';
  }

  @override
  String errorSavingProfile(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get accountProfile => 'My Account';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameDesc => 'Name to be displayed in app';

  @override
  String get email => 'Email';

  @override
  String get cannotBeChanged => 'Cannot be changed';

  @override
  String get verified => 'Verified';

  @override
  String get password => 'Password';

  @override
  String get changePasswordDesc => 'Change your password';

  @override
  String get change => 'Change';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get save => 'Save';

  @override
  String get notSet => 'Not set';

  @override
  String get enterDisplayName => 'Please enter display name';

  @override
  String get nameLengthError => 'Name must be at least 2 characters';

  @override
  String displayNameChanged(Object name) {
    return 'Your display name has been changed to \"$name\".';
  }

  @override
  String get updateSuccess => 'Update successful';

  @override
  String get updateError => 'An error occurred, please try again';

  @override
  String get enterCurrentPassword => 'Please enter current password';

  @override
  String get passwordLengthError =>
      'New password must be at least 6 characters';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get securityAlert => 'Security Alert';

  @override
  String get passwordChangedSuccess =>
      'Your password was changed successfully.';

  @override
  String get passwordChangeSuccessMsg => 'Password changed successfully';

  @override
  String get currentPasswordIncorrect => 'Current password incorrect';

  @override
  String get parentAccount => 'Parent Account';

  @override
  String get edit => 'Edit';

  @override
  String get childAddedTitle => 'Child Added';

  @override
  String childAddedMessage(Object name) {
    return '$name has been added to your family.';
  }

  @override
  String get profileUpdatedTitle => 'Profile Updated';

  @override
  String profileUpdatedMessage(Object name) {
    return '$name\'s profile has been updated.';
  }

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationDismissed => 'Notification dismissed';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get justNow => 'Just now';

  @override
  String get themeChangedTitle => 'Theme Changed';

  @override
  String themeChangedMessage(Object theme) {
    return 'App theme has been updated to $theme.';
  }

  @override
  String get languageChangedTitle => 'Language Changed';

  @override
  String languageChangedMessage(Object language) {
    return 'App language has been updated to $language.';
  }

  @override
  String get settingsUpdatedTitle => 'Settings Updated';

  @override
  String get settingsUpdatedMessage => 'Your preferences have been saved.';

  @override
  String get feedbackSentTitle => 'Feedback Sent';

  @override
  String get feedbackSentMessage => 'Thank you for your feedback!';

  @override
  String get customRewards => 'Custom Rewards';

  @override
  String get addReward => 'Add Reward';

  @override
  String get editReward => 'Edit Reward';

  @override
  String get deleteReward => 'Delete Reward';

  @override
  String get rewardName => 'Reward Name';

  @override
  String get rewardCost => 'Points Required';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get rewardAdded => 'Reward added!';

  @override
  String get rewardUpdated => 'Reward updated!';

  @override
  String get rewardDeleted => 'Reward deleted';

  @override
  String get deleteRewardConfirm => 'Delete this reward?';

  @override
  String get noRewardsYet => 'No custom rewards yet. Tap + to add one!';

  @override
  String get enterRewardName => 'Please enter reward name';

  @override
  String get enterValidCost => 'Please enter valid points';

  @override
  String get defaultRewards => 'Default Rewards';

  @override
  String get myRewards => 'My Rewards';

  @override
  String get homeTab => 'Home';

  @override
  String get activityTab => 'Activity';

  @override
  String get settingsTab => 'Settings';

  @override
  String get manageAlerts => 'Manage alerts';

  @override
  String get howToUse => 'How to use';

  @override
  String get viewTutorialAgain => 'View Tutorial again';

  @override
  String get faqAndGuides => 'FAQ & guides';

  @override
  String get reportIssues => 'Report issues';

  @override
  String get appInformation => 'App information';

  @override
  String get connectionPin => 'Connection PIN';

  @override
  String get linkChildDevicesDesc => 'Use this to link child devices';

  @override
  String get copyPin => 'Copy PIN';

  @override
  String get pinCopied => 'PIN copied to clipboard';

  @override
  String get logOutOfYourAccount => 'Log out of your account';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activitySubtitle => 'Screen time & app usage insights';

  @override
  String get thisWeek => 'This Week';

  @override
  String get weeklyOverview => 'Weekly Overview';

  @override
  String appUsed(Object count) {
    return '$count apps used';
  }

  @override
  String get noAppUsageData => 'No app usage data';

  @override
  String get noAppUsageDataDesc =>
      'App usage will appear after the child\nuses their device on this day';

  @override
  String get showLess => 'Show less';

  @override
  String showMore(Object count) {
    return 'Show $count more';
  }

  @override
  String get mostUsed => 'Most Used';

  @override
  String get todayLabel => 'Today';

  @override
  String get noChildrenAddedYet => 'No children added yet';

  @override
  String get addChildToSeeActivityData => 'Add a child to see activity data';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get unlockRequestSent => 'Unlock request sent';

  @override
  String failedToSendUnlockRequest(Object error) {
    return 'Failed to send unlock request: $error';
  }

  @override
  String get timeLimit => 'Time Limit';

  @override
  String get setLimits => 'Set limits';

  @override
  String get appBlock => 'App Block';

  @override
  String get manage => 'Manage';

  @override
  String get location => 'Location';

  @override
  String get track => 'Track';

  @override
  String get schedule => 'Schedule';

  @override
  String get plan => 'Plan';

  @override
  String get instantPause => 'Instant Pause';

  @override
  String get rewards => 'Rewards';

  @override
  String get appControl => 'App Control';

  @override
  String appControlWithChild(Object name) {
    return 'App Control - $name';
  }

  @override
  String get searchApps => 'Search apps...';

  @override
  String get totalApps => 'Total Apps';

  @override
  String get blocked => 'Blocked';

  @override
  String get allowed => 'Allowed';

  @override
  String get faq1Question => 'How to connect a child device?';

  @override
  String get faq1Answer =>
      '1. Open the app on your child\'s device and select \"Child\".\n2. Enter the 6-digit PIN from the Parent Settings page.\n3. Select or create a child profile.\n4. Turn on Child Mode.';

  @override
  String get faq2Question => 'Why can blocked apps still be opened?';

  @override
  String get faq2Answer =>
      'Please ensure that:\n• Accessibility Service is enabled.\n• Child Mode is turned on.\n• Kid Guard app is running in the background.\n\nIf it still doesn\'t work, try force stopping Kid Guard and opening it again.';

  @override
  String get faq3Question => 'How to set a time limit?';

  @override
  String get faq3Answer =>
      '1. Go to Dashboard > Time Limit.\n2. Select a child profile.\n3. Set your desired time limits.\n4. Save changes.\n\nThe child\'s screen will be locked when the limit is reached.';

  @override
  String get faq4Question => 'How to view child\'s location?';

  @override
  String get faq4Answer =>
      '1. Go to Dashboard > Location.\n2. Select a child profile.\n3. The location will be displayed on the map.\n\nNote: Location Permission must be enabled on the child\'s device.';

  @override
  String get faq5Question => 'What to do if I lost my PIN?';

  @override
  String get faq5Answer =>
      '1. Go to Settings > Connection.\n2. Tap \"Regenerate\" to create a new PIN.\n3. Use the new PIN to connect.\n\nNote: Already connected devices do not need the new PIN.';

  @override
  String get faq6Question => 'How to delete a child profile?';

  @override
  String get faq6Answer =>
      '1. Open the app on the child\'s device.\n2. Select \"Connect with Parent\".\n3. Press and hold the profile you want to delete.\n4. Confirm deletion.';

  @override
  String get faq7Question => 'How does the Rewards system work?';

  @override
  String get faq7Answer =>
      'You can award points to your child for tasks like homework or chores. They can use these points to redeem custom rewards (e.g., extra game time) from the Rewards section.';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get helpCenterSubtitle => 'Frequently asked questions and guides';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get contactSupportTitle => 'Still have questions?';

  @override
  String get contactSupportSubtitle => 'Contact us at support@kidguard.app';

  @override
  String get security => 'Security';

  @override
  String get appProtection => 'App Protection';

  @override
  String get appProtectionDesc => 'Prevent app uninstallation';

  @override
  String get appProtectionEnabled => 'Protected';

  @override
  String get appProtectionDisabled => 'Not protected';

  @override
  String get enableAppProtection => 'Enable Protection';

  @override
  String get enableAppProtectionDesc =>
      'Activate to prevent children from uninstalling KidGuard';

  @override
  String get disableAppProtection => 'Disable Protection';

  @override
  String get enterPinToDisable => 'Enter parent PIN to disable protection';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get appProtectionActivated => 'App protection activated';

  @override
  String get appProtectionDeactivated => 'App protection deactivated';

  @override
  String get confirm => 'Confirm';

  @override
  String get enterPin => 'Enter PIN';
}
