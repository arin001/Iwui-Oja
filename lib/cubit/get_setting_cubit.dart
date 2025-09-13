import 'dart:io';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prime_web/data/model/get_setting_model.dart';
import 'package:prime_web/data/repositories/get_setting_repositories.dart';
import 'package:prime_web/utils/constants.dart';

abstract class GetSettingState {}

class GetSettingStateInit extends GetSettingState {}

class GetSettingStateInProgress extends GetSettingState {}

class GetSettingStateInSussess extends GetSettingState {
  final bool useAuthtoken;
  final GetSettingModel settingdata;
  GetSettingStateInSussess(
      {required this.settingdata, required this.useAuthtoken});
}

class GetSettingInError extends GetSettingState {
  String error;
  GetSettingInError({
    required this.error,
  });
}

class GetSettingCubit extends Cubit<GetSettingState> {
  GetSettingCubit() : super(GetSettingStateInit());

  Future<GetSettingModel> getSetting() async {
    emit(GetSettingStateInProgress());
    try {
      final result = await Getsetting.Getsettingrepo();
      forceUpdatee = await result.appForceUpdate.toString(); //forceUpdate
      webInitialUrl = await result.websiteUrl.toString(); // Web Initial Url
      message = await result.shareAppMessage.toString(); // Share App Message

      String checkUrl = result.dualWebsite.toString();

      if (checkUrl == '1') {
        showBottomNavigationBar = true;
      } else {
        showBottomNavigationBar = false;
      }

      //set Android And Ios App Link
      storeUrl = Platform.isAndroid
          ? result.androidAppLink.toString()
          : result.iosAppLink.toString();

      //set google add id
      interstitialAdId = await Platform.isAndroid
          ? await result.interstitialAdIdAndroid.toString()
          : await result.interstitialAdIdIos.toString();

      bannerAdId = await Platform.isAndroid
          ? await result.bannerAdIdAndroid.toString()
          : await result.bannerAdIdIos.toString();

      openAdId = await Platform.isAndroid
          ? await result.admobAppIdAndroid.toString()
          : await result.admobAppIdIos.toString();

      emit(
        GetSettingStateInSussess(useAuthtoken: false, settingdata: result),
      );
    } catch (e) {
      GetSettingInError(error: e.toString());
    }
    return GetSettingModel.fromJson({});
  }

  String primaryUrl() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String url = data.primaryUrl.toString();
    return url;
  }

  String secondaryUrl() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String url = data.secondaryUrl.toString();
    return url;
  }

  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }

  Color loadercolor() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String loadercolor = data.loaderColor.toString();
    Color loadercolorr = hexToColor(loadercolor);
    return loadercolorr;
  }

  bool onboardingStatus() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.onboardingScreen)!;
    return status;
  }

  bool pullToRefresh() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.pullToRefresh)!;
    return status;
  }

  String onbordingStyle() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String style = data.style.toString();
    return style;
  }

  // bool showAppDrawer() {
  //   GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
  //   bool status = (data.appDrawer)!;
  //   return status;
  // }

  bool showExitPopupScreen() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.exitPopupScreen)!;
    return status;
  }

  String maintenanceMode() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String mode = data.appMaintenanceMode.toString();
    return mode;
  }

  String forceUpdate() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String status = data.appForceUpdate.toString();
    return status;
  }

  String androidAppVertion() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String version = data.androidAppVersion.toString();
    return version;
  }

  String iosVertion() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String version = data.iosAppVersion.toString();
    return version;
  }

  String? contactUS() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    return data.contactUs;
  }

  String? termsPage() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    return data.termsAndCondition;
  }

  String? privacyPage() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    return data.privacyPolicy;
  }

  String? aboutPage() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    return data.aboutUs;
  }

  String appbarTitlestyle() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String style = data.appBarTitle.toString();
    return style;
  }

  bool showInterstitialAds() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.interstitialAdStatus)!;
    return status;
  }

  bool showBannerAds() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.bannerAdStatus)!;
    return status;
  }

  bool showOpenAds() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.admobAdStatus)!;
    return status;
  }

  bool hideHeader() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.hideHeader!);
    return status;
  }

  bool hideFooter() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    bool status = (data.hideFooter!);
    return status;
  }

  String firstBottomNavWeb() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String text = data.firstBottomNavWeb.toString();
    return text;
  }

  String secondBottomNavWeb() {
    GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
    String text = data.secondBottomNavWeb.toString();
    return text;
  }
}
