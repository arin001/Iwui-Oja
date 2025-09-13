import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:prime_web/cubit/get_setting_cubit.dart';
import 'package:prime_web/utils/constants.dart';

class ContactusScreen extends StatelessWidget {
  const ContactusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.read<GetSettingCubit>().contactUS();
    return Scaffold(
      appBar: AppBar(
        title: Text(CustomStrings.contactUs),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: data == null || (data.isEmpty)
                  ? Center(
                      child: Text('NO DATA'),
                    )
                  : HtmlWidget(data),
            ),
          ],
        ),
      ),
    );
  }
}
