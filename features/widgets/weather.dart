import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:my_app32/app/models/weather_models.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:my_app32/app/core/app_utils_mixin.dart';

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
    final temp = AppUtilsMixin.toPersianNumber(
      (weather.main.temp - 273.15).round(),
    );

    final now = DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000);
    final jalali = Jalali.fromDateTime(now);
    final dayName = jalali.formatter.wN;

    final condition = _translateWeatherCondition(
      weather.weather.first.description,
    );
    final weatherIcon = _getWeatherIcon(weather.weather.first.description);

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
                '$dayName، تهران',
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
  }

  String _translateWeatherCondition(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) return 'آفتابی';
    if (desc.contains('cloud')) return 'ابری';
    if (desc.contains('rain')) return 'بارانی';
    if (desc.contains('snow')) return 'برفی';
    if (desc.contains('thunderstorm')) return 'طوفانی';
    return 'نامشخص';
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
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 6.4),
          const Text(
            'خطا در دریافت اطلاعات آب و هوا',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.8),
          ),
          const SizedBox(height: 3.2),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 11.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WeatherEmptyState extends StatelessWidget {
  const WeatherEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 32, color: Colors.grey),
          SizedBox(height: 6.4),
          Text(
            'داده‌ای برای نمایش وجود ندارد',
            style: TextStyle(fontSize: 11.2),
          ),
        ],
      ),
    );
  }
}
