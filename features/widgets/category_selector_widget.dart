import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CategorySelectorWidget extends StatelessWidget {
  const CategorySelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اماکن',
                  style: TextStyle(
                    fontFamily: 'IranYekan',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: const Text(
                    'ویرایش',
                    style: TextStyle(
                      fontFamily: 'IranYekan',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryButton('همه', Icons.home, isSelected: true),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'اتاق خواب',
                    Icons.bed,
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'حمام',
                    Icons.bathtub,
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton('حال', Icons.tv, isSelected: false),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'آشپزخانه',
                    Icons.kitchen,
                    isSelected: false,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'اتاق کار',
                    Icons.work,
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String title,
    IconData icon, {
    required bool isSelected,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[600] : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IranYekan',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
