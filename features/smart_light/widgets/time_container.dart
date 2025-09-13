import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimeContainer extends StatelessWidget {
  final String time;
  final String meridiem;
  final bool active;

  const TimeContainer({
    Key? key,
    required this.time,
    required this.meridiem,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 115,
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? const Color(0xFF464646) : const Color(0xFFBDBDBD),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: Get.textTheme.titleSmall?.copyWith(
                color: active ? const Color(0xFF464646) : const Color(0xFFBDBDBD),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              meridiem,
              style: Get.textTheme.titleSmall?.copyWith(
                color: active ? const Color(0xFF464646) : const Color(0xFFBDBDBD),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 