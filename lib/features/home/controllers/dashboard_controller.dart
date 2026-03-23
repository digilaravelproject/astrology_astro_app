import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    debugPrint('DashboardController: changeIndex to $index');
    selectedIndex.value = index;
  }
}
