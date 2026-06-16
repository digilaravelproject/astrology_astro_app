import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/api_checker.dart';
import '../../../core/constants/app_urls.dart';
import 'user_live_viewer_screen.dart';

class LiveSessionsListScreen extends StatefulWidget {
  const LiveSessionsListScreen({super.key});

  @override
  State<LiveSessionsListScreen> createState() => _LiveSessionsListScreenState();
}

class _LiveSessionsListScreenState extends State<LiveSessionsListScreen> {
  final RxList<dynamic> liveSessions = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchLiveSessions();
  }

  Future<void> _fetchLiveSessions() async {
    try {
      isLoading.value = true;
      final apiClient = Get.find<ApiClient>();
      
      // GET /api/v1/user/live/now
      final response = await apiClient.get('/user/live/now');
      
      if (response.isSuccess) {
        if (response.body != null && response.body['data'] is List) {
          liveSessions.value = response.body['data'];
        } else {
          liveSessions.clear();
        }
      } else {
        ApiChecker.handleResponse(response);
      }
    } catch (e) {
      debugPrint("Error fetching live sessions list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Live Astrologers',
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveSessions,
        child: Obx(() {
          if (isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (liveSessions.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: liveSessions.length,
            itemBuilder: (context, index) {
              final session = liveSessions[index];
              return _buildLiveAstroCard(session);
            },
          );
        }),
      ),
    );
  }

  Widget _buildLiveAstroCard(dynamic session) {
    final astrologer = session['astrologer'] ?? {};
    final int sessionId = session['id'] ?? 0;
    final String title = session['title'] ?? 'Live Stream';
    final String name = astrologer['name'] ?? 'Astrologer';
    final String relativePhoto = astrologer['profile_photo'] ?? '';
    final String profilePhoto = relativePhoto.startsWith('http') 
        ? relativePhoto 
        : '${AppUrls.baseImageUrl}$relativePhoto';
    
    final int viewers = session['viewer_count'] ?? 0;

    return GestureDetector(
      onTap: () {
        Get.to(() => UserLiveViewerScreen(
          sessionId: sessionId,
          title: title,
          astrologerName: name,
          astrologerImage: profilePhoto,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Astrologer background Image
              Positioned.fill(
                child: Image.network(
                  profilePhoto,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 64, color: AppColors.primaryColor),
                  ),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Indicators (LIVE, Viewers)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const AppText(
                        'LIVE',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          AppText(
                            '$viewers',
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Details
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      name,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      title,
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.video_slash_copy, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const AppText(
                'No Astrologers are Live right now',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E1A47),
              ),
              const SizedBox(height: 8),
              AppText(
                'Pull down to refresh and check again.',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
