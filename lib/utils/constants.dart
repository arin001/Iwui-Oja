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
String baseurl = 'https://goldenrod-hippopotamus-556850.hostingersite.com';

String databaseUrl = '$baseurl/api/';

const appName = 'Online Course';

// Here is for only reference you have to change it from panel

String webInitialUrl = baseurl;

//Force Update
String forceUpdatee = '0'; //OFF

String message = '';
final shareAppMessage = '$message : $storeUrl';

String storeUrl = Platform.isAndroid ? '' : '';

bool showBottomNavigationBar = true;


//icon to set when get firebase messages
const String notificationIcon = '@mipmap/ic_launcher_squircle';

//turn on/off enable storage permission
const bool isStoragePermissionEnabled = true;

List<Map<String, String>> navigationTabs(BuildContext context) {
  try {
    final cubit = context.read<GetSettingCubit>();
    final state = cubit.state;

    if (state is GetSettingStateInSussess) {
      return [
        {
          'url': cubit.primaryUrl(),
          'label': cubit.firstBottomNavWeb(),
          'icon': CustomIcons.homeIcon(Theme.of(context).brightness),
        },
        {
          'url': cubit.secondaryUrl(),
          'label': cubit.secondBottomNavWeb(),
          'icon': CustomIcons.demoIcon(Theme.of(context).brightness),
        },
      ];
    }
  } catch (e) {
    print('Settings not available, using fallback navigation: $e');
  }

  // Fallback navigation tabs when settings are not available
  return [
    {
      'url': baseurl,
      'label': 'Home',
      'icon': CustomIcons.homeIcon(Theme.of(context).brightness),
    },
    {
      'url': '$baseurl/downloads/',
      'label': 'Downloads',
      'icon': CustomIcons.demoIcon(Theme.of(context).brightness),
    },
  ];
}
