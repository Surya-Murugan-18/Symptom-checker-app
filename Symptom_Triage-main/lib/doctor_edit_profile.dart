import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class DoctorEditProfile extends StatefulWidget {
  const DoctorEditProfile({Key? key}) : super(key: key);

  @override
  State<DoctorEditProfile> createState() => _DoctorEditProfileState();
}

class _DoctorEditProfileState extends State<DoctorEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final Color appColor = const Color(0xFF199A8E);
  bool isLoading = false;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController specializationController; // Maybe redundant if we use dropdown, but sticking to text for now or dropdown
  late TextEditingController consultationFeeController;

  Uint8List? _previewBytes; // For web/mobile consistent image preview
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final sess = DoctorSession();
    firstNameController = TextEditingController(text: sess.firstName ?? '');
    lastNameController = TextEditingController(text: sess.lastName ?? '');
    phoneController = TextEditingController(text: sess.phone ?? '');
    specializationController = TextEditingController(text: sess.specialization ?? '');
    consultationFeeController = TextEditingController();
    _photoUrl = sess.photoUrl;

    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    setState(() => isLoading = true);
    final sess = DoctorSession();
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/doctors/${sess.doctorId}"),
        headers: {"Authorization": "Bearer ${sess.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            firstNameController.text = data['firstName'] ?? '';
            lastNameController.text = data['lastName'] ?? '';
            phoneController.text = data['phone'] ?? '';
            specializationController.text = data['specialization'] ?? '';
            consultationFeeController.text = data['consultationFee']?.toString() ?? '';
            _photoUrl = data['photoUrl'];
            // Session update just in case
            sess.firstName = data['firstName'];
            sess.lastName = data['lastName'];
            sess.specialization = data['specialization'];
            sess.photoUrl = data['photoUrl'];
            sess.phone = data['phone'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching doctor details: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _previewBytes = bytes;
        _photoUrl = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final sess = DoctorSession();

    try {
      final body = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "phone": phoneController.text.trim(),
        "specialization": specializationController.text.trim(),
        "consultationFee": double.tryParse(consultationFeeController.text.trim()),
        "photoUrl": _photoUrl,
      };

      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/doctors/${sess.doctorId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${sess.token}"
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sess.firstName = data['firstName'];
        sess.lastName = data['lastName'];
        sess.specialization = data['specialization'];
        sess.photoUrl = data['photoUrl'];
        sess.phone = data['phone'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Update failed: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    consultationFeeController.dispose();
    super.dispose();
  }

  ImageProvider _getProfileImage() {
    if (_previewBytes != null) return MemoryImage(_previewBytes!);
    if (_photoUrl != null) {
      if (_photoUrl!.contains(',')) {
        try {
          return MemoryImage(base64Decode(_photoUrl!.split(',').last));
        } catch (e) {
          return const AssetImage('assets/D10.png');
        }
      } else if (_photoUrl!.startsWith('http')) {
        return NetworkImage(_photoUrl!);
      } else if (_photoUrl!.startsWith('assets/')) {
        return AssetImage(_photoUrl!);
      }
    }
    return const AssetImage('assets/D10.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _getProfileImage(),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: appColor,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'First Name',
                      controller: firstNameController,
                      icon: Icons.person,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Last Name',
                      controller: lastNameController,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                label: 'Phone',
                controller: phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                label: 'Specialization',
                controller: specializationController,
                icon: Icons.medical_services,
              ),
              _buildTextField(
                label: 'Consultation Fee',
                controller: consultationFeeController,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfileChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: appColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
