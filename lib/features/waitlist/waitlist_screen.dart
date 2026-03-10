import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import '../../../../core/widgets/loyal_badge.dart';

class WaitlistScreen extends StatelessWidget {
  const WaitlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Waitlist',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                   Get.snackbar('Refreshing', 'Waitlist is refreshing...', snackPosition: SnackPosition.BOTTOM);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const AppText('Refresh', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 1, // Just one static card as per visual request for now
              itemBuilder: (context, index) {
                return _buildWaitlistCard(context);
              },
            ),
          ),
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildWaitlistCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with banner
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 16, bottom: 12, right: 16),
                child: Row(
                  children: [
                    AppText('Repeat (indian)', color: Colors.blue.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                    const SizedBox(width: 8),
                    Container(height: 14, width: 1, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    const AppText('Waiting', color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: AddNoteBottomSheet(),
                          ),
                        );
                      },
                      child: Icon(Iconsax.document_copy, size: 18, color: Colors.grey.shade400),
                    ),
                    const SizedBox(width: 12),
                    const AnimatedFavoriteButton(),
                  ],
                ),
              ),
              LoyalBadge.positioned(),
            ],
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                    ),
                    const SizedBox(width: 8),
                    AppText('Astrotalk (#338579629)', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ],
                ),
                const SizedBox(height: 8),
                AppText('20 Feb 26, 10:50 AM', fontSize: 12, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                _buildRowItem('Name', 'Kishore (AT-ZDXL297)', showCopy: true),
                const SizedBox(height: 8),
                _buildRowItem('Type', 'Chat'),
                const SizedBox(height: 8),
                _buildRowItem('Token', '1'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.person, color: Colors.white, size: 18),
                    label: const AppText('Chat Assistant', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const AppText('Start Offline Session', color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool showCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 60, child: AppText(label, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const AppText(' :  ', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        AppText(value, fontSize: 13, color: Colors.black87),
        if (showCopy) ...[
          const SizedBox(width: 8),
          Icon(Icons.copy_outlined, size: 16, color: AppColors.primaryColor),
        ]
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppText('Offline sessions monthly limit: 7/150', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
            const SizedBox(height: 6),
            const AppText('System allows maximum 150 offline sessions a month.', fontSize: 12, color: Colors.black87, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            AppText('However, if your last 7 days average daily busy time is more than 3 hrs, limit increases.', fontSize: 12, color: Colors.black87, textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}
