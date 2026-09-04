import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';

class MyMembershipScreen extends StatelessWidget {
  const MyMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: CustomAppBar(title: 'My Membership'.tr),
      body: Center(
        child: AppText(
          'No Data Available'.tr,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}
