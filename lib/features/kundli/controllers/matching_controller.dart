import 'package:get/get.dart';
import '../models/matching_request_model.dart';
import '../models/matching_response_model.dart';
import '../usecases/get_matching_usecase.dart';

class MatchingController extends GetxController {
  final GetMatchingUseCase getMatchingUseCase;

  MatchingController({required this.getMatchingUseCase});

  final Rx<MatchingResponseModel?> matchingData = Rx<MatchingResponseModel?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String boyName = '';
  String boyGender = 'Male';
  String boyDobRaw = '';
  String boyTobRaw = '';
  String boyPlace = '';
  double boyLatVal = 0.0;
  double boyLngVal = 0.0;

  String girlName = '';
  String girlGender = 'Female';
  String girlDobRaw = '';
  String girlTobRaw = '';
  String girlPlace = '';
  double girlLatVal = 0.0;
  double girlLngVal = 0.0;

  Future<void> fetchMatchingData({
    String boyName = '',
    String boyGender = 'Male',
    required String boyDob,
    required String boyTob,
    String boyPlace = '',
    required double boyLat,
    required double boyLng,
    required String boyTz,
    String girlName = '',
    String girlGender = 'Female',
    required String girlDob,
    required String girlTob,
    String girlPlace = '',
    required double girlLat,
    required double girlLng,
    required String girlTz,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      this.boyName = boyName;
      this.boyGender = boyGender;
      this.boyDobRaw = boyDob;
      this.boyTobRaw = boyTob;
      this.boyPlace = boyPlace;
      this.boyLatVal = boyLat;
      this.boyLngVal = boyLng;

      this.girlName = girlName;
      this.girlGender = girlGender;
      this.girlDobRaw = girlDob;
      this.girlTobRaw = girlTob;
      this.girlPlace = girlPlace;
      this.girlLatVal = girlLat;
      this.girlLngVal = girlLng;

      print('[MATCHING_APP] [DEBUG] Controller: Fetching matching data');
      print(
        '[MATCHING_APP] [DEBUG] Boy DOB: $boyDob, TOB: $boyTob, Lat: $boyLat, Lng: $boyLng, TZ: $boyTz',
      );
      print(
        '[MATCHING_APP] [DEBUG] Girl DOB: $girlDob, TOB: $girlTob, Lat: $girlLat, Lng: $girlLng, TZ: $girlTz',
      );

      // Build ISO datetime strings: "2001-07-21T04:52:00"
      final maleDatetime = "${boyDob}T$boyTob";
      final femaleDatetime = "${girlDob}T$girlTob";

      final request = MatchingRequestModel(
        male: PersonDetails(
          datetime: maleDatetime,
          latitude: boyLat,
          longitude: boyLng,
          timezone: boyTz,
        ),
        female: PersonDetails(
          datetime: femaleDatetime,
          latitude: girlLat,
          longitude: girlLng,
          timezone: girlTz,
        ),
      );

      final result = await getMatchingUseCase.call(request);

      matchingData.value = result;
      print(
        '[MATCHING_APP] [DEBUG] Controller: Matching data set successfully',
      );
      print(
        '[MATCHING_APP] [DEBUG] Compatibility Score: ${result.data.compatibilityScore}',
      );
    } catch (e) {
      print('[MATCHING_APP] [ERROR] Controller: Failed to load matching: $e');
      errorMessage.value = 'Failed to load matching data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    matchingData.value = null;
    errorMessage.value = '';
  }
}
