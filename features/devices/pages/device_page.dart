import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/core/base/base_view.dart';
import 'package:my_app32/app/services/realable_controller.dart';
import 'package:my_app32/core/lang/lang.dart';
import 'package:my_app32/features/config/device_config_page.dart';
import 'package:my_app32/features/devices/pages/edit_device_page.dart';
import 'package:my_app32/features/main/models/home/device_item_model.dart';
import 'package:my_app32/features/main/pages/home/Add_device_page.dart';
import 'package:my_app32/features/main/pages/home/home_controller.dart';
import 'package:my_app32/features/main/repository/home_repository.dart';
import 'package:my_app32/features/widgets/custom_appbar.dart';
import 'package:my_app32/features/widgets/sidebar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class DevicesPage extends BaseView<HomeController> {
  DevicesPage({super.key}) {
    // ✅ کنترلر را مستقیم داخل صفحه بساز
    Get.put<HomeController>(
      HomeController(Get.find<HomeRepository>()),
      permanent: true,
    );
  }

  @override
  Widget body() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // فقط برای بار اول داده‌ها از صفر لود می‌شوند
      if (controller.isFirstLoad.value) {
        controller.selectedLocationId.value = '';
        controller.deviceList.clear();
        controller.initController();
        controller.isFirstLoad.value = false;
      } else {
        // اگر کاربر از صفحه‌ی دیگر برگشت
        if (controller.selectedLocationId.value.isNotEmpty) {
          final lastLocationId = controller.selectedLocationId.value;
          controller.selectedLocationId
              .refresh(); // 🔹 باعث به‌روزرسانی ظاهر دکمه می‌شود
          controller.fetchDevicesByLocation(lastLocationId);
        }
      }
    });

    return Scaffold(
      endDrawer: const Sidebar(),
      appBar: CustomAppBar(isRefreshing: controller.isRefreshing),
      body: Builder(builder: (context) => _buildDevicesContent(context)),
    );
  }

  Widget _buildDevicesContent(BuildContext context) {
    return Obx(() {
      final locations = controller.userLocations;
      final visibleLocations = locations
          .where((loc) => loc.title != "میانبر")
          .toList();
      final devices = controller.deviceList;

      return RefreshIndicator(
        onRefresh: controller.refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // دکمه‌ها و عنوان بالا
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return ElevatedButton(
                            onPressed: () {
                              Get.to(() => const AddDevicePage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(Lang.t("register_device")),
                          );
                        }),

                        const SizedBox(width: 12),
                        Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return ElevatedButton(
                            onPressed: _showAddLocationDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.yellow.shade700,
                              side: BorderSide(
                                color: Colors.yellow.shade700,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(Lang.t("add_location")),
                          );
                        }),
                      ],
                    ),
                    Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Text(
                        Lang.t("devices"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              // لیست مکان‌ها + دکمه ویرایش
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 45,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // دکمه ویرایش
                        // دکمه ویرایش
                        // دکمه ویرایش
                        GestureDetector(
                          onTap: () {
                            _showEditLocationsModal(
                              context,
                              controller.userLocations,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // کامل دایره
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/pencil-solid.svg',
                                  width: 18,
                                  height: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Obx(() {
                                  final _ =
                                      Lang.current.value; // ⚡ reactive trigger
                                  return Text(
                                    Lang.t("edit"),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        // لیست مکان‌ها
                        ...locations.where((loc) => loc.title != "میانبر").map((
                          loc,
                        ) {
                          return Obx(() {
                            final isSelected =
                                controller
                                    .selectedLocationId
                                    .value
                                    .isNotEmpty &&
                                controller.selectedLocationId.value == loc.id;

                            return GestureDetector(
                              onTap: () async {
                                controller.selectedLocationId.value = '';
                                await Future.delayed(
                                  Duration(milliseconds: 10),
                                );
                                controller.selectedLocationId.value = loc.id;
                                controller.fetchDevicesByLocation(loc.id);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.yellow
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ), // کامل دایره
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      loc.title,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.yellow.shade700
                                            : Colors.grey,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (loc.iconIndex != null) ...[
                                      const SizedBox(
                                        width: 4,
                                      ), // فاصله خیلی کم بین متن و آیکن
                                      SvgPicture.asset(
                                        'assets/svg/${loc.iconIndex}.svg', // مسیر درست
                                        width: 28, // اندازه مناسب
                                        height: 28,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ],
                                ),

                                // child: Center(
                                //   child: Text(
                                //     loc.title,
                                //     style: TextStyle(
                                //       color: isSelected ? Colors.yellow.shade700 : Colors.grey,
                                //       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                //       fontSize: 14,
                                //     ),
                                //   ),
                                // ),
                              ),
                            );
                          });
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // لیست دستگاه‌ها
              if (devices.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 180,
                          child: SvgPicture.asset(
                            'assets/svg/NDeviceF.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t("no_device_message"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              else
                _buildSmartDevicesGrid(),
            ],
          ),
        ),
      );
    });
  }

  int? selectedIconIndex; // متغیر انتخاب آیکن
  Widget _buildIconSelector(
    void Function(void Function()) setState,
    int? selectedIndex,
  ) {
    return SizedBox(
      height: 70, // ارتفاع کانتینر آیکن‌ها
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(18, (index) {
            final iconNumber = index + 1;
            final isSelected = selectedIndex == iconNumber;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIconIndex = iconNumber;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle, // دایره کامل
                  border: Border.all(
                    color: isSelected
                        ? Colors.yellow.shade700
                        : Colors.grey.shade300,
                    width: isSelected ? 2.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/svg/$iconNumber.svg',
                  fit: BoxFit.contain,
                  // رنگ خود آیکن تغییر نکند، فقط دورش بردر زرد شود
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// مدال ویرایش مکان‌ها
  /// مدال ویرایش مکان‌ها با دکمه‌های ثبت و انصراف و استایل جدید
  void _showEditLocationsModal(BuildContext context, List locations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Colors.white, // پس‌زمینه کل مدال
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // هدر آبی با متن سفید
                Obx(() {
                  final _ = Lang.current.value; // ⚡ reactive trigger
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Lang.t('edit_locations'), // کلید ترجمه
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // لیست مکان‌ها
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locations
                        .where((loc) => loc.title != "میانبر")
                        .length,
                    itemBuilder: (context, index) {
                      // فقط مکان‌هایی که title != "میانبر" رو انتخاب می‌کنیم
                      final filteredLocations = locations
                          .where((loc) => loc.title != "میانبر")
                          .toList();
                      final loc = filteredLocations[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              loc.title,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          leading: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black87,
                            ),
                            onSelected: (value) async {
                              // 👈 اینجا async اضافه کن
                              if (value == 'edit') {
                                Navigator.pop(context);
                                _showSingleLocationEditDialog(context, loc);
                              } else if (value == 'up') {
                                Navigator.pop(context);
                              } else if (value == 'down') {
                                Navigator.pop(context);
                              } else if (value == 'delete') {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 8,
                                      titlePadding: EdgeInsets.zero,
                                      title: Obx(() {
                                        final _ = Lang
                                            .current
                                            .value; // ⚡ reactive trigger
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors
                                                .blue, // رنگ هشدار یا رنگ دلخواه
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            Lang.t(
                                              'delete_location',
                                            ), // کلید ترجمه
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }),

                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 8),
                                            Obx(() {
                                              final _ = Lang
                                                  .current
                                                  .value; // ⚡ reactive trigger
                                              return Text(
                                                Lang.t(
                                                  'confirm_delete_location',
                                                  params: {'title': loc.title},
                                                ),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade800,
                                                ),
                                              );
                                            }),

                                            const SizedBox(height: 20),
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.blue,
                                              size: 50,
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                      actionsPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      actions: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 🔸 دکمه انصراف
                                            SizedBox(
                                              width: 100,
                                              child: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // ⚡ reactive trigger
                                                return ElevatedButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        const Color(0xFFF39530),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xFFF39530,
                                                        ),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    Lang.t(
                                                      'cancel',
                                                    ), // ⚡ متن از فایل زبان گرفته می‌شود
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 4),

                                            // 🔹 دکمه حذف
                                            SizedBox(
                                              width: 100,
                                              child: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // ⚡ reactive trigger
                                                return ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // بستن دیالوگ
                                                    String?
                                                    error = await controller
                                                        .deleteDashboardItem(
                                                          id: loc.id,
                                                          title: loc.title,
                                                          displayOrder: 1,
                                                          iconIndex:
                                                              loc.iconIndex,
                                                        );

                                                    if (error == null) {
                                                      await controller
                                                          .refreshAllData();
                                                      controller
                                                              .selectedLocationId
                                                              .value =
                                                          '';

                                                      Get.snackbar(
                                                        Lang.t(
                                                          'delete_success_title',
                                                        ),
                                                        Lang.t(
                                                          'delete_success_message',
                                                          params: {
                                                            'location':
                                                                loc.title,
                                                          },
                                                        ),
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor: Colors
                                                            .green
                                                            .shade600,
                                                        colorText: Colors.white,
                                                        duration:
                                                            const Duration(
                                                              seconds: 2,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        borderRadius: 10,
                                                      );

                                                      Get.offAll(
                                                        () => DevicesPage(),
                                                      );
                                                    } else {
                                                      String errorMessage =
                                                          error;
                                                      if (error.contains(
                                                        'Cannot delete dashboard: contains device configuration.',
                                                      )) {
                                                        errorMessage = Lang.t(
                                                          'delete_error_devices_attached',
                                                        );
                                                      }

                                                      Get.snackbar(
                                                        Lang.t('error'),
                                                        errorMessage,
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor:
                                                            Colors.red.shade600,
                                                        colorText: Colors.white,
                                                        duration:
                                                            const Duration(
                                                              seconds: 4,
                                                            ),
                                                        margin:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        borderRadius: 10,
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    Lang.t('delete'),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },

                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/edit.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    Obx(() {
                                      final _ = Lang
                                          .current
                                          .value; // ⚡ reactive trigger
                                      return Text(
                                        Lang.t('edit_locations'),
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              // PopupMenuItem(
                              //   value: 'up',
                              //   child: Row(
                              //     textDirection: TextDirection.rtl,
                              //     children: [
                              //       SvgPicture.asset('assets/svg/arrow_up.svg', width: 20, height: 20, color: Colors.black87),
                              //       const SizedBox(width: 8),
                              //       const Text('بالا بردن', style: TextStyle(color: Colors.black)),
                              //     ],
                              //   ),
                              // ),
                              // PopupMenuItem(
                              //   value: 'down',
                              //   child: Row(
                              //     textDirection: TextDirection.rtl,
                              //     children: [
                              //       SvgPicture.asset('assets/svg/arrow_down.svg', width: 20, height: 20, color: Colors.black87),
                              //       const SizedBox(width: 8),
                              //       const Text('پایین آوردن', style: TextStyle(color: Colors.black)),
                              //     ],
                              //   ),
                              // ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/deleting.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Obx(() {
                                      final _ = Lang
                                          .current
                                          .value; // ⚡ reactive trigger
                                      return Text(
                                        Lang.t('delete_location'),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // دکمه‌های ثبت و انصراف
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // دکمه انصراف
                    SizedBox(
                      width: 80, // عرض ثابت
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFFF39530),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFF39530),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t('cancel'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // دکمه ثبت
                    SizedBox(
                      width: 80, // عرض ثابت همانند دکمه انصراف
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t('submit'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSingleLocationEditDialog(BuildContext context, dynamic loc) {
    final TextEditingController nameController = TextEditingController(
      text: loc.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          title: Obx(() {
            final _ = Lang.current.value; // ⚡ reactive trigger
            return Text(
              Lang.t('edit_location'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            );
          }),

          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: Align(
                          alignment: Alignment.centerRight,
                          child: Obx(() {
                            final _ = Lang.current.value; // ⚡ reactive trigger
                            return Text(
                              Lang.t('location_name'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }),
                        ),
                        hintText:
                            null, // hintText مستقیم نمی‌ذاریم، از suffix استفاده می‌کنیم
                        // استفاده از Obx برای hintText
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        hintTextDirection: TextDirection.rtl,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                      buildCounter:
                          (
                            BuildContext context, {
                            int? currentLength,
                            int? maxLength,
                            bool? isFocused,
                          }) {
                            // برای hintText داینامیک داخل Obx
                            return Obx(() {
                              final _ = Lang.current.value;
                              return Text(
                                Lang.t('enter_location_name'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              );
                            });
                          },
                    ),

                    const SizedBox(height: 16),
                    Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Lang.t('select_location_icon'), // کلید ترجمه
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    _buildIconSelector(setState, selectedIconIndex),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),

          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min, // فقط به اندازه محتوا جا می‌گیرد
              children: [
                SizedBox(
                  width: 100, // عرض ثابت دکمه انصراف
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFF39530),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFF39530),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Text(
                        Lang.t('cancel'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 4), // فاصله خیلی کم بین دکمه‌ها

                SizedBox(
                  width: 100, // عرض ثابت دکمه ذخیره
                  child: ElevatedButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) {
                        Get.snackbar(
                          'خطا',
                          'لطفاً نام مکان را وارد کنید',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      await controller.updateLocation(
                        title: newName,
                        dashboardId: loc.id,
                        iconIndex: selectedIconIndex,
                      );

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Text(
                        Lang.t('save'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ------------------- Smart Devices Grid (بهینه) -------------------
  Widget _buildSmartDevicesGrid() {
    return Obx(() {
      final devices = controller.deviceList;

      if (devices.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Obx(() {
              final _ = Lang.current.value; // ⚡ reactive trigger
              return Text(
                Lang.t('select_location_to_view_devices'),
                style: TextStyle(color: Colors.grey),
              );
            }),
          ),
        );
      }

      final reliableController =
          Get.isRegistered<ReliableSocketController>(
            tag: 'smartDevicesController',
          )
          ? Get.find<ReliableSocketController>(tag: 'smartDevicesController')
          : Get.put(
              ReliableSocketController(
                controller.token,
                devices.map((d) => d.deviceId).toList(),
              ),
              tag: 'smartDevicesController',
              permanent: true,
            );

      reliableController.updateDeviceList(
        devices.map((d) => d.deviceId).toList(),
      );

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // فاصله از لبه
          child: Column(
            children: devices.map((device) {
              print(device.deviceId);
              print("device.deviceId");
              final deviceData2 =
                  reliableController.latestDeviceDataById[device.deviceId];
              print(deviceData2);
              return Obx(() {
                final deviceData =
                    reliableController.latestDeviceDataById[device.deviceId];

                // 🔴 اگر دیتایی نبود همان UI قبلی ساخته شود
                if (deviceData == null) {
                  // return _buildNormalDeviceCard(device, reliableController);
                }

                // ✅ چک وجود TDDeviceS یا TWDeviceS
                final hasDeviceS =
                    deviceData!.containsKey('TDDeviceS') ||
                    deviceData!.containsKey('TWDeviceS');

                if (hasDeviceS) {
                  // bool switch1On22 = deviceData["TDPower"][0][1]["c"] == "1";
                  // Map<String, dynamic> data =
                  //     Map<String, dynamic>.from(deviceData is List ? deviceData[0] : deviceData);

                  // bool switch1On22 =
                  //     (deviceData["TDPower"]);

                  // print(switch1On22);
                  // print("device.deviceId");
                  // print("device.deviceId");
                  // print("device.deviceId");
                  // print(deviceData["TDPower"][0][1]);
                  bool switch1On22 = false;
bool readLatestPowerSwitchbool(Map deviceData, bool previousValue) {
  final List<List<dynamic>> powerKeys = [];

  try {
    if (deviceData["TDPower"] is List) {
      powerKeys.addAll(List.from(deviceData["TDPower"]));
    }
    if (deviceData["TWPower"] is List) {
      powerKeys.addAll(List.from(deviceData["TWPower"]));
    }

    if (powerKeys.isEmpty) return previousValue;

    int getTimestamp(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    powerKeys.sort(
      (a, b) => getTimestamp(b[0]).compareTo(getTimestamp(a[0])),
    );

    final latestItem = powerKeys.first;

    if (latestItem.length < 2) return previousValue;

    var value = latestItem[1];

    if (value is String) {
      value = jsonDecode(value);
    }

    if (value is! Map) {
      print(value);
      return previousValue;
    }

    final cVal = value["c"];
    if (cVal == null) return previousValue; // اگر کلید "c" نبود، از مقدار قبلی استفاده کن

    final cStr = cVal.toString().trim().toLowerCase();
    return cStr == "1" || cStr.contains("on");
  } catch (e, stackTrace) {
    print("Error parsing power switch data: $e\n$stackTrace");
    return previousValue; // در صورت هر خطا، مقدار قبلی برگردانده می‌شود
  }
}


switch1On22 = readLatestPowerSwitchbool(
  deviceData as Map,
  switch1On22,  // اینجا مقدار قبلی رو میدیم
);
                  print("device.deviceId");
                  print(switch1On22); // false

                 Map<String, dynamic> readLatestDeviceValues(Map deviceData) {
  final Map<String, dynamic> result = {};

  // نگه داشتن جدیدترین کلیدهای TD/TW برای هر نوع
  final Map<String, Map<String, dynamic>> latestPairs = {};

  for (var key in deviceData.keys) {
    final dataList = deviceData[key];

    if (dataList is! List || dataList.isEmpty) continue;

    // پیدا کردن آخرین item بر اساس timestamp
    dataList.sort((a, b) {
      int tsA = (a is List && a.isNotEmpty) ? int.tryParse(a[0].toString()) ?? 0 : 0;
      int tsB = (b is List && b.isNotEmpty) ? int.tryParse(b[0].toString()) ?? 0 : 0;
      return tsB.compareTo(tsA);
    });

    final latestItem = dataList.first;
    if (latestItem is! List || latestItem.length < 2) continue;

    int ts = int.tryParse(latestItem[0].toString()) ?? 0;
    var value = latestItem[1];

    // اگر JSON رشته‌ای است، تبدیل به Map کنیم
    if (value is String) {
      try {
        value = jsonDecode(value);
      } catch (_) {}
    }

    if (value is Map && value.containsKey('c')) {
      value = value['c'];
    }

    // اگر کلید با TD یا TW شروع شد
    if (key.startsWith('TD') || key.startsWith('TW')) {
      // نوع عملکرد را بدون TD/TW استخراج می‌کنیم
      final typeKey = key.substring(2); // مثال: TDPower -> Power, TWPower -> Power

      // بررسی جدیدترین بین TD و TW
      if (!latestPairs.containsKey(typeKey) || ts > latestPairs[typeKey]!['ts']) {
        latestPairs[typeKey] = {'key': key, 'value': value, 'ts': ts};
      }
    } else {
      // کلیدهای دیگر مستقیماً اضافه می‌شوند
      result[key] = value;
    }
  }

  // اضافه کردن جدیدترین کلیدهای TD/TW به نتیجه
  for (var pair in latestPairs.values) {
    result[pair['key']] = pair['value'];
  }

  return result;
}

                  Map<String, dynamic> switch1On222 = readLatestDeviceValues(
                    deviceData as Map,
                  );


  String powerKey = switch1On222.containsKey('TWPower') ? 'TWPower' : 'TDPower';

  // 2️⃣ مقدار کلید
  dynamic powerValue = switch1On222[powerKey];

  // 3️⃣ تبدیل مقدار به true/false
  bool powerState = false;

  if (powerValue is int) {
    powerState = powerValue != 0;
  } else if (powerValue is String) {
    powerState = powerValue.toLowerCase() != 'off';
  } else if (powerValue is bool) {
    powerState = powerValue;
  }

  // نتیجه
  print('کلید موجود: $powerKey');
  print('حالت روشن/خاموش (true/false): $powerState');
                  


                  
                  print("device.deviceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaId");
                  print(switch1On222);


                  

                  // ✅ دیتای فیک ولی منطقی برای S-Device
                  // final bool fakeSwitch1On = false;
                  // final bool? fakeSwitch2On =
                  //     device.deviceTypeName == 'key-1' ? null : false;

                  // final Color fakeIconColor1 =
                  //     fakeSwitch1On ? Colors.blue : Colors.grey;

                  // final Color? fakeIconColor2 =
                  //     fakeSwitch2On == null
                  //         ? null
                  //         : (fakeSwitch2On ? Colors.blue : Colors.grey);

                  // final bool fakeIsSingleKey =
                  //     device.deviceTypeName == 'key-1';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildSmartDeviceSCard(
                          title: device.title ?? "بدون عنوان",
                          deviceId: device.deviceId,
                          // deviceSData: deviceData,
                          device: device,

                          // 👇 دیتای فیک جایگزین
                          switch1On: powerState,

                          // switch2On: fakeSwitch2On,
                          // iconColor1: fakeIconColor1,
                          // iconColor2: fakeIconColor2,
                          // isSingleKey: fakeIsSingleKey,
                          onToggle: (value) async {
                            await reliableController.toggleSwitchS(
                              value,
                              // switchNumber,
                              device.deviceId,
                            );
                          },
                          data_T: {switch1On222},
                        ),
                      ),
                    ),
                  );
                } else {
                  //---------------------------------------------------
                  // ⬇️ اگر TDDeviceS یا TWDeviceS نبود
                  // 👇 منطق قبلی خودت بدون تغییر
                  bool switch1On = false;
                  bool switch2On = false;
                  Color iconColor1 = Colors.grey;
                  Color iconColor2 = Colors.grey;

                  final key1Entries = [
                    if (deviceData['TW1'] is List) ...deviceData['TW1'],
                    if (deviceData['TD1'] is List) ...deviceData['TD1'],
                  ];
                  if (key1Entries.isNotEmpty) {
                    key1Entries.sort(
                      (a, b) => (b[0] as int).compareTo(a[0] as int),
                    );
                    switch1On = key1Entries.first[1].toString().contains('On');
                  }

                  final key2Entries = [
                    if (deviceData['TW2'] is List) ...deviceData['TW2'],
                    if (deviceData['TD2'] is List) ...deviceData['TD2'],
                  ];
                  if (key2Entries.isNotEmpty) {
                    key2Entries.sort(
                      (a, b) => (b[0] as int).compareTo(a[0] as int),
                    );
                    switch2On = key2Entries.first[1].toString().contains('On');
                  }

                  if (deviceData['ledColor'] is List &&
                      deviceData['ledColor'].isNotEmpty) {
                    final ledEntry = deviceData['ledColor'][0][1];
                    Map<String, dynamic> ledMap;

                    if (ledEntry is String) {
                      ledMap = jsonDecode(ledEntry);
                    } else if (ledEntry is Map<String, dynamic>) {
                      ledMap = ledEntry;
                    } else {
                      ledMap = {};
                    }

                    iconColor1 = switch1On
                        ? Color.fromARGB(
                            255,
                            ledMap['c']['t1']['on']['r'],
                            ledMap['c']['t1']['on']['g'],
                            ledMap['c']['t1']['on']['b'],
                          )
                        : Color.fromARGB(
                            255,
                            ledMap['c']['t1']['off']['r'],
                            ledMap['c']['t1']['off']['g'],
                            ledMap['c']['t1']['off']['b'],
                          );

                    iconColor2 = switch2On
                        ? Color.fromARGB(
                            255,
                            ledMap['c']['t2']['on']['r'],
                            ledMap['c']['t2']['on']['g'],
                            ledMap['c']['t2']['on']['b'],
                          )
                        : Color.fromARGB(
                            255,
                            ledMap['c']['t2']['off']['r'],
                            ledMap['c']['t2']['off']['g'],
                            ledMap['c']['t2']['off']['b'],
                          );
                  }

                  final isSingleKey = device.deviceTypeName == 'key-1';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildSmartDeviceCard(
                          title: device.title,
                          deviceId: device.deviceId,
                          switch1On: switch1On,
                          switch2On: switch2On,
                          iconColor1: iconColor1,
                          iconColor2: iconColor2,
                          onToggle: (switchNumber, value) async {
                            await reliableController.toggleSwitch(
                              value,
                              switchNumber,
                              device.deviceId,
                            );
                          },
                          isSingleKey: isSingleKey,
                          device: device,
                        ),
                      ),
                    ),
                  );
                }
              });
            }).toList(),
          ),
        ),
      );
    });
  }

  // ------------------- Smart Device Card -------------------
  Widget _buildSmartDeviceCard({
    required String title,
    required String deviceId,
    required bool switch1On,
    bool? switch2On,
    required Color iconColor1,
    Color? iconColor2,
    required Function(int switchNumber, bool value) onToggle,
    required bool isSingleKey,
    required DeviceItem device,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    bool anySwitchOn = switch1On || (!isSingleKey && (switch2On ?? false));
    Color borderColor = anySwitchOn
        ? Colors.blue.shade400
        : Colors.grey.shade400;

    final homeController = Get.find<HomeController>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 250),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 2),
            ),
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ردیف بالای کارت: کلیدها و اطلاعات دستگاه
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // کلیدها سمت چپ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSwitchRow(
                              deviceId: deviceId,
                              switchNumber: 1,
                              color: iconColor1,
                              onToggle: onToggle,
                            ),
                            if (!isSingleKey)
                              _buildSwitchRow(
                                deviceId: deviceId,
                                switchNumber: 2,
                                color: iconColor2 ?? Colors.grey,
                                onToggle: onToggle,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // اطلاعات دستگاه سمت راست
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // وضعیت آنلاین و نوع کلید
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() {
                                final lastSeen = reliableController
                                    .lastDeviceActivity[deviceId];
                                final isOnline =
                                    lastSeen != null &&
                                    DateTime.now().difference(lastSeen) <
                                        const Duration(seconds: 30);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.blue : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Obx(() {
                                    final _ = Lang
                                        .current
                                        .value; // ⚡ reactive trigger
                                    return Text(
                                      isOnline
                                          ? Lang.t("online")
                                          : Lang.t("offline"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),
                                );
                              }),
                              const SizedBox(width: 6),
                              Obx(() {
                                final _ =
                                    Lang.current.value; // ⚡ reactive trigger
                                return Text(
                                  isSingleKey
                                      ? Lang.t("single_key")
                                      : Lang.t("double_key"),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // عنوان دستگاه
                          Text(
                            title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // مکان دستگاه با آیکن
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  device.dashboardTitle ?? "بدون مکان",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/svg/location.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // ردیف پایین کارت: سه نقطه، SVG تنظیمات و آخرین همگام‌سازی
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PopupMenuButton (سه نقطه)
                      Builder(
                        builder: (context) => PopupMenuButton<int>(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onSelected: (value) async {
                            if (value == 1) {
                              Get.to(
                                () => EditDevicePage(
                                  deviceId: device.deviceId,
                                  serialNumber: device.sn,
                                  initialName: device.title ?? '',
                                  initialDashboardId: device.dashboardId ?? '',
                                ),
                              );
                            } else if (value == 0) {
                              // showLedColorDialog(device);
                            } else if (value == 2) {
                              // افزودن به داشبورد
                              if (!homeController.dashboardDevices.any(
                                (d) => d.deviceId == device.deviceId,
                              )) {
                                final token = homeController.token;
                                if (token == null) {
                                  Get.snackbar(
                                    "خطا",
                                    "توکن معتبر پیدا نشد",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                final headers = {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                };
                                final data = {"deviceId": device.deviceId};
                                try {
                                  final dio = Dio();
                                  final response = await dio.post(
                                    'http://45.149.76.245:8080/api/shortcut/addDevice',
                                    data: data,
                                    options: Options(headers: headers),
                                  );
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    Get.snackbar(
                                      'موفقیت',
                                      'دستگاه به داشبورد اضافه شد',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                    homeController.dashboardDevices.add(device);
                                  } else {
                                    Get.snackbar(
                                      'خطا',
                                      'افزودن دستگاه موفق نبود: ${response.statusCode}',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'خطا',
                                    'مشکل در ارتباط با سرور: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  'توجه',
                                  'این دستگاه قبلاً به داشبورد اضافه شده است',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            } else if (value == 3 || value == 4) {
                              final isPermanent = value == 4;

                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  titlePadding: EdgeInsets.zero,
                                  title: Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    final actionText = isPermanent
                                        ? Lang.t("complete_delete")
                                        : Lang.t("temporary_delete");
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        actionText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }),
                                  content: Obx(() {
                                    final _ = Lang.current.value;
                                    final actionText = isPermanent
                                        ? Lang.t("complete_delete")
                                        : Lang.t("temporary_delete");
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          '${Lang.t("confirm_delete")} "$actionText" ${device.title}؟',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.blue,
                                          size: 50,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  }),
                                  actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  actions: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Obx(() {
                                            final _ = Lang.current.value;
                                            return ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(
                                                  0xFFF39530,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: const BorderSide(
                                                    color: Color(0xFFF39530),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                Lang.t("cancel"),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 100,
                                          child: Obx(() {
                                            final _ = Lang.current.value;
                                            return ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                if (isPermanent) {
                                                  await homeController
                                                      .completeRemoveDevice(
                                                        device.deviceId,
                                                      );
                                                } else {
                                                  await homeController
                                                      .removeFromAllDashboard(
                                                        device.deviceId,
                                                      );
                                                }
                                                await homeController
                                                    .refreshAllData();
                                                Get.snackbar(
                                                  Lang.t("success"),
                                                  isPermanent
                                                      ? Lang.t(
                                                          "device_deleted_success",
                                                        )
                                                      : Lang.t(
                                                          "device_temp_removed",
                                                        ),
                                                  backgroundColor: Colors.green,
                                                  colorText: Colors.white,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                Lang.t("confirm"),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            // else if (value == 4) {
                            //   // حذف کامل
                            //   await showDeleteDeviceConfirmDialog(
                            //     context,
                            //     device.title,
                            //     () async {
                            //       await homeController.completeRemoveDevice(device.deviceId);
                            //       await homeController.refreshAllData();
                            //     },
                            //   );
                            // }
                            else if (value == 5) {
                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(() {
                                          final _ = Lang
                                              .current
                                              .value; // reactive trigger
                                          return Text(
                                            Lang.t('reset_config'),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        }),

                                        const SizedBox(height: 8),
                                        Obx(() {
                                          final _ = Lang
                                              .current
                                              .value; // reactive trigger
                                          return Text(
                                            Lang.t('choose_action'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        }),

                                        const SizedBox(height: 20),

                                        // --- گزینه پیکربندی ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () {
                                              Get.back();
                                              Get.to(
                                                () => DeviceConfigPage(
                                                  sn: device.sn,
                                                ),
                                              );
                                            },
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.settings,
                                                color: Colors.blueAccent,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('go_to_config'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // --- گزینه ریست ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () async {
                                              Get.back();
                                              await homeController.resetDevice(
                                                device.deviceId,
                                              );
                                              Get.snackbar(
                                                'موفقیت',
                                                'دستگاه ریست شد',
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            },
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.refresh,
                                                color: Colors.redAccent,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('reset_device'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // --- گزینه انصراف ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () => Get.back(),
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.cancel,
                                                color: Colors.amber,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('cancel'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    color: Colors.amber,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/edit.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('edit_key'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            // PopupMenuItem<int>(
                            //   value: 0,
                            //   child: Row(
                            //     textDirection: TextDirection.rtl,
                            //     children: [
                            //       SvgPicture.asset(
                            //         'assets/svg/settings.svg',
                            //         width: 20,
                            //         height: 20,
                            //       ),
                            //       const SizedBox(width: 2),
                            //       const Text('تنظیمات پیشرفته',
                            //           style: TextStyle(color: Colors.black)),
                            //     ],
                            //   ),
                            // ),
                            if (!homeController.dashboardDevices.any(
                              (d) => d.deviceId == device.deviceId,
                            ))
                              PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/add_dashboard.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 2),
                                    Obx(() {
                                      final _ = Lang
                                          .current
                                          .value; // reactive trigger
                                      return Text(
                                        Lang.t('add_to_dashboard'),
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            PopupMenuItem<int>(
                              value: 5,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/reset.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('reset_config'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/delete_temp.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('temporary_delete'),
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 4,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/deleting.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('complete_delete'),
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // SVG تنظیمات/LED
                      GestureDetector(
                        onTap: () {
                          showLedColorDialog(device: device);
                        },
                        child: SvgPicture.asset(
                          'assets/svg/advanced_settings.svg',
                          width: 20,
                          height: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // آخرین همگام‌سازی
                      Obx(() {
                        final lastSeen =
                            reliableController.lastDeviceActivity[deviceId];
                        String lastActivityText;

                        if (lastSeen != null) {
                          final formattedDate =
                              "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
                          final formattedTime =
                              "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
                          lastActivityText = Lang.t(
                            'last_sync_date_time',
                            params: {
                              'date': formattedDate,
                              'time': formattedTime,
                            },
                          );
                        } else {
                          lastActivityText = Lang.t('last_sync_unknown');
                        }

                        return Text(
                          lastActivityText,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // دایره لامپ بالا وسط
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: anySwitchOn
                        ? Colors.blue.shade400
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    if (anySwitchOn)
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    anySwitchOn ? 'assets/svg/on.svg' : 'assets/svg/off.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- ستون کلید (Switch Row) اصلاح شده -------------------
  Widget _buildSwitchRow({
    required String deviceId,
    required int switchNumber,
    required Color color,
    required Function(int switchNumber, bool value) onToggle,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    return Obx(() {
      final deviceData = reliableController.latestDeviceDataById[deviceId];
      bool isOn = false;

      if (deviceData != null) {
        final keyEntries = switchNumber == 1
            ? [
                if (deviceData['TW1'] is List) ...deviceData['TW1'],
                if (deviceData['TD1'] is List) ...deviceData['TD1'],
              ]
            : [
                if (deviceData['TW2'] is List) ...deviceData['TW2'],
                if (deviceData['TD2'] is List) ...deviceData['TD2'],
              ];

        if (keyEntries.isNotEmpty) {
          keyEntries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
          isOn = keyEntries.first[1].toString().contains('On');
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ), // فاصله بیشتر بین کلیدها
        child: Row(
          children: [
            // دایره رنگ وضعیت (بزرگتر)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  if (isOn)
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // دکمه روشن/خاموش (بزرگتر)
            GestureDetector(
              onTap: () => onToggle(switchNumber, !isOn),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? Colors.lightBlueAccent : Colors.grey.shade400,
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 20, // آیکون کمی بزرگتر
                ),
              ),
            ),
            const SizedBox(width: 10),

            // اسم کلید (فونت بزرگتر)
            Obx(() {
              final _ = Lang.current.value; // ⚡ reactive trigger
              return Text(
                Lang.t(
                  'switch_number',
                  params: {'number': switchNumber.toString()},
                ),
                style: const TextStyle(
                  fontSize: 16, // فونت بزرگتر
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ------------------- Smart Device S Card اصلاح شده -------------------
  Widget _buildSmartDeviceSCard({
    required String title,
    required String deviceId,
    required bool switch1On,
    required Set<Map<String, dynamic>> data_T,
    // bool? switch2On,
    // required Color iconColor1,
    // Color? iconColor2,
    required Function(bool value) onToggle,

    required DeviceItem device,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    bool anySwitchOn = switch1On;

    Color borderColor = anySwitchOn
        ? Colors.blue.shade400
        : Colors.grey.shade400;

    final homeController = Get.find<HomeController>();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 250),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 2),
            ),
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ردیف بالای کارت: کلیدها و اطلاعات دستگاه
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // کلیدها سمت چپ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDeviceSSwitch(
                              deviceId: deviceId,

                              // switchNumber: 1,
                              // color: iconColor1,
                              onToggle: onToggle,
                              switch1On: anySwitchOn,
                            ),
                            // if (!isSingleKey)
                            //   _buildDeviceSSwitch(
                            //     deviceId: deviceId,
                            //     switchNumber: 2,
                            //     color: iconColor2 ?? Colors.grey,
                            //     onToggle: onToggle,
                            //   ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // اطلاعات دستگاه سمت راست
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // وضعیت آنلاین و نوع کلید
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() {
                                final lastSeen = reliableController
                                    .lastDeviceActivity[deviceId];
                                final isOnline =
                                    lastSeen != null &&
                                    DateTime.now().difference(lastSeen) <
                                        const Duration(seconds: 30);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.blue : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Obx(() {
                                    final _ = Lang
                                        .current
                                        .value; // ⚡ reactive trigger
                                    return Text(
                                      isOnline
                                          ? Lang.t("online")
                                          : Lang.t("offline"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),
                                );
                              }),
                              const SizedBox(width: 6),

                              //                            Obx(() {
                              //   final _ = Lang.current.value; // ⚡ reactive trigger
                              //   // return Text(
                              //   //   isSingleKey ? Lang.t("single_key") : Lang.t("double_key"),
                              //   //   textAlign: TextAlign.right,
                              //   //   style: const TextStyle(
                              //   //     fontSize: 12,
                              //   //     color: Colors.grey,
                              //   //     fontWeight: FontWeight.w500,
                              //   //   ),
                              //   // );
                              // }),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // عنوان دستگاه
                          Text(
                            title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // مکان دستگاه با آیکن
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  device.dashboardTitle ?? "بدون مکان",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/svg/location.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // ردیف پایین کارت: سه نقطه، SVG تنظیمات و آخرین همگام‌سازی
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PopupMenuButton (سه نقطه)
                      Builder(
                        builder: (context) => PopupMenuButton<int>(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onSelected: (value) async {
                            if (value == 1) {
                              Get.to(
                                () => EditDevicePage(
                                  deviceId: device.deviceId,
                                  serialNumber: device.sn,
                                  initialName: device.title ?? '',
                                  initialDashboardId: device.dashboardId ?? '',
                                ),
                              );
                            } else if (value == 0) {
                              // showLedColorDialog(device);
                            } else if (value == 2) {
                              // افزودن به داشبورد
                              if (!homeController.dashboardDevices.any(
                                (d) => d.deviceId == device.deviceId,
                              )) {
                                final token = homeController.token;
                                if (token == null) {
                                  Get.snackbar(
                                    "خطا",
                                    "توکن معتبر پیدا نشد",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                final headers = {
                                  'Authorization': 'Bearer $token',
                                  'Content-Type': 'application/json',
                                };
                                final data = {"deviceId": device.deviceId};
                                try {
                                  final dio = Dio();
                                  final response = await dio.post(
                                    'http://45.149.76.245:8080/api/shortcut/addDevice',
                                    data: data,
                                    options: Options(headers: headers),
                                  );
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    Get.snackbar(
                                      'موفقیت',
                                      'دستگاه به داشبورد اضافه شد',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                    homeController.dashboardDevices.add(device);
                                  } else {
                                    Get.snackbar(
                                      'خطا',
                                      'افزودن دستگاه موفق نبود: ${response.statusCode}',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'خطا',
                                    'مشکل در ارتباط با سرور: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  'توجه',
                                  'این دستگاه قبلاً به داشبورد اضافه شده است',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            } else if (value == 3 || value == 4) {
                              final isPermanent = value == 4;

                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  titlePadding: EdgeInsets.zero,
                                  title: Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    final actionText = isPermanent
                                        ? Lang.t("complete_delete")
                                        : Lang.t("temporary_delete");
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        actionText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }),
                                  content: Obx(() {
                                    final _ = Lang.current.value;
                                    final actionText = isPermanent
                                        ? Lang.t("complete_delete")
                                        : Lang.t("temporary_delete");
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          '${Lang.t("confirm_delete")} "$actionText" ${device.title}؟',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.blue,
                                          size: 50,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  }),
                                  actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  actions: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Obx(() {
                                            final _ = Lang.current.value;
                                            return ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: const Color(
                                                  0xFFF39530,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  side: const BorderSide(
                                                    color: Color(0xFFF39530),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                Lang.t("cancel"),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 100,
                                          child: Obx(() {
                                            final _ = Lang.current.value;
                                            return ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                if (isPermanent) {
                                                  await homeController
                                                      .completeRemoveDevice(
                                                        device.deviceId,
                                                      );
                                                } else {
                                                  await homeController
                                                      .removeFromAllDashboard(
                                                        device.deviceId,
                                                      );
                                                }
                                                await homeController
                                                    .refreshAllData();
                                                Get.snackbar(
                                                  Lang.t("success"),
                                                  isPermanent
                                                      ? Lang.t(
                                                          "device_deleted_success",
                                                        )
                                                      : Lang.t(
                                                          "device_temp_removed",
                                                        ),
                                                  backgroundColor: Colors.green,
                                                  colorText: Colors.white,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                Lang.t("confirm"),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            // else if (value == 4) {
                            //   // حذف کامل
                            //   await showDeleteDeviceConfirmDialog(
                            //     context,
                            //     device.title,
                            //     () async {
                            //       await homeController.completeRemoveDevice(device.deviceId);
                            //       await homeController.refreshAllData();
                            //     },
                            //   );
                            // }
                            else if (value == 5) {
                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(() {
                                          final _ = Lang
                                              .current
                                              .value; // reactive trigger
                                          return Text(
                                            Lang.t('reset_config'),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        }),

                                        const SizedBox(height: 8),
                                        Obx(() {
                                          final _ = Lang
                                              .current
                                              .value; // reactive trigger
                                          return Text(
                                            Lang.t('choose_action'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        }),

                                        const SizedBox(height: 20),

                                        // --- گزینه پیکربندی ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () {
                                              Get.back();
                                              Get.to(
                                                () => DeviceConfigPage(
                                                  sn: device.sn,
                                                ),
                                              );
                                            },
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.settings,
                                                color: Colors.blueAccent,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('go_to_config'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // --- گزینه ریست ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () async {
                                              Get.back();
                                              await homeController.resetDevice(
                                                device.deviceId,
                                              );
                                              Get.snackbar(
                                                'موفقیت',
                                                'دستگاه ریست شد',
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            },
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.refresh,
                                                color: Colors.redAccent,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('reset_device'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // --- گزینه انصراف ---
                                        Card(
                                          color: const Color(0xFFF8F9FA),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            onTap: () => Get.back(),
                                            child: ListTile(
                                              trailing: const Icon(
                                                Icons.cancel,
                                                color: Colors.amber,
                                              ),
                                              title: Obx(() {
                                                final _ = Lang
                                                    .current
                                                    .value; // reactive trigger
                                                return Text(
                                                  Lang.t('cancel'),
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                    color: Colors.amber,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                              }),

                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/edit.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('edit_key'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            // PopupMenuItem<int>(
                            //   value: 0,
                            //   child: Row(
                            //     textDirection: TextDirection.rtl,
                            //     children: [
                            //       SvgPicture.asset(
                            //         'assets/svg/settings.svg',
                            //         width: 20,
                            //         height: 20,
                            //       ),
                            //       const SizedBox(width: 2),
                            //       const Text('تنظیمات پیشرفته',
                            //           style: TextStyle(color: Colors.black)),
                            //     ],
                            //   ),
                            // ),
                            if (!homeController.dashboardDevices.any(
                              (d) => d.deviceId == device.deviceId,
                            ))
                              PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/add_dashboard.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 2),
                                    Obx(() {
                                      final _ = Lang
                                          .current
                                          .value; // reactive trigger
                                      return Text(
                                        Lang.t('add_to_dashboard'),
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            PopupMenuItem<int>(
                              value: 5,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/reset.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('reset_config'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/delete_temp.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('temporary_delete'),
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 4,
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/deleting.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Obx(() {
                                    final _ =
                                        Lang.current.value; // reactive trigger
                                    return Text(
                                      Lang.t('complete_delete'),
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // SVG تنظیمات/LED
                      GestureDetector(
                        onTap: () {
                          showSettingsDialog(device: device, data_T: data_T);
                          print(data_T);
                        },
                        child: SvgPicture.asset(
                          'assets/svg/advanced_settings.svg',
                          width: 20,
                          height: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // آخرین همگام‌سازی
                      Obx(() {
                        final lastSeen =
                            reliableController.lastDeviceActivity[deviceId];
                        String lastActivityText;

                        if (lastSeen != null) {
                          final formattedDate =
                              "${lastSeen.year}/${lastSeen.month.toString().padLeft(2, '0')}/${lastSeen.day.toString().padLeft(2, '0')}";
                          final formattedTime =
                              "${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}:${lastSeen.second.toString().padLeft(2, '0')}";
                          lastActivityText = Lang.t(
                            'last_sync_date_time',
                            params: {
                              'date': formattedDate,
                              'time': formattedTime,
                            },
                          );
                        } else {
                          lastActivityText = Lang.t('last_sync_unknown');
                        }

                        return Text(
                          lastActivityText,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // دایره لامپ بالا وسط
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: anySwitchOn
                        ? Colors.blue.shade400
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    if (anySwitchOn)
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    anySwitchOn
                        ? 'assets/svg/air-conditioner-on.svg'
                        : 'assets/svg/air-conditioner.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Device S Switch اصلاح شده -------------------
  Widget _buildDeviceSSwitch({
    required String deviceId,
    // required int switchNumber,
    // required Color color,
    required bool switch1On,
    required Function(bool value) onToggle,
  }) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );

    bool anySwitchOn = switch1On;
    return Obx(() {
      final deviceData = reliableController.latestDeviceDataById[deviceId];
      // bool isOn = false;

      // if (deviceData != null) {
      //   final keyEntries = switchNumber == 1
      //       ? [
      //           if (deviceData['TW1'] is List) ...deviceData['TW1'],
      //           if (deviceData['TD1'] is List) ...deviceData['TD1'],
      //         ]
      //       : [
      //           if (deviceData['TW2'] is List) ...deviceData['TW2'],
      //           if (deviceData['TD2'] is List) ...deviceData['TD2'],
      //         ];

      //   if (keyEntries.isNotEmpty) {
      //     keyEntries.sort((a, b) => (b[0] as int).compareTo(a[0] as int));
      //     isOn = keyEntries.first[1].toString().contains('On');
      //   }
      // }
      // bool readLatestPowerSwitch(Map deviceData) {
      //   final List<List<dynamic>> powerKeys = [];

      //   if (deviceData["TDPower"] is List) {
      //     powerKeys.addAll(List.from(deviceData["TDPower"]));
      //   }
      //   if (deviceData["TWPower"] is List) {
      //     powerKeys.addAll(List.from(deviceData["TWPower"]));
      //   }

      //   // if (powerKeys.isEmpty) return false;

      //   // مرتب‌سازی بر اساس timestamp (جدیدترین اول)
      //   powerKeys.sort((a, b) => (b[0] as int).compareTo(a[0] as int));

      //   final latestItem = powerKeys.first;
      //   if (latestItem is List && latestItem.length > 1) {
      //     final value = latestItem[1];

      //     // اگر Map بود و کلید c داشت
      //     if (value is Map && value.containsKey("c")) {
      //       final cValue = value["c"];
      //       if (cValue is int) return cValue == 1;
      //       if (cValue is String)
      //         return cValue == "1" || cValue.toLowerCase().contains("on");
      //     }

      //     // اگر مستقیم int باشد
      //     if (value is int) return value == 1;

      //     // اگر مستقیم String باشد
      //     if (value is String) return value.toLowerCase().contains("on");
      //   }

      //   return false;
      // }

      // bool switch1On22 = readLatestPowerSwitch(deviceData as Map);

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ), // فاصله بیشتر بین کلیدها
        child: Row(
          children: [
            // // دایره رنگ وضعیت (بزرگتر)
            // Container(
            //   width: 20,
            //   height: 20,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: color,
            //     boxShadow: [
            //       if (isOn)
            //         BoxShadow(
            //           color: color.withOpacity(0.6),
            //           blurRadius: 6,
            //           spreadRadius: 2,
            //         ),
            //     ],
            //   ),
            // ),
            // const SizedBox(width: 8),

            // دکمه روشن/خاموش (بزرگتر)
            GestureDetector(
              onTap: () => onToggle(!anySwitchOn),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: anySwitchOn
                      ? Colors.lightBlueAccent
                      : Colors.grey.shade400,
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 20, // آیکون کمی بزرگتر
                ),
              ),
            ),
            const SizedBox(width: 10),

            // اسم کلید (فونت بزرگتر)
            Obx(() {
              final _ = Lang.current.value; // ⚡ reactive trigger
              return Text(
                anySwitchOn ? "روشن" : "خاموش",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Future<void> showDeleteDeviceConfirmDialog(
    BuildContext context,
    String title,
    Future<String?> Function()
    onDelete, // تابع حذف برمی‌گرداند String? برای پیام خطا
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          titlePadding: EdgeInsets.zero,
          title: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Obx(() {
              final _ = Lang.current.value; // ⚡ reactive trigger
              return Text(
                Lang.t('delete_device'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              );
            }),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Obx(() {
                  final _ = Lang.current.value; // ⚡ reactive trigger
                  return Text(
                    Lang.t('confirm_delete_item', params: {'title': title}),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  );
                }),

                const SizedBox(height: 20),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.blue,
                  size: 50,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔸 دکمه انصراف
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF39530),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFF39530),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Text(
                        Lang.t('cancel'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 4),

                // 🔹 دکمه حذف
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // بستن دیالوگ

                      String? error = await onDelete();

                      if (error == null) {
                        await controller.refreshAllData();

                        Get.snackbar(
                          'موفقیت',
                          'عملیات حذف با موفقیت انجام شد.',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        // ترجمه پیام خطا به فارسی
                        String errorMessage = error;
                        if (error.contains(
                          'Cannot delete dashboard: contains device configuration.',
                        )) {
                          errorMessage =
                              'امکان حذف وجود ندارد؛ دستگاه‌هایی به این مکان متصل هستند.';
                        }

                        Get.snackbar(
                          'خطا',
                          errorMessage,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value; // ⚡ reactive trigger
                      return Text(
                        Lang.t('delete'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddLocationDialog() {
    final TextEditingController nameController = TextEditingController();
    int? selectedIconIndex; // 👈 برای ذخیره انتخاب کاربر

    showDialog(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Obx(() {
                  final _ = Lang.current.value; // ⚡ reactive trigger
                  return Text(
                    Lang.t('add_location'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final _ = Lang.current.value; // ⚡ reactive trigger
                        return TextField(
                          controller: nameController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            label: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                Lang.t('location_name'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            hintText: Lang.t('enter_location_name'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      /// عنوان بخش آیکن‌ها
                      Obx(() {
                        final _ = Lang.current.value; // ⚡ reactive trigger
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            Lang.t(
                              'select_location_icon',
                            ), // کلید ترجمه در فایل JSON
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      /// لیست آیکن‌ها
                      /// لیست آیکن‌ها - اسکرول افقی و دایره کامل
                      SizedBox(
                        height: 70, // ارتفاع کانتینر آیکن‌ها
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(18, (index) {
                              final iconNumber = index + 1;
                              final isSelected =
                                  selectedIconIndex == iconNumber;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIconIndex = iconNumber;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle, // 🔹 دایره کامل
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.yellow.shade700
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: SvgPicture.asset(
                                    'assets/svg/$iconNumber.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFF39530),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFF39530),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t('cancel'), // کلید ترجمه در JSON
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar(
                              'خطا',
                              'لطفاً نام مکان را وارد کنید',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          // اگر آیکن انتخاب نشده بود، هشدار بده
                          if (selectedIconIndex == null) {
                            Get.snackbar(
                              'خطا',
                              'لطفاً یک آیکن انتخاب کنید',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await controller.addLocation(
                            name,
                            iconIndex: selectedIconIndex,
                          );

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t('submit'), // کلید ترجمه در JSON
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingDeviceCard({required String title}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_sharp, size: 40, color: Colors.grey),
                  Icon(Icons.lightbulb_sharp, size: 40, color: Colors.grey),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1E3A8A),
                ),
                textAlign: TextAlign.right,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t(
                              'key_loading',
                              params: {'number': '۱'},
                            ), // کلید ترجمه با پارامتر شماره
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final _ = Lang.current.value; // ⚡ reactive trigger
                          return Text(
                            Lang.t('key_loading', params: {'number': '۲'}),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDevicesFound() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double svgHeight = (constraints.maxHeight * 0.4).clamp(
            120.0,
            300.0,
          );
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: svgHeight,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.asset(
                    'assets/images/device_notFound.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                final _ = Lang.current.value; // ⚡ reactive trigger
                return Text(
                  Lang.t('no_device_found'),
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // ------------------- Advanced Settings Dialog -------------------
  void showLedColorDialog({required DeviceItem device}) {
    final reliableController = Get.find<ReliableSocketController>(
      tag: 'smartDevicesController',
    );
    final deviceData = reliableController.latestDeviceDataById[device.deviceId];
    final isSingleKey = device.deviceTypeName == 'key-1';

    // Reactive colors
    Rx<Color> touch1On = const Color(0xFF2196F3).obs;
    Rx<Color> touch1Off = const Color(0xFF9E9E9E).obs;
    Rx<Color> touch2On = const Color(0xFF4CAF50).obs;
    Rx<Color> touch2Off = const Color(0xFF9E9E9E).obs;

    // مقداردهی اولیه از داده دستگاه
    if (deviceData != null &&
        deviceData['ledColor'] is List &&
        deviceData['ledColor'].isNotEmpty) {
      try {
        final ledEntry = deviceData['ledColor'][0][1];
        Map<String, dynamic> ledMap = ledEntry is String
            ? jsonDecode(ledEntry)
            : (ledEntry as Map<String, dynamic>);

        if (ledMap['c']['t1'] != null) {
          touch1On.value = Color.fromARGB(
            255,
            (ledMap['c']['t1']['on']['r'] as int).clamp(0, 255),
            (ledMap['c']['t1']['on']['g'] as int).clamp(0, 255),
            (ledMap['c']['t1']['on']['b'] as int).clamp(0, 255),
          );
          touch1Off.value = Color.fromARGB(
            255,
            (ledMap['c']['t1']['off']['r'] as int).clamp(0, 255),
            (ledMap['c']['t1']['off']['g'] as int).clamp(0, 255),
            (ledMap['c']['t1']['off']['b'] as int).clamp(0, 255),
          );
        }

        if (!isSingleKey && ledMap['c']['t2'] != null) {
          touch2On.value = Color.fromARGB(
            255,
            (ledMap['c']['t2']['on']['r'] as int).clamp(0, 255),
            (ledMap['c']['t2']['on']['g'] as int).clamp(0, 255),
            (ledMap['c']['t2']['on']['b'] as int).clamp(0, 255),
          );
          touch2Off.value = Color.fromARGB(
            255,
            (ledMap['c']['t2']['off']['r'] as int).clamp(0, 255),
            (ledMap['c']['t2']['off']['g'] as int).clamp(0, 255),
            (ledMap['c']['t2']['off']['b'] as int).clamp(0, 255),
          );
        }
      } catch (e) {
        print("❗️Error parsing ledColor: $e");
      }
    }

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Obx(() {
                final _ = Lang.current.value; // ⚡ reactive trigger
                return Text(
                  Lang.t('advanced_settings'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => _ColorPreviewPicker(
                    label: Lang.t('single_key_on'), // 🔹 ترجمه
                    color: touch1On.value,
                    onPick: (c) => touch1On.value = c,
                  ),
                ),
                Obx(
                  () => _ColorPreviewPicker(
                    label: Lang.t('single_key_off'),
                    color: touch1Off.value,
                    onPick: (c) => touch1Off.value = c,
                  ),
                ),
                if (!isSingleKey) ...[
                  const SizedBox(height: 8),
                  Obx(
                    () => _ColorPreviewPicker(
                      label: Lang.t('double_key_on'),
                      color: touch2On.value,
                      onPick: (c) => touch2On.value = c,
                    ),
                  ),
                  Obx(
                    () => _ColorPreviewPicker(
                      label: Lang.t('double_key_off'),
                      color: touch2Off.value,
                      onPick: (c) => touch2Off.value = c,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFF39530),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFF39530),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Obx(() {
                        final _ = Lang.current.value; // ⚡ reactive trigger
                        return Text(
                          Lang.t('cancel'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 100,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 🔹 ارسال رنگ‌ها به API
                        try {
                          final token = controller.token;
                          final dio = Dio();
                          final headers = {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          };

                          final data = json.encode({
                            "deviceId": device.deviceId,
                            "request": {
                              "ledColor": {
                                "t1": {
                                  "on": {
                                    "r": touch1On.value.red,
                                    "g": touch1On.value.green,
                                    "b": touch1On.value.blue,
                                  },
                                  "off": {
                                    "r": touch1Off.value.red,
                                    "g": touch1Off.value.green,
                                    "b": touch1Off.value.blue,
                                  },
                                },
                                if (!isSingleKey)
                                  "t2": {
                                    "on": {
                                      "r": touch2On.value.red,
                                      "g": touch2On.value.green,
                                      "b": touch2On.value.blue,
                                    },
                                    "off": {
                                      "r": touch2Off.value.red,
                                      "g": touch2Off.value.green,
                                      "b": touch2Off.value.blue,
                                    },
                                  },
                              },
                            },
                          });

                          print('🔹 Sending LED color payload: $data');

                          final response = await dio.post(
                            'http://45.149.76.245:8080/api/plugins/telemetry/changeDeviceState',
                            options: Options(headers: headers),
                            data: data,
                          );

                          if (response.statusCode == 200) {
                            print('✅ Success: ${response.data}');
                            Get.snackbar(
                              'موفق',
                              'رنگ کلید با موفقیت تغییر کرد',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            Navigator.of(context).pop();
                          } else {
                            print(
                              '⚠️ Response: ${response.statusCode} ${response.data}',
                            );
                            Get.snackbar(
                              'خطا',
                              'خطا در تغییر رنگ: ${response.data}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        } on DioException catch (e) {
                          print('❌ Dio error: ${e.message}');
                          Get.snackbar(
                            'خطا',
                            'خطا در ارتباط با سرور: ${e.message}',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Obx(() {
                        final _ = Lang.current.value; // ⚡ reactive trigger
                        return Text(
                          Lang.t('submit'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }




void showSettingsDialog({
  required DeviceItem device,
  required Set<Map<String, dynamic>> data_T,
}) {
  final RxInt selectedTab = 0.obs;
  final RxString deviceType = 'نوع 1'.obs;
  final RxString maxPower = ''.obs;
  final RxInt selectedMode = 0.obs; // 0: آبی | 1: قرمز | 2: بنفش
  const double minTemp = 16;
  const double maxTemp = 40;
  final RxDouble currentTemp = 22.0.obs; // دمای اولیه
  final RxDouble fanSpeed = 1.0.obs;

  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: EdgeInsets.zero,

        // 🔹 HEADER
        title: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Obx(() {
              final _ = Lang.current.value;
              return Text(
                Lang.t('settings_dialog'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
        ),

        // 🔹 BODY
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 TABS
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => selectedTab.value = 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab.value == 0
                                    ? Colors.blue.shade100
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  Lang.t('basic_settings'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedTab.value == 0
                                        ? Colors.blue
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => selectedTab.value = 1,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab.value == 1
                                    ? Colors.blue.shade100
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  Lang.t('advanced_settings'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedTab.value == 1
                                        ? Colors.blue
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 20),

                /// 🔹 CONTENT
                Obx(() {
                  if (selectedTab.value == 0) {
                    return Column(
                      children: [
                        /// ✅ نوع دستگاه + حداکثر توان
                        Row(
                          children: [
                            /// نوع دستگاه
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'نوع دستگاه',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.devices,
                                            color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DropdownButtonHideUnderline(
                                            child: Obx(
                                              () => DropdownButton<String>(
                                                value: deviceType.value,
                                                isExpanded: true,
                                                icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.blue),
                                                items: [
                                                  'نوع 1',
                                                  'نوع 2',
                                                  'نوع 3'
                                                ]
                                                    .map((e) => DropdownMenuItem(
                                                          value: e,
                                                          child: Text(
                                                            e,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (val) {
                                                  if (val != null)
                                                    deviceType.value = val;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// حداکثر توان
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'حداکثر توان (W)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.bolt, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) =>
                                                maxPower.value = val,
                                            style:
                                                const TextStyle(color: Colors.blue),
                                            decoration: const InputDecoration(
                                              hintText: 'مثلاً 1000',
                                              suffixText: 'W',
                                              border: InputBorder.none,
                                              hintStyle:
                                                  TextStyle(color: Colors.blueGrey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// 🔹 حالت عملکرد
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'حالت عملکرد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Obx(
                          () => SizedBox(
                            height: 55,
                            child: Row(
                              children: [
                                // 🔵 نرمال
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () => selectedMode.value = 0,
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: selectedMode.value == 0
                                            ? Colors.blue
                                            : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.flash_on,
                                            color: selectedMode.value == 0
                                                ? Colors.blue.shade900
                                                : Colors.blue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'نرمال',
                                            style: TextStyle(
                                              color: selectedMode.value == 0
                                                  ? Colors.blue.shade900
                                                  : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 🔴 پرقدرت
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () => selectedMode.value = 1,
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: selectedMode.value == 1
                                            ? Colors.red
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: selectedMode.value == 1
                                                ? Colors.red.shade900
                                                : Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'پرقدرت',
                                            style: TextStyle(
                                              color: selectedMode.value == 1
                                                  ? Colors.red.shade900
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 🟣 هوشمند
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () => selectedMode.value = 2,
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: selectedMode.value == 2
                                            ? Colors.purple
                                            : Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.auto_mode,
                                            color: selectedMode.value == 2
                                                ? Colors.purple.shade900
                                                : Colors.purple,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'هوشمند',
                                            style: TextStyle(
                                              color: selectedMode.value == 2
                                                  ? Colors.purple.shade900
                                                  : Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// 🔹 دمای مطلوب
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'دمای مطلوب',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () => SizedBox(
                                height: 200,
                                width: 200,
                                child: SleekCircularSlider(
                                  min: minTemp,
                                  max: maxTemp,
                                  initialValue: currentTemp.value,
                                  appearance: CircularSliderAppearance(
                                    customWidths: CustomSliderWidths(
                                      trackWidth: 10,
                                      progressBarWidth: 12,
                                      shadowWidth: 0,
                                    ),
                                    infoProperties: InfoProperties(
                                      mainLabelStyle: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      modifier: (value) => '${value.toInt()}°',
                                    ),
                                    size: 200,
                                    startAngle: 270,
                                    angleRange: 360,
                                    customColors: CustomSliderColors(
                                      trackColor: Colors.blue.shade100,
                                      progressBarColor: Colors.blue,
                                      dotColor: Colors.blueAccent,
                                    ),
                                  ),
                                  onChange: (value) {
                                    currentTemp.value = value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        


Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Align(
      alignment: Alignment.centerRight,
      child: Text(
        'سرعت فن',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    ),
    const SizedBox(height: 12),
    SizedBox(
      height: 60,
      width: MediaQuery.of(Get.context!).size.width * 0.8,
      child: Stack(
        children: [
          // پس‌زمینه پرگرس
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.orange.shade400,
                ],
              ),
            ),
          ),
          // آیکن روی وضعیت فعلی
          Obx(() {
            final trackWidth = MediaQuery.of(Get.context!).size.width * 0.8;
            final iconSize = 36.0;
            double leftPos;

            switch (fanSpeed.value.toInt()) {
              case 1:
                leftPos = 8;
                break;
              case 2:
                leftPos = (trackWidth - iconSize) / 2;
                break;
              case 3:
                leftPos = trackWidth - iconSize - 8;
                break;
              default:
                leftPos = 8;
            }

            return Positioned(
              left: leftPos,
              top: (60 - iconSize) / 2,
              child: IgnorePointer(
                child: Icon(Icons.air, color: Colors.black, size: iconSize),
              ),
            );
          }),
          // Slider
          Obx(() => SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  trackHeight: 60,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 25),
                  thumbColor: Colors.orange,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
                child: Slider(
                  value: fanSpeed.value,
                  min: 1,
                  max: 3,
                  divisions: 2,
                  onChanged: (value) => fanSpeed.value = value,
                  label: fanSpeed.value == 1
                      ? 'کم'
                      : fanSpeed.value == 2
                          ? 'متوسط'
                          : 'زیاد',
                ),
              )),
        ],
      ),
    ),
    const SizedBox(height: 8),
    Obx(() => Text(
          'سرعت: ${fanSpeed.value == 1 ? 'کم' : fanSpeed.value == 2 ? 'متوسط' : 'زیاد'}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        )),
  ],
),

                        const SizedBox(height: 20),

                        /// نمایش مقدار انتخاب شده
                        Obx(
                          () => Text(
                            'انتخاب شما: ${deviceType.value} | ${maxPower.value} W',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'این متن مربوط به تنظیمات پیشرفته است.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // 🔹 BUTTONS
        actions: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF39530),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFFF39530),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value;
                      return Text(
                        Lang.t('cancel'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      print(
                        '✅ ثبت شد => نوع: ${deviceType.value}, توان: ${maxPower.value}W, دما: ${currentTemp.value.toInt()}°',
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: Obx(() {
                      final _ = Lang.current.value;
                      return Text(
                        Lang.t('submit'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}





}

// ------------------- Color Picker Widget -------------------
class _ColorPreviewPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onPick;

  const _ColorPreviewPicker({
    required this.label,
    required this.color,
    required this.onPick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            Color tempColor = color;
            Color? picked = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  titlePadding: const EdgeInsets.all(16),
                  title: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Center(
                      child: Obx(() {
                        final _ = Lang.current.value; // ⚡ reactive trigger
                        return Text(
                          Lang.t('change_key_color'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: tempColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black26, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (c) => tempColor = c,
                            showLabel: false,
                            pickerAreaHeightPercent: 0.8,
                            enableAlpha: false,
                            displayThumbColor: true,
                            portraitOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  actions: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // دکمه انصراف
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFF39530),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Color(0xFFF39530),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Obx(() {
                                final _ =
                                    Lang.current.value; // ⚡ reactive trigger
                                return Text(
                                  Lang.t('cancel'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // دکمه تایید همیشه آبی
                          SizedBox(
                            width: 100,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(tempColor),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: Obx(() {
                                final _ =
                                    Lang.current.value; // ⚡ reactive trigger
                                return Text(
                                  Lang.t('confirm'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black26),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
