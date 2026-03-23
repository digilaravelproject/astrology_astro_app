import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import 'package:get/get.dart' as getx;
import '../../../routes/route_helper.dart';
import '../../constants/app_constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/logger.dart';
import '../storage/shared_prefs.dart';
import 'response_model.dart';
import '../../widgets/error_screen.dart';

class ApiChecker {
  /// Centralized method to handle ResponseModel and show Snackbars
  static void handleResponse(ResponseModel response, {bool showSuccess = false, bool showError = true}) {
    if (response.isSuccess) {
      if (showSuccess) {
        CustomSnackBar.showSuccess(response.message);
      }
    } else {
      if (showError) {
        if (response.errors != null && response.errors!.isNotEmpty) {
          CustomSnackBar.showError(response.errors!.first.message ?? response.message);
        } else {
          CustomSnackBar.showError(response.message);
        }
      }
    }
  }

  static Response checkResponse(Response response, {bool showToaster = false}) {
    switch (response.statusCode) {
      case 200:
        final res = (response.data['res'] ?? response.data['status'])?.toString().toLowerCase();
        Logger.d('ApiChecker: checkResponse 200, res/status: $res');
        if (res == 'success') {
          return response;
        } else {
          Logger.d('ApiChecker: 200 case but not success, throwing exception');
          final errorMessage = response.data['msg'] ?? response.data['message'] ?? 'Something went wrong';
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: errorMessage,
          );
        }
      case 401:
        _logout();
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unauthorized',
        );
      case 403:
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Forbidden',
        );
      case 404:
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Not Found',
        );
      case 422:
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Validation Error',
        );
      case 500:
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Server Error',
        );
      default:
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Something went wrong',
        );
    }
  }
  static ResponseModel handleError(dynamic error, {bool showErrorScreen = false}) {
    final responseModel = _processError(error, showErrorScreen: showErrorScreen);
    if (!showErrorScreen) {
      handleResponse(responseModel, showSuccess: false, showError: true);
    }
    return responseModel;
  }

  static ResponseModel _processError(dynamic error, {bool showErrorScreen = false}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Connection Timeout',
              message: 'The connection has timed out. Please try again.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Connection timeout',
            statusCode: 408,
          );

        case DioExceptionType.sendTimeout:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Send Timeout',
              message: 'Request sending timed out. Please try again.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Send timeout',
            statusCode: 408,
          );

        case DioExceptionType.receiveTimeout:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Receive Timeout',
              message: 'Server response timed out. Please try again.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Receive timeout',
            statusCode: 408,
          );

        case DioExceptionType.badCertificate:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Security Error',
              message: 'There was a security certificate error. Please try again.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Bad certificate',
            statusCode: 495,
          );

        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            _logout();
            return const ResponseModel(
              isSuccess: false,
              message: 'Unauthorized',
              statusCode: 401,
            );
          }

          if (error.response?.data != null) {
            try {
              final responseModel = ResponseModel.fromJson(
                error.response!.data,
                statusCode: error.response!.statusCode,
              );

              if (showErrorScreen) {
                _showErrorScreen(
                  title: 'Error',
                  message: responseModel.errors != null && responseModel.errors!.isNotEmpty
                      ? responseModel.errors!.first.message ?? responseModel.message
                      : responseModel.message,
                );
              }

              return responseModel;
            } catch (e) {
              if (showErrorScreen) {
                _showErrorScreen(
                  title: 'Error',
                  message: 'Something went wrong. Please try again.',
                );
              }
              return ResponseModel(
                isSuccess: false,
                message: 'Something went wrong',
                statusCode: error.response?.statusCode,
              );
            }
          } else {
            if (showErrorScreen) {
              _showErrorScreen(
                title: 'Bad Response',
                message: 'Received an invalid response from server.',
              );
            }
            return ResponseModel(
              isSuccess: false,
              message: 'Bad response',
              statusCode: error.response?.statusCode,
            );
          }

        case DioExceptionType.cancel:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Request Cancelled',
              message: 'The request was cancelled.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Request cancelled',
            statusCode: 499,
          );

        case DioExceptionType.connectionError:
          return const ResponseModel(
            isSuccess: false,
            message: 'No internet connection',
          );

        case DioExceptionType.unknown:
          if (showErrorScreen) {
            _showErrorScreen(
              title: 'Unknown Error',
              message: 'An unexpected error occurred. Please try again.',
            );
          }
          return const ResponseModel(
            isSuccess: false,
            message: 'Something went wrong',
            statusCode: 500,
          );
      }
    } else {
      Logger.e('Error: $error');
      if (showErrorScreen) {
        _showErrorScreen(
          title: 'Error',
          message: 'Something went wrong. Please try again.',
        );
      }
    }

    return const ResponseModel(
      isSuccess: false,
      message: 'Something went wrong',
      statusCode: 500,
    );
  }

  static ResponseModel checkApi(Response response, {bool showToaster = false}) {
    final statusCode = response.statusCode ?? 500;

    if (statusCode == 401) {
      if (showToaster) {
        CustomSnackBar.showError('Session expired. Please login again.');
      }
      _logout();
      return const ResponseModel(
        isSuccess: false,
        message: 'Unauthorized',
        statusCode: 401,
      );
    }

    if (statusCode != 200) {
      if (response.data != null) {
        try {
          final responseModel = ResponseModel.fromJson(response.data, statusCode: statusCode);

          if (showToaster) {
            if (responseModel.errors != null && responseModel.errors!.isNotEmpty) {
              CustomSnackBar.showError(
                responseModel.errors!.first.message ?? 'Something went wrong',
              );
            } else {
              CustomSnackBar.showError(responseModel.message);
            }
          }

          return responseModel;
        } catch (e) {
          if (showToaster) {
            CustomSnackBar.showError('Something went wrong');
          }
          return ResponseModel(
            isSuccess: false,
            message: 'Something went wrong',
            statusCode: statusCode,
          );
        }
      } else {
        if (showToaster) {
          CustomSnackBar.showError('Something went wrong');
        }
        return ResponseModel(
          isSuccess: false,
          message: 'Something went wrong',
          statusCode: statusCode,
        );
      }
    }

    final result = response.data is Map && (response.data['res'] ?? response.data['status'])?.toString().toLowerCase() == 'success'
        ? ResponseModel.fromJson(response.data, statusCode: statusCode)
        : ResponseModel(
            isSuccess: false,
            message: response.data is Map
                ? (response.data['msg']?.toString() ?? response.data['message']?.toString() ?? 'Something went wrong')
                : 'Something went wrong',
            body: response.data is Map ? response.data['data'] : null,
            statusCode: statusCode,
          );

    if (showToaster) {
      handleResponse(result, showSuccess: true, showError: true);
    }

    return result;
  }

  static void _showErrorScreen({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    getx.Get.to(
          () => ErrorScreen(
        title: title,
        message: message,
        onRetry: onRetry ?? () => getx.Get.back(),
        showBackButton: true,
      ),
    );
  }

  static void _logout() {
    SharedPrefs.remove(AppConstants.userData);
    SharedPrefs.setBool(AppConstants.isLoggedIn, false);
    TokenManager.clearToken();
    getx.Get.offAllNamed(RouteHelper.getLoginRoute());
  }
}