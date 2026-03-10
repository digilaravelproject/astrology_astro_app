import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'add_astromall_listing_screen.dart';

class AstromallListingsScreen extends StatefulWidget {
  const AstromallListingsScreen({super.key});

  @override
  State<AstromallListingsScreen> createState() => _AstromallListingsScreenState();
}

class _AstromallListingsScreenState extends State<AstromallListingsScreen> with SingleTickerProviderStateMixin {
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
        title: _isSearching ? '' : 'My Astromall Listings',
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search listings...',
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
                      Tab(text: "Requests"),
                      Tab(text: "Listed"),
                    ],
                  ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsTab(),
                _buildListedTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddAstromallListingScreen()),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

    );
  }

  Widget _buildRequestsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildListingCard(
          title: index == 0 ? 'Gemstone Consultation with Astrologer' : index == 1 ? 'Name Correction' : index == 2 ? 'Vastu for Home' : 'Vastu for Santaan Prapti',
          price: index == 0 ? '499' : index == 1 ? '1000' : '2100',
          status: 'Pending for Approval',
          colorMode: 'yellow',
          image: _getImage(index),
        );
      },
    );
  }

  Widget _buildListedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildListingCard(
            title: index == 0 ? 'Name Correction' : index == 1 ? 'Birth Time Rectification' : 'Kundali Matching',
            price: index == 0 ? '577' : index == 1 ? '600' : '501',
            status: 'Already Listed',
            colorMode: 'green',
            image: _getImage(index + 4),
        );
      },
    );
  }
  
  String _getImage(int index) {
     // A placeholder logic to show different shapes/images if needed, using flutter's fallback or network images
     // Using a solid color container in UI for now if assets aren't available, but user has assets so using a grey placeholder
     return "placeholder_url";
  }

  Widget _buildListingCard({
    required String title,
    required String price,
    required String status,
    required String colorMode,
    required String image,
    String? category,
  }) {
    Color bgColor = colorMode == 'yellow' ? const Color(0xFFFEFDF0) : const Color(0xFFF2FDF6);
    Color statusColor = colorMode == 'yellow' ? Colors.grey.shade600 : Colors.green.shade600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Icon(Icons.image, color: Colors.grey)), // Placeholder for actual asset
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          AppText(title, fontWeight: FontWeight.bold, fontSize: 13, maxLines: 2),
                          const SizedBox(height: 8),
                          AppText('Listed Price : ₹ $price', color: Colors.grey.shade800, fontSize: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24), // Space for more icon
                  ],
                ),
                const SizedBox(height: 12),
                AppText(status, color: statusColor, fontSize: 11, fontWeight: FontWeight.w500),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'Edit') {
                  Get.to(() => AddAstromallListingScreen(
                        isEditing: true,
                        initialTitle: title,
                        initialPrice: price,
                        initialCategory: category ?? 'Astrology Service',
                      ));
                } else if (value == 'Delete') {
                  Get.defaultDialog(
                    title: 'Confirm Delete',
                    titleStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
                    middleText: 'Are you sure you want to delete this listing?',
                    middleTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    textCancel: 'No',
                    textConfirm: 'Yes',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red.shade600,
                    cancelTextColor: Colors.black87,
                    onConfirm: () {
                      Get.back();
                      Get.snackbar(
                        'Deleted',
                        'Listing "$title" has been removed',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade600,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  );
                } else if (value == 'Status') {
                  Get.snackbar(
                    'Status Changed',
                    'Listing status toggled',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: AppText('Edit', fontSize: 13, color: Colors.black87),
                ),
                const PopupMenuItem<String>(
                  value: 'Status',
                  child: AppText('Turn On/Off', fontSize: 13, color: Colors.black87),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: AppText('Delete', fontSize: 13, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
