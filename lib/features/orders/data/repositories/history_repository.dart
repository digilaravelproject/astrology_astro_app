import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/call/domain/models/call_session_model.dart';

abstract class HistoryRepository {
  Future<CallSessionListResponse> getCallSessions({int page = 1});
}

class HistoryRepositoryImpl implements HistoryRepository {
  final ApiClient _apiClient;

  HistoryRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<CallSessionListResponse> getCallSessions({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '${AppUrls.astrologerCallSessions}?page=$page',
      );
      if (response.isSuccess && response.body != null) {
        return CallSessionListResponse.fromJson(response.body);
      } else {
        throw Exception(response.message ?? 'Failed to fetch call sessions');
      }
    } catch (e) {
      rethrow;
    }
  }
}
