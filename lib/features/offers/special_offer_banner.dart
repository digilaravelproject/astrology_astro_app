import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/offers/presentation/controllers/offer_controller.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/toggle_offer_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offer_history_usecase.dart';
import 'package:astro_astrologer/features/offers/data/repositories/offer_repository.dart';

class SpecialOfferBanner extends StatefulWidget {
  const SpecialOfferBanner({Key? key}) : super(key: key);

  @override
  State<SpecialOfferBanner> createState() => _SpecialOfferBannerState();
}

class _SpecialOfferBannerState extends State<SpecialOfferBanner> {
  late final OfferController _controller;

  @override
  void initState() {
    super.initState();
    // Use Get.put to make it globally available and keep it alive with HomeScreen
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
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoadingOffers.value && _controller.offers.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      if (_controller.offers.isEmpty) {
        return const SizedBox.shrink();
      }

      // Find the offer with the maximum discount percentage
      final bestOffer = _controller.offers.reduce(
        (curr, next) =>
            curr.discountPercentage > next.discountPercentage ? curr : next,
      );

      final isOfferEnabled = bestOffer.isCurrentlyActiveForMe;
      final isToggling = _controller.togglingOfferIds.contains(bestOffer.id);

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEFCE8), // Light yellow background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFDE047),
            width: 1.5,
          ), // Yellow border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF08A), // Slightly darker yellow header
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.5),
                  topRight: Radius.circular(14.5),
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFDE047), width: 1.5),
                ),
              ),
              alignment: Alignment.center,
              child: AppText('Special offer to attract new users!'.tr,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF423D00), // Dark yellow text
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '${bestOffer.discountPercentage}% off - ${bestOffer.name}',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'Activate this offer to get more ${bestOffer.calculatedPricing?.chat != null ? "chat" : ""}${bestOffer.calculatedPricing?.chat != null && bestOffer.calculatedPricing?.call != null ? " and " : ""}${bestOffer.calculatedPricing?.call != null ? "call" : ""} requests from users!',
                          fontSize: 11,
                          color: const Color(0xFF6B6B6B),
                          height: 1.4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Custom Toggle
                  GestureDetector(
                    onTap:
                        isToggling
                            ? null
                            : () => _controller.toggleOffer(bestOffer.id),
                    child:
                        isToggling
                            ? const SizedBox(
                              width: 76,
                              height: 36,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            )
                            : AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 76,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    left: isOfferEnabled ? 42 : 6,
                                    top: 6,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isOfferEnabled
                                                ? AppColors.primaryColor
                                                : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment:
                                        isOfferEnabled
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: AppText(
                                        isOfferEnabled ? 'On' : 'Off',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isOfferEnabled
                                                ? AppColors.primaryColor
                                                : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
