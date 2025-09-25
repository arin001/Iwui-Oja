import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
      debugPrint('API Settings Response - websiteUrl: ${result.websiteUrl}, primaryUrl: ${result.primaryUrl}, secondaryUrl: ${result.secondaryUrl}');

      forceUpdatee = await result.appForceUpdate.toString(); //forceUpdate
      // Force use website URL from constants instead of API response
      webInitialUrl = baseurl; // Use website URL from constants.dart
      debugPrint('Forcing webInitialUrl to website URL: $webInitialUrl');

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


      emit(
        GetSettingStateInSussess(useAuthtoken: false, settingdata: result),
      );
    } catch (e) {
      // On API failure, ensure webInitialUrl has a valid fallback to server URL
      webInitialUrl = baseurl;
      emit(GetSettingInError(error: e.toString()));
    }
    return GetSettingModel.fromJson({});
  }

  String primaryUrl() {
    // Force use website URL from constants instead of API response
    debugPrint('primaryUrl returning website URL: $baseurl');
    return baseurl;
  }

  String secondaryUrl() {
    // Force use downloads page from website URL
    final downloadsUrl = '$baseurl/downloads/';
    debugPrint('secondaryUrl returning downloads URL: $downloadsUrl');
    return downloadsUrl;
  }

  Color hexToColor(String hexString, {String alphaChannel = 'FF'}) {
    return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
  }

  Color loadercolor() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        String loadercolor = data.loaderColor.toString();
        Color loadercolorr = hexToColor(loadercolor);
        return loadercolorr;
      }
    } catch (e) {
      print('Error getting loader color: $e');
    }
    return const Color(0xFF4CAF50); // Default green color
  }

  bool onboardingStatus() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        bool status = (data.onboardingScreen)!;
        return status;
      }
    } catch (e) {
      print('Error getting onboarding status: $e');
    }
    return false; // Default to not showing onboarding
  }

  bool pullToRefresh() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        bool status = (data.pullToRefresh)!;
        return status;
      }
    } catch (e) {
      print('Error getting pull to refresh status: $e');
    }
    return true; // Default to allowing pull to refresh
  }

  String onbordingStyle() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        String style = data.style.toString();
        return style;
      }
    } catch (e) {
      print('Error getting onboarding style: $e');
    }
    return 'style1'; // Default style
  }

  // bool showAppDrawer() {
  //   GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
  //   bool status = (data.appDrawer)!;
  //   return status;
  // }

  bool showExitPopupScreen() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        bool status = (data.exitPopupScreen)!;
        return status;
      }
    } catch (e) {
      print('Error getting exit popup status: $e');
    }
    return true; // Default to showing exit popup
  }

  String maintenanceMode() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        String mode = data.appMaintenanceMode.toString();
        return mode;
      }
    } catch (e) {
      print('Error getting maintenance mode: $e');
    }
    return '0'; // Default to no maintenance mode
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


  bool hideHeader() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        bool status = (data.hideHeader!);
        return status;
      }
    } catch (e) {
      print('Error getting hide header status: $e');
    }
    return false; // Default to not hiding header
  }

  bool hideFooter() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        bool status = (data.hideFooter!);
        return status;
      }
    } catch (e) {
      print('Error getting hide footer status: $e');
    }
    return false; // Default to not hiding footer
  }

  String firstBottomNavWeb() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        String text = data.firstBottomNavWeb.toString();
        return text;
      }
    } catch (e) {
      print('Error getting first bottom nav text: $e');
    }
    return 'Home'; // Default label
  }

  String secondBottomNavWeb() {
    try {
      if (state is GetSettingStateInSussess) {
        GetSettingModel data = (state as GetSettingStateInSussess).settingdata;
        String text = data.secondBottomNavWeb.toString();
        return text;
      }
    } catch (e) {
      print('Error getting second bottom nav text: $e');
    }
    return 'Downloads'; // Default label
  }
}
