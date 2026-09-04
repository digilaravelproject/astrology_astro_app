import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/core/widgets/loyal_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/call/call_history_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_history_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory/Off-white
        appBar: CustomAppBar(title: 'History'.tr),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  tabs: [Tab(text: 'Call'.tr), Tab(text: 'Chat'.tr)],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    CallHistoryScreen(isFromTab: true),
                    ChatHistoryScreen(isFromTab: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
