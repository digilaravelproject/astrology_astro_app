import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/remedy_controller.dart';
import '../../domain/models/remedy_model.dart';

class RemedyDetailScreen extends StatefulWidget {
  final int remedyId;
  const RemedyDetailScreen({super.key, required this.remedyId});

  @override
  State<RemedyDetailScreen> createState() => _RemedyDetailScreenState();
}

class _RemedyDetailScreenState extends State<RemedyDetailScreen> {
  late RemedyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RemedyController>();
    _controller.fetchRemedyDetails(widget.remedyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Remedy Details',
      ),
      body: Obx(() {
        if (_controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final remedy = _controller.selectedRemedy.value;
        if (remedy == null) {
          return const Center(child: AppText('Details not found', color: Colors.grey));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(remedy),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTags(),
                    const SizedBox(height: 16),
                    AppText(
                      remedy.title,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                      height: 1.2,
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),
                    _buildSectionTitle('About this Remedy'),
                    const SizedBox(height: 12),
                    AppText(
                      remedy.description,
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                    const SizedBox(height: 40),
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImageHeader(RemedyModel remedy) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
          ),
          child: Hero(
            tag: 'remedy_image_${remedy.id}',
            child: Image.network(
              remedy.image ?? 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1000',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB342).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const AppText(
        'Verified Remedy',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF7CB342),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(Iconsax.shield_tick_copy, 'Planetary Alignment', 'Positive'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _buildInfoRow(Iconsax.status_copy, 'Availability', 'In Stock'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        AppText(label, fontSize: 14, color: Colors.grey.shade600),
        const Spacer(),
        AppText(value, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
      ],
    );
  }
}
