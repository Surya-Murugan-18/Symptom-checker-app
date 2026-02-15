import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

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

  final List<String> relationships = [
    'Father',
    'Mother',
    'Sister',
    'Brother',
    'Spouse',
    'Friend',
    'Other',
  ];

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

    // Initialize emergency contacts from session with robust key handling
    if (sess.emergencyContacts != null && sess.emergencyContacts!.isNotEmpty) {
      emergencyContacts = sess.emergencyContacts!.map((c) {
        // Handle variations in key names (relation vs relationship)
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
      // 1. Update Personal Info
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

      // 2. Update Health Info (About You)
      final healthUpdate = {
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

      // 3. Update Emergency Contacts
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
        // Complete data sync back to session
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

        // Refresh emergency contacts strictly from source of truth (API)
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
        String errorMsg = "Update failed.";
        if (profileResponse.statusCode != 200) {
          errorMsg += "\nProfile Error (${profileResponse.statusCode}): ${profileResponse.body}";
          debugPrint("Profile Update Failed: ${profileResponse.body}");
        }
        if (healthResponse.statusCode != 200) {
          errorMsg += "\nHealth Error (${healthResponse.statusCode}): ${healthResponse.body}";
          debugPrint("Health Update Failed: ${healthResponse.body}");
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Exception: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: appColor, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Updated',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, true); // Return to profile page with refresh signal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Back to Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    locationController.dispose();
    weightController.dispose();
    healthProblemController.dispose();
    for (var contact in emergencyContacts) {
      contact['name'].dispose();
      contact['phone'].dispose();
    }
    super.dispose();
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      final contact = emergencyContacts.removeAt(index);
      if (contact['id'] != null) {
        deletedContactIds.add(contact['id'] is int ? contact['id'] : int.parse(contact['id'].toString()));
      }
      contact['name'].dispose();
      contact['phone'].dispose();
      // Ensure at least one form remains if all were deleted
      if (emergencyContacts.isEmpty) {
        emergencyContacts.add({
          'name': TextEditingController(),
          'phone': TextEditingController(),
          'relationship': null,
        });
      }
    });
  }

  ImageProvider _getProfileImage() {
    if (_previewBytes != null) {
      return MemoryImage(_previewBytes!);
    }
    if (_photoUrl != null) {
      if (_photoUrl!.startsWith('data:image')) {
        try {
          return MemoryImage(base64Decode(_photoUrl!.split(',').last));
        } catch (e) {
          debugPrint("Base64 decode error: $e");
        }
      } else if (_photoUrl!.startsWith('http')) {
        return NetworkImage(_photoUrl!);
      }
    }
    return const AssetImage('assets/D10.png');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final horizontalPadding = isMobile ? 16.0 : 40.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 800 ? 800 : constraints.maxWidth;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image Section with Scalability Fix (supports both base64 and URLs)
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColor, width: 3),
                                    image: DecorationImage(
                                      image: _getProfileImage(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appColor,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _pickImage,
                                        borderRadius: BorderRadius.circular(50),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Change Picture', style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Full Name', controller: nameController, icon: FontAwesomeIcons.user, validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Phone Number', controller: phoneController, icon: FontAwesomeIcons.phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Email ID', controller: emailController, icon: FontAwesomeIcons.envelope, keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : 'Invalid Email'),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Location', controller: locationController, icon: FontAwesomeIcons.locationArrow),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Weight (lbs)', controller: weightController, icon: FontAwesomeIcons.weight, keyboardType: TextInputType.number),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Health Information'),
                      const SizedBox(height: 16),
                      _buildQuestionBlock(
                        title: 'Do you have any long-term health problem?',
                        child: Row(
                          children: [
                            _buildRadioOption(label: 'Yes', value: true, groupValue: hasLongTermProblem, onChanged: (v) => setState(() => hasLongTermProblem = true)),
                            const SizedBox(width: 24),
                            _buildRadioOption(label: 'No', value: false, groupValue: hasLongTermProblem, onChanged: (v) => setState(() => hasLongTermProblem = false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (hasLongTermProblem) ...[
                        _buildTextField(label: 'Describe Problem', controller: healthProblemController, icon: Icons.history, maxLines: 3),
                        const SizedBox(height: 16),
                      ],
                      _buildQuestionBlock(
                        title: 'Do you take any medications?',
                        child: Row(
                          children: [
                            _buildRadioOption(label: 'Yes', value: true, groupValue: takesMedicines, onChanged: (v) => setState(() => takesMedicines = true)),
                            const SizedBox(width: 24),
                            _buildRadioOption(label: 'No', value: false, groupValue: takesMedicines, onChanged: (v) => setState(() => takesMedicines = false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionBlock(
                        title: 'Blood Pressure Level:',
                        child: Wrap(
                          spacing: 16,
                          children: [
                            _buildRadioOption(label: 'Low', value: 'Low', groupValue: selectedBPLevel, onChanged: (v) => setState(() => selectedBPLevel = v)),
                            _buildRadioOption(label: 'Medium', value: 'Medium', groupValue: selectedBPLevel, onChanged: (v) => setState(() => selectedBPLevel = v)),
                            _buildRadioOption(label: 'High', value: 'High', groupValue: selectedBPLevel, onChanged: (v) => setState(() => selectedBPLevel = v)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Emergency Contact'),
                      const SizedBox(height: 16),
                      ..._buildEmergencyContactForms(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: appColor, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () => setState(() => emergencyContacts.add({'name': TextEditingController(), 'phone': TextEditingController(), 'relationship': null})),
                          child: Text('Add Another Contact', style: TextStyle(color: appColor, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(side: BorderSide(color: appColor, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text('Cancel', style: TextStyle(color: appColor, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _saveProfileChanges,
                              style: ElevatedButton.styleFrom(backgroundColor: appColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700));
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.shade50, blurRadius: 6)]),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: appColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: appColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildQuestionBlock({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(color: appColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: appColor.withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _buildRadioOption<T>({required String label, required T value, required T groupValue, required ValueChanged<T?> onChanged}) {
    bool selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? appColor : Colors.grey.shade400, width: selected ? 6 : 2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  List<Widget> _buildEmergencyContactForms() {
    return List.generate(emergencyContacts.length, (i) => Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.shade50, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Contact ${i + 1}', style: TextStyle(color: appColor, fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeEmergencyContact(i)),
        ]),
        const SizedBox(height: 12),
        _buildTextField(label: 'Name', controller: emergencyContacts[i]['name'], icon: FontAwesomeIcons.userTag),
        const SizedBox(height: 12),
        _buildTextField(label: 'Phone Number', controller: emergencyContacts[i]['phone'], icon: FontAwesomeIcons.phoneAlt, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: emergencyContacts[i]['relationship'],
          decoration: const InputDecoration(labelText: 'Relationship', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
          items: relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => emergencyContacts[i]['relationship'] = v),
        ),
      ]),
    ));
  }
}
