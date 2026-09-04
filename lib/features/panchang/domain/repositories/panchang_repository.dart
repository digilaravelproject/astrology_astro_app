import 'package:astro_astrologer/features/panchang/data/models/panchang_model.dart';

abstract class PanchangRepository {
  Future<PanchangModel> getPanchangByDate(
    String date, {
    double? latitude,
    double? longitude,
    double? timezone,
  });
}
