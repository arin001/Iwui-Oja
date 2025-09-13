import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/main.dart';
import 'package:prime_web/ui/screens/setting_screens/aboutUs_screen.dart';
import 'package:prime_web/ui/screens/setting_screens/contactUs_screen.dart';
import 'package:prime_web/ui/screens/setting_screens/privacyPolicy_screen.dart';
import 'package:prime_web/ui/screens/setting_screens/term_and_condition.dart';
import 'package:prime_web/ui/widgets/glassmorphism_container.dart';
import 'package:prime_web/ui/widgets/widgets.dart';
import 'package:prime_web/utils/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin<SettingsScreen> {
  @override
  bool get wantKeepAlive => true;
  final _inAppReview = InAppReview.instance;

  void initState() {
    super.initState();
    if (context.read<GetSettingCubit>().showInterstitialAds()) {
      AdMobService.createInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GlassmorphismContainer(
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(CustomStrings.settings),
            backgroundColor: Colors.transparent,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _homeFloatingAction,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                /// Dark Mode
                const SettingTile(
                  leadingIcon: CustomIcons.darkModeIcon,
                  title: CustomStrings.darkMode,
                  trailing: ChangeThemeButtonWidget(),
                ),
                // About us
                SettingTile(
                  leadingIcon: CustomIcons.aboutUsIcon,
                  title: CustomStrings.aboutUs,
                  onTap: () {
                    _onPressed(AboutUsScreen());
                  },
                ),

                // Privacy Policy
                SettingTile(
                  leadingIcon: CustomIcons.shareIcon,
                  title: CustomStrings.privacyPolicy,
                  onTap: () {
                    _onPressed(PrivacyPolicyScreen());
                  },
                ),

                // Terms & Conditions

                SettingTile(
                  leadingIcon: CustomIcons.termsIcon,
                  title: CustomStrings.terms,
                  onTap: () {
                    _onPressed(TermAndCondition());
                  },
                ),

                // contact_us
                SettingTile(
                  leadingIcon: CustomIcons.contactIcon,
                  title: CustomStrings.contactUs,
                  onTap: () {
                    _onPressed(ContactusScreen());
                  },
                ),

                /// Share
                SettingTile(
                  leadingIcon: CustomIcons.shareIcon,
                  title: CustomStrings.share,
                  onTap: () => Share.share(
                    shareAppMessage,
                    subject: shareAppMessage,
                  ),
                ),

                /// Rate Us
                SettingTile(
                  leadingIcon: CustomIcons.rateUsIcon,
                  title: CustomStrings.rateUs,
                  onTap: () async {
                    if (await _inAppReview.isAvailable()) {
                      await _inAppReview
                          .requestReview()
                          .then((value) => _rateApp(context))
                          .onError(
                            (error, stackTrace) => log('[RateUs] : $error'),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _homeFloatingAction => !showBottomNavigationBar
      ? FloatingActionButton(
          onPressed: Navigator.of(context).pop,
          child: Lottie.asset(
            CustomIcons.homeIcon(Theme.of(context).brightness),
            height: 30,
            repeat: true,
          ),
        )
      : const SizedBox.shrink();

  Future<void> _rateApp(BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(storeUrl))) {
      await launchUrl(Uri.parse(storeUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again'),
        ),
      );
    }
  }

  void _onPressed(Widget routeName) {
    if (context.read<GetSettingCubit>().showInterstitialAds()) {
      AdMobService.showInterstitialAd();
    }

    navigatorKey.currentState!.push(
      CupertinoPageRoute<dynamic>(builder: (_) => routeName),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.leadingIcon,
    required this.title,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String leadingIcon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SvgPicture.asset(
            leadingIcon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!,
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
          onTap: onTap,
        ),
        Divider(
          color: Colors.grey.withValues(alpha: .5),
          indent: 20,
          endIndent: 20,
        )
      ],
    );
  }
}
