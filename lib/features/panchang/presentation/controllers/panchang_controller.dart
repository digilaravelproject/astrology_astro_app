import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astro_astrologer/features/panchang/data/models/panchang_model.dart';
import 'package:astro_astrologer/features/panchang/domain/usecases/get_panchang_usecase.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class PanchangController extends GetxController {
  final GetPanchangUseCase getPanchangUseCase;

  PanchangController({required this.getPanchangUseCase});

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<PanchangModel?> panchangData = Rx<PanchangModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool showFullCalendar = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxDouble timezone = 5.5.obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchPanchangData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchPanchangData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      print(
        '[PCB_APP] [DEBUG] Fetching panchang for date: $dateString with lat: ${latitude.value}, lon: ${longitude.value}, tz: ${timezone.value}',
      );

      final result = await getPanchangUseCase.call(
        dateString,
        latitude: latitude.value,
        longitude: longitude.value,
        timezone: timezone.value,
      );

      print('[PCB_APP] [DEBUG] Panchang data received: ${result.success}');
      print('[PCB_APP] [DEBUG] Panchang location: ${result.data.location}');
      print('[PCB_APP] [DEBUG] Panchang tithi: ${result.data.tithi.name}');

      panchangData.value = result;

      print(
        '[PCB_APP] [DEBUG] Panchang data set in controller: ${panchangData.value != null}',
      );
    } catch (e) {
      print('[PCB_APP] [ERROR] Failed to load panchang: $e');
      errorMessage.value = 'Failed to load panchang data: $e';
      CustomSnackBar.disabledSnackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    showFullCalendar.value = false;
    fetchPanchangData();
  }

  void toggleCalendar() {
    showFullCalendar.value = !showFullCalendar.value;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B4FA0),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1A47),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectDate(picked);
    }
  }

  String formatTime(String time) {
    if (time.isEmpty) return '';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String formatTimeRange(String start, String end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }
}
