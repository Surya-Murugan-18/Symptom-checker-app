import 'package:flutter/material.dart';
import 'package:symtom_checker/successfull.dart';
import 'package:symtom_checker/models/registration_data.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 🌐 Language imports
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class AboutYouPage extends StatefulWidget {
  final RegistrationData registrationData;
  const AboutYouPage({Key? key, required this.registrationData}) : super(key: key);

  @override
  State<AboutYouPage> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends State<AboutYouPage> {
  bool hasLongTermProblem = false;
  bool takesMedicines = false;
  String healthProblem = '';
  bool agreeTerms = false;
  bool allowUse = false;
  String bpLevel = "Low"; // default
  bool _isLoading = false;

  final Color accent = const Color(0xFF15B09A);
  final Color lightAccent = const Color(0xFFF1FFFC);
  final Color checkboxColor = const Color(0xFF17A08B);

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);

    // Update data
    widget.registrationData.hasChronicIllness = hasLongTermProblem;
    widget.registrationData.chronicIllnessDetails = healthProblem;
    widget.registrationData.takesRegularMedicine = takesMedicines;
    widget.registrationData.bloodPressureLevel = bpLevel;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.registrationData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SuccessfulPage(),
            ),
          );
        }
      } else {
        _showError('Registration failed: ${response.body}');
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(
          strings['signup']!,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.local_hospital, color: Color(0xFF15B09A)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Center(
                child: Text(
                  strings['about']!,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 26),

              // First question
              _questionBlock(
                title: strings['q1']!,
                child: Row(
                  children: [
                    _radOption(strings['yes']!, hasLongTermProblem, () {
                      setState(() => hasLongTermProblem = true);
                    }),
                    const SizedBox(width: 18),
                    _radOption(strings['no']!, !hasLongTermProblem, () {
                      setState(() => hasLongTermProblem = false);
                    }),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // If yes input box
              if (hasLongTermProblem) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                  child: Text(
                    strings['if_yes']!,
                    style: const TextStyle(
                      color: Color(0xFF17A08B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade50,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => healthProblem = v),
                    decoration: InputDecoration(
                      hintText: strings['mention_problem']!,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14.0),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
              ],

              // Second question
              _questionBlock(
                title: strings['q3']!,
                child: Row(
                  children: [
                    _radOption(strings['yes']!, takesMedicines, () {
                      setState(() => takesMedicines = true);
                    }),
                    const SizedBox(width: 18),
                    _radOption(strings['no']!, !takesMedicines, () {
                      setState(() => takesMedicines = false);
                    }),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 22),



           _questionBlock(
  title: strings['q2']!, // Do you have blood pressure?
  child: Row(
    children: [
      _radOption(strings['low']!, bpLevel == "Low", () {
        setState(() => bpLevel = "Low");
      }),
      const SizedBox(width: 18),
      _radOption(strings['Medium']!, bpLevel == "Medium", () {
        setState(() => bpLevel = "Medium");
      }),
      const SizedBox(width: 18),
      _radOption(strings['High']!, bpLevel == "High", () {
        setState(() => bpLevel = "High");
      }),
      const Spacer(),
    ],
  ),
),


              const SizedBox(height: 22),

              

              // Checkboxes
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreeTerms,
                    onChanged: (v) => setState(() => agreeTerms = v ?? false),
                    activeColor: checkboxColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => agreeTerms = !agreeTerms),
                      child: Text(
                        strings['t1']!,
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: allowUse,
                    onChanged: (v) => setState(() => allowUse = v ?? false),
                    activeColor: checkboxColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => allowUse = !allowUse),
                      child:Text(
                        strings['t2']!,
                        style:const TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Complete button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (agreeTerms && allowUse)
                      ? () => _registerUser()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          strings['complete']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // bottom small indicator bar
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
      ),
    );
  }

  Widget _questionBlock({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17A08B),
            fontSize: 18,
            height: 2.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _radOption(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? accent : Colors.grey.shade400,
                width: selected ? 6 : 2,
              ),
              color: Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _speakerIcon() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: lightAccent, shape: BoxShape.circle),
        child: Center(child: Icon(Icons.volume_up, color: accent)),
      ),
    );
  }
}
