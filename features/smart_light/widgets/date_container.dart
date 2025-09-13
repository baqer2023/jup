import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateContainer extends StatelessWidget {
  final String date;
  final String day;
  final bool active;

  const DateContainer({
    Key? key,
    required this.date,
    required this.day,
    required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 70,
        width: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: active ? const Color(0xFF464646) : Colors.white,
          border: Border.all(
            color: active ? const Color(0xFF464646) : const Color(0xFFBDBDBD),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              ' $date\n$day',
              style: Get.textTheme.displayMedium?.copyWith(
                color: active ? Colors.white : const Color(0xFFBDBDBD),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 