import 'package:get/get.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/other_details_model.dart';
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

  // Update API call
  Future<void> updateOtherDetails() async {
    final data = {
      "gender": gender.value,
      "current_address": currentAddress.value,
      "bio": bio.value,
      "date_of_birth": dateOfBirth.value,
      "website_link": websiteLink.value,
      "instagram_username": instagramUsername.value,
    };

    final response = await repository.updateOtherDetails(data);

    if (response.isSuccess && response.body != null) {
      CustomSnackBar.showSuccess(response.message ?? "Updated successfully");
    } else {
      CustomSnackBar.showError(response.message ?? "Failed to update");
    }
  }
}