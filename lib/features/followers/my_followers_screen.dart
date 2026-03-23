import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/chat/chat_history_screen.dart';
import 'package:astro_astrologer/features/kundli/kundli_list_screen.dart';
import 'package:astro_astrologer/features/chat/assistant_chat_sort_bottom_sheet.dart';
import '../../../core/utils/date_formatter.dart';
import '../home/widgets/animated_favorite_button.dart';
import 'controllers/follower_controller.dart';
import 'domain/models/follower_model.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FollowerController followerController = Get.find<FollowerController>();
  
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
    _tabController.addListener(() {
      // Clear search when switching tabs if needed
      if (!_tabController.indexIsChanging) {
        followerController.updateSearch('');
        _searchController.clear();
      }
    });
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
                Obx(() => _buildCircularBadge(followerController.followerCount.value.toString())),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Favourites'),
                const SizedBox(width: 2),
                Obx(() => _buildCircularBadge(followerController.favoriteCount.value.toString())),
              ],
            ),
          ),
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
    return Column(
      children: [
        _buildSearchInput(
          controller: _searchController,
          onChanged: followerController.updateSearch,
        ),
        Expanded(
          child: Obx(() {
            if (followerController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final list = followerController.filteredFollowers;
            
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.user_copy, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    AppText(
                      followerController.searchQuery.isNotEmpty 
                        ? 'No followers match "${followerController.searchQuery.value}"' 
                        : 'No followers found', 
                      color: Colors.grey.shade600, fontSize: 16
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final follower = list[index];
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
                      _buildAvatarFromModel(follower),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(follower.name, fontWeight: FontWeight.w600, fontSize: 14),
                            const SizedBox(height: 2),
                            if (follower.followedAt != null)
                              AppText(
                                DateFormatter.formatDateTime(DateTime.parse(follower.followedAt!)),
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                          ],
                        ),
                      ),
                      AnimatedFavoriteButton(
                        isFavorite: follower.isLiked,
                        onTap: () => followerController.toggleLike(follower.userId),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFavouritesTab() {
    return Column(
      children: [
        _buildSearchInput(
          controller: _searchController,
          onChanged: followerController.updateSearch,
        ),
        Expanded(
          child: Obx(() {
            if (followerController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final list = followerController.filteredFavorites;
            
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.heart_copy, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    AppText(
                      followerController.searchQuery.isNotEmpty 
                        ? 'No favorites match "${followerController.searchQuery.value}"' 
                        : 'No Data Available', 
                      color: Colors.grey.shade700, fontSize: 16
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final favorite = list[index];
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
                      _buildAvatarFromModel(favorite),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(favorite.name, fontWeight: FontWeight.w600, fontSize: 14),
                            const SizedBox(height: 2),
                            if (favorite.likedAt != null)
                              AppText(
                                'Liked: ${DateFormatter.formatDateTime(DateTime.parse(favorite.likedAt!))}', 
                                color: Colors.grey, 
                                fontSize: 11
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAvatarFromModel(FollowerModel follower) {
    // Generate a consistent color based on the name
    final List<Color> avatarColors = [
      Colors.deepPurple.shade100,
      Colors.orange.shade100,
      Colors.amber.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.pink.shade100,
    ];
    final int colorIndex = follower.name.length % avatarColors.length;
    final String initial = follower.name.isNotEmpty ? follower.name[0].toUpperCase() : '?';

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColors[colorIndex],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchInput({TextEditingController? controller, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
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
