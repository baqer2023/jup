import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/features/widgets/bottom_sheet_widget.dart';

class AppBottomSheet {
  static void bottomSheet({
    required VoidCallback onTapSave,
    required String title,
  }) {
    Get.bottomSheet(
      BottomSheetWidget(onTapSave: onTapSave, title: title),
      isDismissible: false,
    );
  }
}
