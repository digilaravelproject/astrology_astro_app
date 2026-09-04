import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/offers/presentation/controllers/offer_controller.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/toggle_offer_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offer_history_usecase.dart';
import 'package:astro_astrologer/features/offers/data/repositories/offer_repository.dart';
import 'package:astro_astrologer/features/offers/data/models/offer_model.dart';
import 'package:astro_astrologer/features/offers/data/models/offer_history_model.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final OfferController _controller;
  String _selectedHistoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = Get.put(
      OfferController(
        getOffersUseCase: GetOffersUseCase(
          OfferRepositoryImpl(apiClient: Get.find<ApiClient>()),
        ),
        toggleOfferUseCase: ToggleOfferUseCase(
          OfferRepositoryImpl(apiClient: Get.find<ApiClient>()),
        ),
        getOfferHistoryUseCase: GetOfferHistoryUseCase(
          OfferRepositoryImpl(apiClient: Get.find<ApiClient>()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(title: 'Offers'.tr),
      body: Column(
        children: [
          _buildInfoBanner(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAllOffersTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: AppText(
        'Loyal - Customers who have spoken with you for more than 15 minutes (including both call and chat)'
            .tr,
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.grey.shade200,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
        tabs: [
          Tab(child: Text('ALL OFFERS'.tr)),
          Tab(child: Text('HISTORY'.tr)),
        ],
      ),
    );
  }

  Widget _buildAllOffersTab() {
    return Obx(() {
      if (_controller.isLoadingOffers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.offers.isEmpty) {
        return Center(child: AppText('No offers available.'.tr));
      }
      return RefreshIndicator(
        onRefresh: () => _controller.fetchOffers(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.offers.length,
          itemBuilder: (context, index) {
            return _buildOfferCard(_controller.offers[index]);
          },
        ),
      );
    });
  }

  Widget _buildOfferCard(OfferModel offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${offer.discountPercentage}% off - ${offer.name}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final isToggling = _controller.togglingOfferIds.contains(
                        offer.id,
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isToggling
                              ? const SizedBox(
                                width: 40,
                                height: 20,
                                child: Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                              : Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: offer.isCurrentlyActiveForMe,
                                  onChanged: (v) {
                                    _controller.toggleOffer(offer.id);
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ),
                          AppText(
                            offer.isCurrentlyActiveForMe
                                ? 'Active'
                                : 'Inactive',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                if (offer.calculatedPricing?.chat != null)
                  _buildUserTypeSection(
                    'Chat Pricing',
                    '₹${offer.calculatedPricing!.chat!.baseRatePerMinute}',
                    '₹${offer.calculatedPricing!.chat!.discountedRatePerMinute}',
                    '₹${offer.calculatedPricing!.chat!.estimatedAstrologerEarningPerMinute}',
                    '₹${offer.calculatedPricing!.chat!.estimatedAdminEarningPerMinute}',
                    '₹${offer.calculatedPricing!.chat!.discountedRatePerMinute}',
                    Colors.blue.shade50,
                    Colors.blue,
                  ),
                if (offer.calculatedPricing?.chat != null)
                  const SizedBox(height: 16),
                if (offer.calculatedPricing?.call != null)
                  _buildUserTypeSection(
                    'Call Pricing',
                    '₹${offer.calculatedPricing!.call!.baseRatePerMinute}',
                    '₹${offer.calculatedPricing!.call!.discountedRatePerMinute}',
                    '₹${offer.calculatedPricing!.call!.estimatedAstrologerEarningPerMinute}',
                    '₹${offer.calculatedPricing!.call!.estimatedAdminEarningPerMinute}',
                    '₹${offer.calculatedPricing!.call!.discountedRatePerMinute}',
                    Colors.orange.shade50,
                    Colors.orange,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSection(
    String title,
    String originalPrice,
    String currentPrice,
    String yourShare,
    String atShare,
    String customerPays,
    Color tagBg,
    Color tagText,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: AppText(
                title,
                color: tagText,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                AppText(
                  originalPrice,
                  color: Colors.grey,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
                const SizedBox(width: 8),
                AppText(
                  currentPrice,
                  color: Colors.green.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPriceDetail('Your Share', yourShare),
            const SizedBox(width: 8),
            _buildPriceDetail('At Share', atShare),
            const SizedBox(width: 8),
            _buildPriceDetail('Customer pays', customerPays),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetail(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            AppText(
              label,
              fontSize: 10,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            AppText(
              value,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        _buildHistoryFilters(),
        Expanded(
          child: Obx(() {
            if (_controller.isLoadingHistory.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredHistory =
                _controller.history.where((item) {
                  if (_selectedHistoryFilter == 'All') return true;
                  return item.offerName.contains(_selectedHistoryFilter) ||
                      '${item.discountPercentage}% off' ==
                          _selectedHistoryFilter;
                }).toList();

            if (filteredHistory.isEmpty) {
              return Center(child: AppText('No history available.'.tr));
            }

            return RefreshIndicator(
              onRefresh: () => _controller.fetchHistory(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(filteredHistory[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistoryFilters() {
    final List<String> filters = ['All', '50% off', '20% off', '75% off'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedHistoryFilter == filter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: AppText(
                filter,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  _selectedHistoryFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(OfferHistoryModel historyItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  historyItem.discountPercentage > 0
                      ? '${historyItem.discountPercentage}% off - ${historyItem.offerName}'
                      : historyItem.offerName,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      historyItem.status == 'active'
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  historyItem.status.capitalizeFirst ?? historyItem.status,
                  color:
                      historyItem.status == 'active'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeDetail(
                  'Start Time *',
                  _formatDate(historyItem.activatedAt),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeDetail(
                  'End Time *',
                  historyItem.deactivatedAt != null
                      ? _formatDate(historyItem.deactivatedAt!)
                      : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr.split('.').first;
    }
  }

  Widget _buildTimeDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, fontSize: 10, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          AppText(
            value,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
