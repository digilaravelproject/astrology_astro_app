import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'astromall_filter_bottom_sheet.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import 'astromall_listings_screen.dart';

class AstromallOrdersScreen extends StatefulWidget {
  const AstromallOrdersScreen({super.key});

  @override
  State<AstromallOrdersScreen> createState() => _AstromallOrdersScreenState();
}

class _AstromallOrdersScreenState extends State<AstromallOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: _isSearching ? '' : 'AstroMall Orders',
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search orders...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black87),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.black87),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AstromallFilterBottomSheet(),
                );
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
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
              tabs: const [
                Tab(text: "Orders"),
                Tab(text: "Chats"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(),
                _buildChatsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AstromallListingsScreen()),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.touch_app, color: Colors.white, size: 20),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppText('Astromall', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0),
            AppText('Listings', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == index;
        return GestureDetector(
          onTap: () => _tabController.animateTo(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.8) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: AppText(
                text,
                color: isSelected ? Colors.white : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildOrderCard(
          context,
          orderId: index == 0 ? '1752982547415' : index == 1 ? '1752982206840' : '1752982123171',
          date: index == 0 ? '20 Jul 25, 09:05 AM' : index == 1 ? '20 Jul 25, 09:00 AM' : '20 Jul 25, 08:58 AM',
          price: index == 1 ? '₹184.27' : '₹116.31',
          productName: index == 0 ? 'Evil Eye Protection Bracelet' : index == 1 ? 'Money & Focus Combo' : 'Rose Quartz Bracelet with Buddha',
        );
      },
    );
  }

  Widget _buildChatsTab() {
    return Center(
      child: AppText("No chats found :(", color: Colors.grey.shade500, fontSize: 16),
    );
  }

  Widget _buildOrderCard(
    BuildContext context, {
    required String orderId,
    required String date,
    required String price,
    required String productName,
  }) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Status & Actions)
            Row(
              children: [
                AppText('Indian', color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                const SizedBox(width: 8),
                AppText('CLOSED', color: Colors.green.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                const SizedBox(width: 4),
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
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
                  child: Icon(Iconsax.receipt_2_copy, color: AppColors.primaryColor.withOpacity(0.7), size: 20),
                ),
                const SizedBox(width: 12),
                const AnimatedFavoriteButton(),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Color(0xFFEEEEEE)),
            ),
            // Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade800, fontSize: 13),
                          children: [
                            const TextSpan(text: 'Order Id: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: orderId),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AppText(date, color: Colors.grey.shade600, fontSize: 11),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(price, fontWeight: FontWeight.bold, fontSize: 16),
                    AppText('Your Earnings', color: Colors.grey.shade600, fontSize: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AppText('Name: ', color: Colors.grey.shade600, fontSize: 13),
                const AppText('Kartikee (AT-GG4V2W8)', fontWeight: FontWeight.w600, fontSize: 13),
                const SizedBox(width: 6),
                Icon(Icons.copy, size: 14, color: AppColors.primaryColor.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Product Name: ', color: Colors.grey.shade600, fontSize: 13),
                Expanded(
                  child: AppText(productName, fontWeight: FontWeight.w600, fontSize: 13, maxLines: 2),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                AppText('Quantity: ', color: Colors.grey.shade600, fontSize: 13),
                const AppText('1', fontWeight: FontWeight.w600, fontSize: 13),
              ],
            ),
            const SizedBox(height: 16),
            // Action Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryColor.withOpacity(0.8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: AppText('Call with User', color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
