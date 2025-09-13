import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/smart_light_controller.dart';
import 'date_container.dart';
import 'time_container.dart';
import 'advance_settings.dart';
import 'reusable_button.dart';

class ExpandableBottomSheet extends StatelessWidget {
  final SmartLightController controller;

  const ExpandableBottomSheet({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 35,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF464646),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: Get.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Set schedule room light',
                      style: Get.textTheme.headlineSmall,
                    )
                  ],
                ),
                Switch.adaptive(
                  inactiveThumbColor: const Color(0xFFE4E4E4),
                  inactiveTrackColor: Colors.white,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF464646),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(thickness: 2),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'January 2022',
                      style: Get.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Select the desired date',
                      style: Get.textTheme.headlineSmall,
                    )
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.arrow_back_ios_outlined),
                    SizedBox(width: 20),
                    Icon(Icons.arrow_forward_ios_outlined),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  DateContainer(date: '01', day: 'Sat', active: true),
                  DateContainer(date: '02', day: 'Sun', active: false),
                  DateContainer(date: '03', day: 'Mon', active: false),
                  DateContainer(date: '04', day: 'Tue', active: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select the desired time',
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On Time',
                      style: Get.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const TimeContainer(
                      time: '10:27',
                      meridiem: 'PM',
                      active: true,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Off Time',
                      style: Get.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    const TimeContainer(
                      time: '7:30',
                      meridiem: 'AM',
                      active: false,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Advance setting',
              style: Get.textTheme.displayMedium,
            ),
            const SizedBox(height: 20),
            const AdvanceSettings(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ReusableButton(
                      active: false,
                      buttonText: 'Clear all',
                      onPress: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ReusableButton(
                      active: true,
                      buttonText: 'Schedule',
                      onPress: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 