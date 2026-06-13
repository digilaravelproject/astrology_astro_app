import 'package:get/get.dart';
import '../../domain/models/weekly_ranking_model.dart';
import '../../domain/repositories/i_wallet_repository.dart';

class WeeklyRankingController extends GetxController {
  final IWalletRepository _walletRepository;

  WeeklyRankingController(this._walletRepository);

  final RxBool isLoading = true.obs;
  final Rx<WeeklyRankingData?> rankingData = Rx<WeeklyRankingData?>(null);
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRankings();
  }

  Future<void> fetchRankings() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final data = await _walletRepository.getWeeklyRankings();
      rankingData.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
