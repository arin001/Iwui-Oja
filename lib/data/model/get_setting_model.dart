class GetSettingModel {
  String? websiteUrl;
  String? appBarTitle;
  String? loaderColor;
  bool? pullToRefresh;
  bool? onboardingScreen;
  bool? exitPopupScreen;
  bool? appDrawer;
  bool? showBottomNavigation;
  String? style;
  String? admobAppIdAndroid;
  String? bannerAdIdAndroid;
  String? interstitialAdIdAndroid;
  String? admobAppIdIos;
  String? bannerAdIdIos;
  String? interstitialAdIdIos;
  String? aboutUs;
  String? contactUs;
  String? termsAndCondition;
  String? privacyPolicy;
  String? androidAppVersion;
  String? iosAppVersion;
  String? androidAppLink;
  String? iosAppLink;
  String? appForceUpdate;
  String? appMaintenanceMode;
  bool? admobAdStatus;
  bool? bannerAdStatus;
  bool? interstitialAdStatus;
  String? systemVersion;
  String? serviceFile;
  String? demoUrl;
  String? shareAppMessage;
  bool? hideFooter;
  bool? hideHeader;
  String? dualWebsite;
  String? primaryUrl;
  String? secondaryUrl;
  String? firstBottomNavWeb;
  String? secondBottomNavWeb;
  bool? demoMode;

  GetSettingModel(
      {this.websiteUrl,
      this.appBarTitle,
      this.loaderColor,
      this.pullToRefresh,
      this.onboardingScreen,
      this.exitPopupScreen,
      this.appDrawer,
      this.showBottomNavigation,
      this.style,
      this.admobAppIdAndroid,
      this.bannerAdIdAndroid,
      this.interstitialAdIdAndroid,
      this.admobAppIdIos,
      this.bannerAdIdIos,
      this.interstitialAdIdIos,
      this.aboutUs,
      this.contactUs,
      this.termsAndCondition,
      this.privacyPolicy,
      this.androidAppVersion,
      this.iosAppVersion,
      this.androidAppLink,
      this.iosAppLink,
      this.appForceUpdate,
      this.appMaintenanceMode,
      this.admobAdStatus,
      this.bannerAdStatus,
      this.interstitialAdStatus,
      this.systemVersion,
      this.serviceFile,
      this.demoUrl,
      this.shareAppMessage,
      this.hideFooter,
      this.hideHeader,
      this.dualWebsite,
      this.primaryUrl,
      this.secondaryUrl,
      this.firstBottomNavWeb,
      this.secondBottomNavWeb,
      this.demoMode});

  GetSettingModel.fromJson(Map<String, dynamic> json) {
    websiteUrl = json['website_url'];
    appBarTitle = json['app_bar_title'];
    loaderColor = json['loader_color'];
    pullToRefresh = json['pull_to_refresh'];
    onboardingScreen = json['onboarding_screen'];
    exitPopupScreen = json['exit_popup_screen'];
    appDrawer = json['app_drawer'] == '1';
    showBottomNavigation = json['show_bottom_navigation'] == '1';
    style = json['style'];
    admobAppIdAndroid = json['admob_app_id_android'];
    bannerAdIdAndroid = json['banner_ad_id_android'];
    interstitialAdIdAndroid = json['interstitial_ad_id_android'];
    admobAppIdIos = json['admob_app_id_ios'];
    bannerAdIdIos = json['banner_ad_id_ios'];
    interstitialAdIdIos = json['interstitial_ad_id_ios'];
    aboutUs = json['about_us'];
    contactUs = json['contact_us'];
    termsAndCondition = json['terms_and_condition'];
    privacyPolicy = json['privacy_policy'];
    androidAppVersion = json['android_app_version'];
    iosAppVersion = json['ios_app_version'];
    androidAppLink = json['android_app_link'];
    iosAppLink = json['ios_app_link'];
    appForceUpdate = json['app_force_update'];
    appMaintenanceMode = json['app_maintenance_mode'];
    admobAdStatus = json['admob_ad_status'];
    bannerAdStatus = json['banner_ad_status'];
    interstitialAdStatus = json['interstitial_ad_status'];
    systemVersion = json['system_version'];
    serviceFile = json['service_file'];
    demoUrl = json['demo_url'];
    shareAppMessage = json['share_app_message'];
    hideFooter = json['hide_footer'];
    hideHeader = json['hide_header'];
    dualWebsite = json['dual_website'];
    primaryUrl = json['primary_url'];
    secondaryUrl = json['secondary_url'];
    firstBottomNavWeb = json['first_bottom_nav_web'];
    secondBottomNavWeb = json['second_bottom_nav_web'];
    demoMode = json['demo_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['website_url'] = this.websiteUrl;
    data['app_bar_title'] = this.appBarTitle;
    data['loader_color'] = this.loaderColor;
    data['pull_to_refresh'] = this.pullToRefresh;
    data['onboarding_screen'] = this.onboardingScreen;
    data['exit_popup_screen'] = this.exitPopupScreen;
    data['app_drawer'] = this.appDrawer;
    data['show_bottom_navigation'] = this.showBottomNavigation;
    data['style'] = this.style;
    data['admob_app_id_android'] = this.admobAppIdAndroid;
    data['banner_ad_id_android'] = this.bannerAdIdAndroid;
    data['interstitial_ad_id_android'] = this.interstitialAdIdAndroid;
    data['admob_app_id_ios'] = this.admobAppIdIos;
    data['banner_ad_id_ios'] = this.bannerAdIdIos;
    data['interstitial_ad_id_ios'] = this.interstitialAdIdIos;
    data['about_us'] = this.aboutUs;
    data['contact_us'] = this.contactUs;
    data['terms_and_condition'] = this.termsAndCondition;
    data['privacy_policy'] = this.privacyPolicy;
    data['android_app_version'] = this.androidAppVersion;
    data['ios_app_version'] = this.iosAppVersion;
    data['android_app_link'] = this.androidAppLink;
    data['ios_app_link'] = this.iosAppLink;
    data['app_force_update'] = this.appForceUpdate;
    data['app_maintenance_mode'] = this.appMaintenanceMode;
    data['admob_ad_status'] = this.admobAdStatus;
    data['banner_ad_status'] = this.bannerAdStatus;
    data['interstitial_ad_status'] = this.interstitialAdStatus;
    data['system_version'] = this.systemVersion;
    data['service_file'] = this.serviceFile;
    data['demo_url'] = this.demoUrl;
    data['share_app_message'] = this.shareAppMessage;
    data['hide_footer'] = this.hideFooter;
    data['hide_header'] = this.hideHeader;
    data['dual_website'] = this.dualWebsite;
    data['primary_url'] = this.primaryUrl;
    data['secondary_url'] = this.secondaryUrl;
    data['first_bottom_nav_web'] = this.firstBottomNavWeb;
    data['second_bottom_nav_web'] = this.secondBottomNavWeb;
    data['demo_mode'] = this.demoMode;
    return data;
  }
}
