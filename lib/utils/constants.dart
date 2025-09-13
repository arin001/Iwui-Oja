import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/utils/icons.dart';

export '../ui/styles/colors.dart';
export 'icons.dart';
export 'strings.dart';

const String androidPackageName = 'com.onlinecourse.pheichon';

/// DO NOT ADD / AT THE END OF URL
String baseurl = 'https://darkorange-sardine-183079.hostingersite.com';

String databaseUrl = '$baseurl/api/';

const appName = 'Online Course';

// Here is for only reference you have to change it from panel

String webInitialUrl = '';

//Force Update
String forceUpdatee = '0'; //OFF

String message = '';
final shareAppMessage = '$message : $storeUrl';

String storeUrl = Platform.isAndroid ? '' : '';

bool showBottomNavigationBar = true;

/// Ad Ids
String interstitialAdId = Platform.isAndroid ? '' : '';
String bannerAdId = Platform.isAndroid ? '' : '';
String openAdId = Platform.isAndroid ? '' : '';

//icon to set when get firebase messages
const String notificationIcon = '@mipmap/ic_launcher_squircle';

//turn on/off enable storage permission
const bool isStoragePermissionEnabled = true;

List<Map<String, String>> navigationTabs(BuildContext context) => [
      {
        'url': context.read<GetSettingCubit>().primaryUrl(),
        'label': context.read<GetSettingCubit>().firstBottomNavWeb(),
        'icon': CustomIcons.homeIcon(Theme.of(context).brightness),
      },
      {
        'url': context.read<GetSettingCubit>().secondaryUrl(),
        'label': context.read<GetSettingCubit>().secondBottomNavWeb(),
        'icon': CustomIcons.demoIcon(Theme.of(context).brightness),
      },
    ];
