import 'package:flutter/material.dart';
import 'package:symtom_checker/about_you_page.dart';
import 'package:flutter/services.dart';

// 🌐 Language imports
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/models/registration_data.dart';

class EmergencyContactPage extends StatefulWidget {
  final RegistrationData registrationData;
  const EmergencyContactPage({Key? key, required this.registrationData}) : super(key: key);

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _contacts = [
    {
      'name': TextEditingController(),
      'phone': TextEditingController(),
      'relationship': null,
    },
  ];

  final Color primary = const Color(
    0xFF0FA388,
  ); // teal-like color used across the UI

  @override
  void dispose() {
    for (var contact in _contacts) {
      contact['name'].dispose();
      contact['phone'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          strings['signup']!,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo.png',
              width: 40,
              height: 40,
              // Provide your logo at assets/logo.png or replace with an Icon
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.local_hospital, color: Colors.teal),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  strings['emergency_hint']!,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display all contacts dynamically
                    ..._buildContactForms(),

                    const SizedBox(height: 30),

                    // Add another contact (outlined)
                    SizedBox(
                      width: double.infinity, // 🔥 makes it full width
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _contacts.add({
                              'name': TextEditingController(),
                              'phone': TextEditingController(),
                              'relationship': null,
                            });
                          });
                        },
                        child: Text(
                          strings['add_another_contact']!,
                          style: TextStyle(
                            color: primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Next button (filled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Collect contacts
                            widget.registrationData.emergencyContacts = _contacts.map((c) {
                              return {
                                'name': c['name'].text.trim(),
                                'phoneNumber': c['phone'].text.trim(),
                                'relationship': c['relationship'],
                              };
                            }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AboutYouPage(registrationData: widget.registrationData),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            150,
                            136,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          strings['next']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // optional bottom spacing or the little drag indicator shown in the screenshot
                    Center(
                      child: Container(
                        width: 120,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters, // ✅ ADD THIS
      validator:
          customValidator ??
          (v) => (v == null || v.trim().isEmpty) ? strings['required']! : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _roundedDropdown(int contactIndex) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: _contacts[contactIndex]['relationship'],
        isDense: false,
        dropdownColor: Colors.white,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(
          strings['select']!,
          style: const TextStyle(color: Colors.grey),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        items: [
          DropdownMenuItem(value: 'parent', child: Text(strings['parent']!)),
          DropdownMenuItem(value: 'spouse', child: Text(strings['spouse']!)),
          DropdownMenuItem(value: 'sibling', child: Text(strings['sibling']!)),
          DropdownMenuItem(value: 'friend', child: Text(strings['friend']!)),
          DropdownMenuItem(value: 'other', child: Text(strings['other']!)),
        ],
        onChanged: (v) =>
            setState(() => _contacts[contactIndex]['relationship'] = v),
        validator: (v) =>
            (v == null || v.isEmpty) ? strings['required']! : null,
      ),
    );
  }

  List<Widget> _buildContactForms() {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    List<Widget> forms = [];

    for (int i = 0; i < _contacts.length; i++) {
      forms.addAll([
        // Contact header
        if (i > 0)
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Text(
              'Contact ${i + 1}',
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(height: 0),

        // Name label
        Text(
          strings['name']!,
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _roundedField(
          controller: _contacts[i]['name'],
          hint: strings['name_hint']!,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[\p{L}\s]', unicode: true),
            ),
          ],
          customValidator: (v) {
            if (v == null || v.trim().isEmpty) {
              return strings['required']!;
            }
            return null;
          },
        ),

        const SizedBox(height: 18),

        // Relationship
        Text(
          strings['relationship']!,
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _roundedDropdown(i),

        const SizedBox(height: 18),

        // Phone label
        Text(
          strings['emergency_hint']!,
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _roundedField(
          controller: _contacts[i]['phone'],
          hint: strings['phone_hint_emergency']!,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          customValidator: (v) {
  if (v == null || v.trim().isEmpty) {
    return strings['required']!;
  }
  if (v.length != 10) {
    return strings['phone_invalid']!;
  }
  return null;
},

        ),
      ]);
    }

    return forms;
  }
}

/*
Usage:
- Add this file to your project and import it where needed.
- Example: Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyContactPage()));
- Replace `assets/logo.png` with your actual logo path or adjust the AppBar action.
*/
