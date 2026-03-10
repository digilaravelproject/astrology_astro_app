import 'package:flutter/material.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class MyMembershipScreen extends StatelessWidget {
  const MyMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: 'My Membership',
      ),
      body: Center(
        child: AppText(
          'No Data Available',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }
}
