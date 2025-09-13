import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  static void showProfileDialog(String token) {
    final context = Get.context!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchProfileStatic(token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.error_outline, color: Colors.red),
                    ),
                    const SizedBox(width: 12),
                    const Text('خطا'),
                  ],
                ),
                content: const Text('دریافت اطلاعات پروفایل با خطا مواجه شد.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('بستن'),
                  ),
                ],
              );
            }

            final profile = snapshot.data!;
            return _buildProfileDialogStatic(context, profile, token);
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> _fetchProfileStatic(String token) async {
    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/user/profile');
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      });

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  static Widget _buildProfileDialogStatic(
      BuildContext context, Map<String, dynamic> profile, String token) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderStatic(context),
                  _buildFormStatic(context, setState, profile, token),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildHeaderStatic(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF42A5F5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'پروفایل کاربر',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'کاربر مدیر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  static Widget _buildFormStatic(BuildContext context, StateSetter setState,
      Map<String, dynamic> profile, String token) {
    final emailController = TextEditingController(text: profile['email'] ?? '');
    final phoneController =
        TextEditingController(text: profile['phoneNumber'] ?? '');
    final firstNameController =
        TextEditingController(text: profile['firstName'] ?? '');
    final lastNameController =
        TextEditingController(text: profile['lastName'] ?? '');
    String? selectedCity = profile['city'];
    final String? id = profile['id'];
    final List<String> cities = ['تهران', 'اصفهان', 'شیراز', 'مشهد', 'تبریز'];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFieldStatic(
                'ایمیل', emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextFieldStatic(
                'شماره همراه', phoneController, Icons.phone_outlined,
                enabled: false),
            const SizedBox(height: 16),
            _buildTextFieldStatic(
                'نام', firstNameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextFieldStatic(
                'نام خانوادگی', lastNameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildCityDropdownStatic(setState, selectedCity, cities),
            const SizedBox(height: 32),
            _buildSaveButtonStatic(
                context,
                emailController,
                phoneController,
                firstNameController,
                lastNameController,
                selectedCity,
                id,
                token),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFieldStatic(
      String label, TextEditingController controller, IconData icon,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color:
                  enabled ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
              size: 20,
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF42A5F5), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  static Widget _buildCityDropdownStatic(
      StateSetter setState, String? selectedCity, List<String> cities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'شهر',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCity != null && cities.contains(selectedCity)
              ? selectedCity
              : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.location_city_outlined,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF42A5F5), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          hint: const Text(
            'انتخاب شهر',
            textAlign: TextAlign.right,
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          items: cities
              .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(
                      city,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Color(0xFF111827)),
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => selectedCity = value),
          alignment: AlignmentDirectional.centerEnd,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF111827)),
        ),
      ],
    );
  }

  static Widget _buildSaveButtonStatic(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController phoneController,
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      String? selectedCity,
      String? id,
      String token) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF42A5F5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          final success = await _updateProfileStatic(
              emailController,
              phoneController,
              firstNameController,
              lastNameController,
              selectedCity,
              id,
              token);
          if (success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تغییرات با موفقیت ثبت شد'),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('خطا در ثبت تغییرات'),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'ثبت تغییرات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool> _updateProfileStatic(
      TextEditingController emailController,
      TextEditingController phoneController,
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      String? selectedCity,
      String? id,
      String token) async {
    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/user/updateProfile');
      final body = json.encode({
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'id': id,
        'city': selectedCity,
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: utf8.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  String? selectedCity;
  String? id;
  final List<String> cities = ['تهران', 'اصفهان', 'شیراز', 'مشهد', 'تبریز'];

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/user/profile');
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json; charset=utf-8',
      });

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<bool> _updateProfile() async {
    try {
      final url = Uri.parse('http://45.149.76.245:8080/api/user/updateProfile');
      final body = json.encode({
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'id': id,
        'city': selectedCity,
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: utf8.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: const Text('خطا'),
                content: const Text('دریافت اطلاعات پروفایل با خطا مواجه شد.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('بستن'),
                  ),
                ],
              );
            }

            final profile = snapshot.data!;
            _initializeControllers(profile);

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          _buildForm(setState),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _initializeControllers(Map<String, dynamic> profile) {
    emailController.text = profile['email'] ?? '';
    phoneController.text = profile['phoneNumber'] ?? '';
    firstNameController.text = profile['firstName'] ?? '';
    lastNameController.text = profile['lastName'] ?? '';
    id = profile['id'];
    selectedCity = profile['city'];
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          const Text('کاربر مدیر',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.verified_user, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildForm(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('ایمیل', emailController),
            const SizedBox(height: 12),
            _buildTextField('شماره همراه', phoneController, enabled: false),
            const SizedBox(height: 12),
            _buildTextField('نام', firstNameController),
            const SizedBox(height: 12),
            _buildTextField('نام خانوادگی', lastNameController),
            const SizedBox(height: 12),
            _buildCityDropdown(setState),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, textAlign: TextAlign.right),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(StateSetter setState) {
    return Row(
      children: [
        const Expanded(child: Text('شهر', textAlign: TextAlign.right)),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedCity != null && cities.contains(selectedCity)
                ? selectedCity
                : null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('انتخاب شهر', textAlign: TextAlign.right),
            items: cities
                .map((city) => DropdownMenuItem(
                    value: city, child: Text(city, textAlign: TextAlign.right)))
                .toList(),
            onChanged: (value) => setState(() => selectedCity = value),
            alignment: AlignmentDirectional.centerEnd,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          final success = await _updateProfile();
          if (success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تغییرات با موفقیت ثبت شد')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطا در ثبت تغییرات')),
            );
          }
        },
        child: const Text('ثبت تغییرات',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle, size: 32, color: Colors.white),
      onPressed: _showProfileDialog,
      tooltip: 'پروفایل',
    );
  }
}
