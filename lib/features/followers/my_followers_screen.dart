import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/chat/chat_history_screen.dart';
import 'package:astro_astrologer/features/kundli/kundli_list_screen.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import 'package:astro_astrologer/features/chat/assistant_chat_sort_bottom_sheet.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // State for Always Online toggles
  final List<Map<String, dynamic>> _alwaysOnlineUsers = [
    {'name': 'Rohini (AT-ZDXL297)', 'spent': '₹ 1,000+', 'lastSession': '20 Feb, 26', 'isOnline': false},
    {'name': 'Pallavi (AT-MKK63GE)', 'spent': '₹ 1,000+', 'lastSession': '19 Feb, 26', 'isOnline': true},
    {'name': 'Saurabh (AT-XYRQXZ7)', 'spent': '₹ 500+', 'lastSession': '19 Feb, 26', 'isOnline': false},
    {'name': 'Pooja Desai (AT-VLQM7E)', 'spent': '₹ 1,000+', 'lastSession': '19 Feb, 26', 'isOnline': false},
    {'name': 'HARSHADA PURUSHOTTAM PRATIKSHA (AT-V468LEM)', 'spent': null, 'lastSession': null, 'isOnline': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'My Community',
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowersTab(),
                _buildFavouritesTab(),
                _buildAlwaysOnlineTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Poppins'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10, fontFamily: 'Poppins'),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Followers'),
                const SizedBox(width: 2),
                _buildCircularBadge('1761'),
              ],
            ),
          ),
          const Tab(child: Text('Favourites')),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Online'),
                const SizedBox(width: 2),
                _buildCircularBadge('2164'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppText(
        count,
        color: Colors.white,
        fontSize: 7,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFollowersTab() {
    final followers = [
      {'name': 'Sushmita (AT-6WDZMM4)', 'date': '17 May 2024', 'initial': 'S', 'color': Colors.deepPurple.shade100},
      {'name': 'Sakshi Pandey (AT-VX7X9ZE)', 'date': '17 May 2024', 'initial': 'S', 'color': Colors.orange.shade100},
      {'name': 'Anil singh tanwar (AT-XV7G4GM)', 'date': '17 May 2024', 'initial': 'A', 'color': Colors.amber.shade100},
      {'name': 'Manmohan (AT-L7QMWM4)', 'date': '17 May 2024', 'image': 'zodiac_cancer'},
      {'name': 'Manjula Rao (AT-YDQ39QL)', 'date': '17 May 2024', 'icon': Icons.person_outline},
      {'name': 'RAGHURAJ (AT-KDDV8LQ)', 'date': '17 May 2024', 'icon': Icons.person_outline},
      {'name': 'Shikha (AT-RX22QX7)', 'date': '17 May 2024', 'icon': Icons.person_outline},
      {'name': 'Neha (AT-V3EW9X3)', 'date': '17 May 2024', 'icon': Icons.person_outline},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final f = followers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              _buildAvatar(f),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(f['name'] as String, fontWeight: FontWeight.w600, fontSize: 14),
                    const SizedBox(height: 2),
                    AppText(f['date'] as String, color: Colors.grey, fontSize: 12),
                  ],
                ),
              ),
              const AnimatedFavoriteButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(Map<String, dynamic> f) {
    if (f.containsKey('image')) {
      return Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFF9C4)),
        child: const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 24), // Placeholder for zodiac icon
      );
    }
    if (f.containsKey('initial')) {
      return Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(shape: BoxShape.circle, color: f['color'] as Color),
        alignment: Alignment.center,
        child: Text(f['initial'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      );
    }
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
      child: Icon(f['icon'] as IconData, color: Colors.black54),
    );
  }

  Widget _buildFavouritesTab() {
    return Column(
      children: [
        _buildSearchInput(),
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText('No Data Available', color: Colors.grey.shade700, fontSize: 16),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by Name',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: null,
          suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildAlwaysOnlineTab() {
    final alwaysOnlineUsers = [
      {'name': 'Rohini (AT-ZDXL297)', 'spent': '₹ 1,000+', 'lastSession': '20 Feb, 26'},
      {'name': 'Pallavi (AT-MKK63GE)', 'spent': '₹ 1,000+', 'lastSession': '19 Feb, 26'},
      {'name': 'Saurabh (AT-XYRQXZ7)', 'spent': '₹ 500+', 'lastSession': '19 Feb, 26'},
      {'name': 'Pooja Desai (AT-VLQM7E)', 'spent': '₹ 1,000+', 'lastSession': '19 Feb, 26'},
      {'name': 'HARSHADA PURUSHOTTAM PRATIKSHA (AT-V468LEM)', 'spent': null, 'lastSession': null},
    ];

    return Column(
      children: [
        _buildAlwaysOnlineHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(child: _buildSearchInputPaddingFree()),
              const SizedBox(width: 8),
              _buildSortButton(),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _alwaysOnlineUsers.length,
            itemBuilder: (context, index) {
              final user = _alwaysOnlineUsers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: AppText(user['name'] as String, fontWeight: FontWeight.bold, fontSize: 15)),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: user['isOnline'] as bool,
                            onChanged: (v) {
                              setState(() {
                                _alwaysOnlineUsers[index]['isOnline'] = v;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (user['spent'] != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildChip('Spent - ${user['spent']}'),
                          const SizedBox(width: 8),
                          _buildChip('Last Session - ${user['lastSession']}'),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlwaysOnlineHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              AppText('Always Online', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade800),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            'This feature allows selected users to start a session with you even when you’re not online. Use it to stay connected with your important users. They will be able to reach out to you anytime.',
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputPaddingFree() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by Name',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        suffixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, color: AppColors.primaryColor, size: 18),
            const SizedBox(width: 4),
            AppText('Sort', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(label, fontSize: 11, color: Colors.black54),
    );
  }
}
