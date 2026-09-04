import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:astro_astrologer/features/wallet/data/models/invoice_model.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_invoices_summary_usecase.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class InvoiceController extends GetxController {
  final GetInvoicesSummaryUseCase _getInvoicesSummaryUseCase;

  InvoiceController(this._getInvoicesSummaryUseCase);

  final Rx<InvoiceSummaryModel?> summary = Rx<InvoiceSummaryModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Track downloading states by month string (e.g. "January 2026")
  final RxMap<String, bool> isDownloading = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    try {
      isLoading.value = true;
      error.value = '';
      summary.value = await _getInvoicesSummaryUseCase.execute();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadInvoice(String monthName, String downloadUrl) async {
    if (isDownloading[monthName] == true) return;

    try {
      isDownloading[monthName] = true;

      // Ensure URL is complete
      String url = downloadUrl;
      if (!url.startsWith('http')) {
        url = '${AppUrls.baseUrl.replaceAll('/api/v1', '')}$downloadUrl';
      }

      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        CustomSnackBar.showError('Authentication error. Please login again.');
        return;
      }

      // Safe year/month extraction
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      String year = '2026';
      String month = '08';

      if (pathSegments.isNotEmpty) {
        if (pathSegments.length >= 3) {
          month = pathSegments[pathSegments.length - 2];
          year = pathSegments[pathSegments.length - 3];
        } else if (pathSegments.length >= 2) {
          month = pathSegments[pathSegments.length - 1];
          year = pathSegments[pathSegments.length - 2];
        } else {
          month = pathSegments[pathSegments.length - 1];
        }
      }

      final String fileName = 'invoice_${year}_$month.pdf';

      // Determine safe directory - external storage is safer for user visibility
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getTemporaryDirectory();

      final String savePath = '${dir.path}/$fileName';

      // Download file with Auth header
      final Dio dio = Dio();
      final response = await dio.download(
        url,
        savePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Safe check file exists
        final file = File(savePath);
        if (await file.exists()) {
          try {
            final result = await OpenFilex.open(savePath);
            if (result.type != ResultType.done) {
              CustomSnackBar.showInfo(
                'Downloaded to: $fileName. Opening manually is recommended.',
              );
            }
          } catch (openEx) {
            // Fallback snackbar if default PDF handler crashes
            CustomSnackBar.showInfo('Invoice saved to Downloads directory.');
          }
        } else {
          CustomSnackBar.showError('Downloaded file not found.');
        }
      } else {
        CustomSnackBar.showError('Failed to download invoice');
      }
    } catch (e) {
      CustomSnackBar.showError('Error downloading invoice: $e');
    } finally {
      isDownloading[monthName] = false;
    }
  }
}
