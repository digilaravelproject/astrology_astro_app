import '../../data/models/panchang_model.dart';
import '../repositories/panchang_repository.dart';

class GetPanchangUseCase {
  final PanchangRepository repository;

  GetPanchangUseCase({required this.repository});

  Future<PanchangModel> call(
    String date, {
    double? latitude,
    double? longitude,
    double? timezone,
  }) async {
    return await repository.getPanchangByDate(
      date,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}
