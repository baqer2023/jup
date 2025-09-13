import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_app32/app/theme/app_colors.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.title,
    this.onTap,
    this.showBackButton = true,
    this.phoneNumber,
    this.profileImageUrl,
    this.onProfileTap,
    this.onMenuTap,
  });

  final String title;
  final VoidCallback? onTap;
  final bool showBackButton;
  final String? phoneNumber;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      color: Colors.blue, // Set background color to blue
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu button
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white), // White icon
              onPressed:
                  onMenuTap ??
                  () {
                    Scaffold.of(context).openDrawer();
                  },
            ),

            // Phone number and title
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (phoneNumber != null)
                  Text(
                    phoneNumber!,
                    style: const TextStyle(
                      color: Colors.white, // White text
                      fontSize: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                IconButton(
                  icon: const Icon(
                    Icons.add_alert,
                    color: Colors.white,
                    size: 35,
                  ), // White icon
                  onPressed:
                      onMenuTap ??
                      () {
                        Scaffold.of(context).openDrawer();
                      },
                ),
              ],
            ),

            // Profile picture
            Builder(
              builder: (context) => GestureDetector(
                onTap:
                    onProfileTap ??
                    () {
                      Scaffold.of(context).openEndDrawer();
                    },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    image: profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profileImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileImageUrl == null
                      ? const Icon(Icons.menu, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
