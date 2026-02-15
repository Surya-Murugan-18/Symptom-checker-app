import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'language/app_state.dart';
import 'language/app_strings.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Color appColor = const Color(0xFF199A8E);
  bool isLoading = false;

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController locationController;
  late TextEditingController weightController;
  late TextEditingController healthProblemController;

  // Emergency Contacts List
  late List<Map<String, dynamic>> emergencyContacts;
  List<int> deletedContactIds = [];

  // Form States
  String? selectedBPLevel = "Low";
  bool hasLongTermProblem = false;
  bool takesMedicines = false;
  
  Uint8List? _previewBytes;
  String? _photoUrl;
  final ImagePicker _picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    final sess = UserSession();
    nameController = TextEditingController(text: sess.fullName);
    phoneController = TextEditingController(text: sess.contact ?? '');
    emailController = TextEditingController(text: sess.email ?? '');
    locationController = TextEditingController(text: sess.location ?? '');
    weightController = TextEditingController(text: sess.weight ?? '');
    healthProblemController = TextEditingController(text: sess.chronicIllnessDetails ?? '');

    selectedBPLevel = sess.bloodPressureLevel ?? "Low";
    hasLongTermProblem = sess.hasChronicIllness ?? false;
    takesMedicines = sess.takesRegularMedicine ?? false;
    _photoUrl = sess.photoUrl;

    if (sess.emergencyContacts != null && sess.emergencyContacts!.isNotEmpty) {
      emergencyContacts = sess.emergencyContacts!.map((c) {
        String rel = c['relationship'] ?? c['relation'] ?? 'Other';
        return {
          'id': c['id'],
          'name': TextEditingController(text: c['name'] ?? ''),
          'phone': TextEditingController(text: c['phone'] ?? ''),
          'relationship': rel,
        };
      }).toList();
    } else {
      emergencyContacts = [
        {
          'name': TextEditingController(),
          'phone': TextEditingController(),
          'relationship': null,
        },
      ];
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final sess = UserSession();
    final userId = sess.userId;

    try {
      final personalUpdate = {
        "firstName": nameController.text.split(' ').first,
        "lastName": nameController.text.contains(' ') ? nameController.text.substring(nameController.text.indexOf(' ')).trim() : '',
        "email": emailController.text,
        "contact": phoneController.text,
        "location": locationController.text,
        "weight": weightController.text,
        "bloodPressureLevel": selectedBPLevel,
        "photoUrl": _photoUrl,
      };

      final profileResponse = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${sess.token}"
        },
        body: jsonEncode(personalUpdate),
      );

      final healthUpdate = {
        "language": sess.language ?? "English",
        "hasChronicIllness": hasLongTermProblem,
        "chronicIllnessDetails": healthProblemController.text,
        "takesRegularMedicine": takesMedicines,
      };

      final healthResponse = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId/about-you"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${sess.token}"
        },
        body: jsonEncode(healthUpdate),
      );

      for (var id in deletedContactIds) {
        await http.delete(
          Uri.parse("${ApiConfig.baseUrl}/emergency/$id"),
          headers: {"Authorization": "Bearer ${sess.token}"},
        );
      }
      deletedContactIds.clear();

      for (var contact in emergencyContacts) {
        final contactData = {
          "name": contact['name'].text,
          "phone": contact['phone'].text,
          "relation": contact['relationship'] ?? 'Other',
        };

        if (contact['name'].text.isNotEmpty && contact['phone'].text.isNotEmpty) {
          if (contact['id'] != null) {
            await http.put(
              Uri.parse("${ApiConfig.baseUrl}/emergency/${contact['id']}"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${sess.token}"
              },
              body: jsonEncode(contactData),
            );
          } else {
            await http.post(
              Uri.parse("${ApiConfig.baseUrl}/users/$userId/emergency"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${sess.token}"
              },
              body: jsonEncode(contactData),
            );
          }
        }
      }

      if (profileResponse.statusCode == 200 && healthResponse.statusCode == 200) {
        sess.firstName = nameController.text.split(' ').first;
        sess.lastName = nameController.text.contains(' ') ? nameController.text.substring(nameController.text.indexOf(' ')).trim() : '';
        sess.email = emailController.text;
        sess.contact = phoneController.text;
        sess.location = locationController.text;
        sess.weight = weightController.text;
        sess.bloodPressureLevel = selectedBPLevel;
        sess.hasChronicIllness = hasLongTermProblem;
        sess.chronicIllnessDetails = healthProblemController.text;
        sess.takesRegularMedicine = takesMedicines;
        sess.photoUrl = _photoUrl;

        final empResp = await http.get(
          Uri.parse("${ApiConfig.baseUrl}/users/$userId/emergency"),
          headers: {"Authorization": "Bearer ${sess.token}"},
        );
        if (empResp.statusCode == 200) {
          final List<dynamic> contacts = jsonDecode(empResp.body);
          sess.emergencyContacts = contacts.map((c) => {
            "id": c['id'],
            "name": c['name'],
            "phone": c['phone'],
            "relationship": c['relation'],
          }).toList();
        }
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Update failed."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: appColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle, color: appColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(strings['profile_updated'] ?? 'Profile Updated', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); Navigator.pop(context, true); },
                    style: ElevatedButton.styleFrom(backgroundColor: appColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text(strings['back_to_profile'] ?? 'Back to Profile', style: const TextStyle(color: Colors.white)),
                  ),
                ),
               ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose(); phoneController.dispose(); emailController.dispose();
    locationController.dispose(); weightController.dispose(); healthProblemController.dispose();
    for (var contact in emergencyContacts) { contact['name'].dispose(); contact['phone'].dispose(); }
    super.dispose();
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      final contact = emergencyContacts.removeAt(index);
      if (contact['id'] != null) deletedContactIds.add(contact['id']);
      contact['name'].dispose(); contact['phone'].dispose();
      if (emergencyContacts.isEmpty) {
        emergencyContacts.add({'name': TextEditingController(), 'phone': TextEditingController(), 'relationship': null});
      }
    });
  }

  ImageProvider _getProfileImage() {
    if (_previewBytes != null) return MemoryImage(_previewBytes!);
    if (_photoUrl != null) {
      if (_photoUrl!.startsWith('data:image')) {
        return MemoryImage(base64Decode(_photoUrl!.split(',').last));
      } else if (_photoUrl!.startsWith('http')) {
        return NetworkImage(_photoUrl!);
      }
    }
    return const AssetImage('assets/D10.png');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(strings['edit_profile_title'] ?? 'Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(radius: 60, backgroundImage: _getProfileImage()),
                    Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: appColor, radius: 18, child: IconButton(icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white), onPressed: _pickImage))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(strings['personal_information'] ?? 'Personal Information'),
              _buildTextField(label: strings['full_name'] ?? 'Full Name', controller: nameController, icon: Icons.person),
              _buildTextField(label: strings['phone'] ?? 'Phone', controller: phoneController, icon: Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(label: strings['email'] ?? 'Email', controller: emailController, icon: Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField(label: strings['location'] ?? 'Location', controller: locationController, icon: Icons.location_on),
              _buildTextField(label: strings['weight_label'] ?? 'Weight', controller: weightController, icon: Icons.monitor_weight, keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              _buildSectionTitle(strings['health_info'] ?? 'Health Info'),
              _buildQuestionBlock(title: strings['chronic_illness_q'] ?? 'Chronic Illness?', child: Row(children: [
                Radio(value: true, groupValue: hasLongTermProblem, onChanged: (v) => setState(() => hasLongTermProblem = true)), Text(strings['yes'] ?? 'Yes'),
                Radio(value: false, groupValue: hasLongTermProblem, onChanged: (v) => setState(() => hasLongTermProblem = false)), Text(strings['no'] ?? 'No'),
              ])),
              if (hasLongTermProblem) _buildTextField(label: strings['details'] ?? 'Details', controller: healthProblemController, icon: Icons.description, maxLines: 3),
              const SizedBox(height: 32),
              _buildSectionTitle(strings['emergency_contacts_title'] ?? 'Emergency Contacts'),
              ...List.generate(emergencyContacts.length, (i) => Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text((strings['contact_num'] ?? 'Contact {value}').replaceAll('{value}', '${i+1}')), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeEmergencyContact(i))]),
                _buildTextField(label: strings['name'] ?? 'Name', controller: emergencyContacts[i]['name'], icon: Icons.person_outline),
                _buildTextField(label: strings['phone'] ?? 'Phone', controller: emergencyContacts[i]['phone'], icon: Icons.phone_android, keyboardType: TextInputType.phone),
              ])),
              TextButton(onPressed: () => setState(() => emergencyContacts.add({'name': TextEditingController(), 'phone': TextEditingController(), 'relationship': null})), child: Text(strings['add_contact'] ?? 'Add Contact')),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: isLoading ? null : _saveProfileChanges, style: ElevatedButton.styleFrom(backgroundColor: appColor, minimumSize: const Size(double.infinity, 50)), child: isLoading ? const CircularProgressIndicator() : Text(strings['save_changes'] ?? 'Save Changes', style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) { return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))); }
  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))));
  }
  Widget _buildQuestionBlock({required String title, required Widget child}) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), child]); }
}
