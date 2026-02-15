
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';

class MedfriendPage extends StatefulWidget {
  const MedfriendPage({Key? key}) : super(key: key);

  @override
  State<MedfriendPage> createState() => _MedfriendPageState();
}

class _MedfriendPageState extends State<MedfriendPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedfriendInfo();
  }

  Future<void> _fetchMedfriendInfo() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nameController.text = data['medfriendName'] ?? '';
            _emailController.text = data['medfriendEmail'] ?? '';
            _contactController.text = data['medfriendContact'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        debugPrint("Failed to fetch user info: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching user info: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMedfriend() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId"),
        headers: {
          "Authorization": "Bearer ${UserSession().token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "medfriendName": _nameController.text.trim(),
          "medfriendEmail": _emailController.text.trim(),
          "medfriendContact": _contactController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Medfriend Updated Successfully!"),
              backgroundColor: Color(0xFF199A8E),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update Medfriend."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving medfriend: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text("My Medfriend"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF199A8E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanation Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1), // Light teal back
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.userNurse, color: Color(0xFF199A8E), size: 30),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Designate a Medfriend to help you stay on track. They can receive alerts if you miss doses.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF004D40),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Medfriend Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    hint: "alerts@example.com",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    hint: "+1 234 567 8900",
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveMedfriend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF199A8E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save Medfriend",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
