import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/loyal_badge.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/chat/assistant_chat_sort_bottom_sheet.dart';
import 'package:astro_astrologer/features/offers/discounted_session_screen.dart';
import 'package:astro_astrologer/features/chat/chat_screen.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Placeholder navigation to a chat screen
  void _navigateToChat() {
     Get.to(() => const ChatScreen(request: {'user': 'Assistant Chat User'}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Assistant Chat',
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined, color: Colors.black87),
            onPressed: () {
              Get.to(() => const DiscountedSessionScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              dividerColor: Colors.grey.shade300,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Active Users"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.5), // Pinkish
                          shape: BoxShape.circle,
                        ),
                        child: const AppText('7', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Connect Again"),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const AppText('49', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveUsersTab(),
                _buildConnectAgainTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildActiveUserCard();
      },
    );
  }

  Widget _buildConnectAgainTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: OutlinedButton.icon(
             onPressed: () {
               showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: AssistantChatSortBottomSheet(),
                  ),
                );
             },
             icon: const Icon(Icons.swap_vert, size: 18, color: Colors.black87),
             label: const AppText('Sort', color: Colors.black87, fontWeight: FontWeight.w500),
             style: OutlinedButton.styleFrom(
               side: BorderSide(color: AppColors.primaryColor.withOpacity(0.5)),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
             ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildConnectAgainCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveUserCard() {
    return GestureDetector(
      onTap: _navigateToChat,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 32), // Spacer for the ribbon
                      Expanded(
                        child: AppText('Harshala (AT-RKWK95Z)', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      const AnimatedFavoriteButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppText('sorry kal mai dekh nahi paya tha aapka message aaj...', fontSize: 12, color: Colors.grey.shade600, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const AppText('1', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText('09:39 AM', fontSize: 10, color: Colors.grey.shade400),
                ],
              ),
            ),
            LoyalBadge.positioned(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectAgainCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText('Renu (AT-LW74YZ9)', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, overflow: TextOverflow.ellipsis),
                    ),
                    const AnimatedFavoriteButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText('Spent - 120', fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: AppText('Last Session - 19 Feb 2026 , 02:36 PM', fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToChat,
                    icon: Icon(Iconsax.message_text_1_copy, size: 18, color: Colors.green.shade700),
                    label: AppText('Start Assistant Chat', color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
               color: Colors.grey.shade50,
               borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
               border: Border(top: BorderSide(color: Colors.grey.shade200))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Add/View Notes', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
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
                  child: Icon(Iconsax.note_2_copy, color: AppColors.primaryColor.withOpacity(0.6), size: 18)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
