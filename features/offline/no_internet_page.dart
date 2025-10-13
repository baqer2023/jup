import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/no internet.svg', // مسیر SVG خودت
                width: 150,
                height: 300,
              ),
              const SizedBox(height: 30),

              // متن اول - بزرگ و پررنگ
              const Text(
                'متأسفیم...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // متن دوم - کمی کوچکتر و خاکستری متوسط
              const Text(
                'مشکلی در دسترسی به اینترنت وجود دارد!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),

              // متن سوم - کوچکترین و خاکستری روشن
              const Text(
                'به نظر می‌رسد که اتصال اینترنت شما قطع شده‌است. لطفا وضعیت شبکه خود را بررسی و دوباره تلاش کنید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
