import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../repository/skill_repository.dart';

class OtherDetailsController extends GetxController {
  final AstrologerSkillsRepository repository;

  OtherDetailsController({required this.repository});

  // Observables
  RxString gender = ''.obs;
  RxString currentAddress = ''.obs;
  RxString bio = ''.obs;
  RxString dateOfBirth = ''.obs;
  RxString websiteLink = ''.obs;
  RxString instagramUsername = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingSheet = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  void refreshData() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    if (user != null) {
      gender.value = user.gender ?? '';
      currentAddress.value = user.city ?? ''; // Assuming city is used as address part for now
      dateOfBirth.value = user.dateOfBirth ?? '';
      
      if (user.astrologer != null) {
        final ast = user.astrologer!;
        bio.value = ast.bio ?? '';
        // Other fields like website and instagram might not be in AstrologerModel yet
        // In a real app, these would come from the API
        websiteLink.value = 'www.starguide.com';
        instagramUsername.value = '@starguide_official';
      }
      
      Logger.d('OtherDetailsController: Data loaded from AuthController');
    }
  }

  // Update API call
  Future<bool> updateOtherDetails({bool isSilent = false}) async {
    if (!isSilent) isLoading.value = true;
    try {
      final data = {
        "gender": gender.value,
        "current_address": currentAddress.value,
        "bio": bio.value,
        "date_of_birth": dateOfBirth.value,
        "website_link": websiteLink.value,
        "instagram_username": instagramUsername.value,
      };

      final response = await repository.updateOtherDetails(data);

      if (response.isSuccess) {
        CustomSnackBar.showSuccess(response.message ?? "Updated successfully");
        
        // Refresh profile to get updated data
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value != null) {
          await authController.getProfile(authController.currentUser.value!.id);
          
          // Save updated user data to SharedPreferences
          await Get.find<AuthService>().saveUserInfo(authController.currentUser.value!);
          Logger.d('OtherDetailsController: Updated data saved to SharedPreferences');
        }
        return true;
      } else {
        CustomSnackBar.showError(response.message ?? "Failed to update");
        return false;
      }
    } catch (e) {
      Logger.e('OtherDetailsController: updateOtherDetails error: $e');
      CustomSnackBar.showError('Update failed: $e');
      return false;
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }
}