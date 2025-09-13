import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'dart:ui';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temp = AppUtilsMixin.toPersianNumber('22');
    final condition = 'نیمه ابری';
    final city = 'تهران';
    final now = DateTime.now();
    final jalali = Jalali.fromDateTime(now);
    final dayName = jalali.formatter.wN; // Day name in Persian

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$temp°',
            style: TextStyle(
              fontFamily: 'IranYekan',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                condition,
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$dayName، $city',
                style: TextStyle(
                  fontFamily: 'IranYekan',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          SvgPicture.asset(
            'assets/weather/partly_cloudy.svg',
            width: 48,
            height: 48,
          ),
        ],
      ),
    );
  }
}
