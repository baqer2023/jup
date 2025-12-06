import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_app32/app/models/weather_models.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';
import 'package:my_app32/core/lang/lang.dart';

class WeatherDisplay extends StatelessWidget {
  final Future<WeatherData> weatherFuture;

  const WeatherDisplay({super.key, required this.weatherFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WeatherLoadingShimmer();
        } else if (snapshot.hasError) {
          return WeatherErrorWidget(error: snapshot.error.toString());
        } else if (snapshot.hasData) {
          return WeatherCard(weather: snapshot.data!);
        } else {
          return const WeatherEmptyState();
        }
      },
    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFa = Lang.current.value == 'fa';
      
      final temp = AppUtilsMixin.toPersianNumber(
        (weather.main.temp - 273.15).round(),
      );

      final now = DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
      
      String dayName;
      if (isFa) {
        final jalali = Jalali.fromDateTime(now);
        dayName = jalali.formatter.wN;
      } else {
        const weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        dayName = weekDays[now.weekday - 1];
      }

      final condition = _translateWeatherCondition(
        weather.weather.first.description,
        isFa,
      );
      final weatherIcon = _getWeatherIcon(weather.weather.first.description);
      
      final cityName = isFa ? 'تهران' : 'Tehran';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// ✅ بخش متن راست‌چین
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$condition - $temp°',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFa ? '$dayName، $cityName' : '$dayName, $cityName',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            /// ✅ فاصله بسیار کم بین متن و آیکون
            const SizedBox(width: 10),

            /// ✅ آیکون
            SizedBox(
              width: 28,
              height: 28,
              child: weatherIcon,
            ),
          ],
        ),
      );
    });
  }

  String _translateWeatherCondition(String description, bool isFa) {
    final desc = description.toLowerCase();
    if (isFa) {
      if (desc.contains('clear')) return 'آفتابی';
      if (desc.contains('cloud')) return 'ابری';
      if (desc.contains('rain')) return 'بارانی';
      if (desc.contains('snow')) return 'برفی';
      if (desc.contains('thunderstorm')) return 'طوفانی';
      return 'نامشخص';
    } else {
      if (desc.contains('clear')) return 'Clear';
      if (desc.contains('cloud')) return 'Cloudy';
      if (desc.contains('rain')) return 'Rainy';
      if (desc.contains('snow')) return 'Snowy';
      if (desc.contains('thunderstorm')) return 'Storm';
      return 'Unknown';
    }
  }

  Widget _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    String asset = '';
    if (desc.contains('clear')) asset = 'assets/svg/sunny.svg';
    else if (desc.contains('cloud')) asset = 'assets/svg/partly_cloudy.svg';
    else if (desc.contains('rain')) asset = 'assets/svg/rainy.svg';
    else if (desc.contains('snow')) asset = 'assets/svg/snowy.svg';
    else if (desc.contains('thunderstorm')) asset = 'assets/svg/thunderstorm.svg';
    else return const Icon(Icons.help_outline, size: 20, color: Colors.grey);

    return SvgPicture.asset(asset, width: 28, height: 28);
  }
}

class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
    );
  }
}

class WeatherErrorWidget extends StatelessWidget {
  final String error;

  const WeatherErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFa = Lang.current.value == 'fa';
      return Container(
        padding: const EdgeInsets.all(12.8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(height: 2.4),
            Text(
              isFa ? 'خطا در دریافت اطلاعات آب و هوا' : 'Weather data error',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ],
        ),
      );
    });
  }
}

class WeatherEmptyState extends StatelessWidget {
  const WeatherEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFa = Lang.current.value == 'fa';
      return Container(
        padding: const EdgeInsets.all(12.8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 32, color: Colors.grey),
            const SizedBox(height: 6.4),
            Text(
              isFa ? 'داده‌ای برای نمایش وجود ندارد' : 'No data available',
              style: const TextStyle(fontSize: 11.2),
            ),
          ],
        ),
      );
    });
  }
}