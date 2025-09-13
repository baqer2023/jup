import 'package:flutter/material.dart';
import 'package:my_app32/app/theme/app_colors.dart';
import 'package:my_app32/features/dashboard_item_detail/pages/main/dashboard_item_detail_controller.dart';

class LightBulbWidget extends StatelessWidget {
  const LightBulbWidget({
    required this.index,
    required this.controller,
    required this.title,
    required this.isOn,
  });

  final int index;
  final DashboardItemDetailController controller;
  final String title;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFF8FBFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0676C8).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF0676C8).withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF0676C8), const Color(0xFF49A7EA)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0676C8).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.lightbulb_outline,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Status with background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOn
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : const Color(0xFF6B7280).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                isOn ? "روشن" : "خاموش",
                style: TextStyle(
                  fontSize: 14,
                  color: isOn
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Enhanced Switch
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0676C8).withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Switch(
                value: isOn,
                onChanged: (bool value) {
                  controller.sendCommandToDevice(value: value, index: index);
                },
                activeColor: const Color(0xFF0676C8),
                activeTrackColor: const Color(0xFF49A7EA).withOpacity(0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE5E7EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
