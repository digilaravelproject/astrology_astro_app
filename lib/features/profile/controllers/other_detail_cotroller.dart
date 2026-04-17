import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/services/auth_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../repository/skill_repository.dart';
import '../model/other_details_model.dart';

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
    // Listen to current user changes and refresh local observables
    ever(Get.find<AuthController>().currentUser, (_) => refreshData());
  }

  @override
  void onReady() {
    super.onReady();
    // Force a fresh profile load when screen opens to catch 'other_details'
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value != null) {
      Logger.d('OtherDetailsController: Forcing fresh profile load onReady...');
      authController.getProfile(authController.currentUser.value!.id);
    }
  }

  void refreshData() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    
    Logger.d('OtherDetailsController: refreshData called. User: ${user?.name}, Has Astrologer: ${user?.astrologer != null}');
    
    if (user != null) {
      gender.value = user.gender ?? '';
      dateOfBirth.value = user.dateOfBirth ?? '';
      
      if (user.astrologer != null) {
        final ast = user.astrologer!;
        bio.value = ast.bio ?? '';
        
        Logger.d('OtherDetailsController: Astrologer found. Has otherDetails: ${ast.otherDetails != null}');
        
        if (ast.otherDetails != null) {
          final other = ast.otherDetails!;
          Logger.d('OtherDetailsController: Mapping otherDetails. Address: ${other.currentAddress}');
          
          gender.value = other.gender ?? gender.value;
          currentAddress.value = other.currentAddress ?? '';
          dateOfBirth.value = other.dateOfBirth ?? dateOfBirth.value;
          bio.value = other.bio ?? bio.value;
          websiteLink.value = other.websiteLink ?? '';
          instagramUsername.value = other.instagramUsername ?? '';
        } else {
          Logger.d('OtherDetailsController: otherDetails is NULL in AstrologerModel');
        }
      }
      
      Logger.d('OtherDetailsController: Final values - Address: ${currentAddress.value}, Bio: ${bio.value}');
    }
  }

  // Update API call
  Future<bool> updateOtherDetails({bool isSilent = false}) async {
    if (!isSilent) isLoading.value = true;
    try {
      final model = OtherDetailsModel(
        gender: gender.value.toLowerCase(),
        currentAddress: currentAddress.value,
        bio: bio.value,
        dateOfBirth: dateOfBirth.value,
        websiteLink: websiteLink.value,
        instagramUsername: instagramUsername.value,
      );

      final response = await repository.updateOtherDetails(model.toJson());

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