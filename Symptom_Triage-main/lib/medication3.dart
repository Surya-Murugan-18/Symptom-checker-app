import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/medication4.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

// Shared color constants
const Color kPrimary = Color(0xFF199A8E);
const Color kTextPrimary = Colors.black;
const Color kFieldBorder = Color(0xFFE1E5E8);
const Color kPlaceholder = Color(0xFF9BA3AA);
const Color kCardBg = Color(0xFFE7F5F2);

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({Key? key}) : super(key: key);

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();

  String _medicineType = 'Tablet';
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameCtrl.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          strings['add_medicine'] ?? 'Add Medicine',
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth < 560 ? constraints.maxWidth : 520;
          final double horizontalPadding = constraints.maxWidth < 560 ? 20 : 24;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(strings['medicine_name'] ?? 'Medicine Name'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _nameCtrl,
                      hint: 'e.g., Metformin',
                    ),
                    const SizedBox(height: 20),
                    _Label(strings['medicine_type'] ?? 'Medicine Type'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _TypeButton(
                          label: strings['tablet'] ?? 'Tablet',
                          icon: FontAwesomeIcons.pills,
                          selected: _medicineType == 'Tablet',
                          onTap: () => _setType('Tablet'),
                        ),
                        const SizedBox(width: 12),
                        _TypeButton(
                          label: strings['syrup'] ?? 'Syrup',
                          icon: FontAwesomeIcons.bottleDroplet,
                          selected: _medicineType == 'Syrup',
                          onTap: () => _setType('Syrup'),
                        ),
                        const SizedBox(width: 12),
                        _TypeButton(
                          label: strings['injection'] ?? 'Injection',
                          icon: FontAwesomeIcons.syringe,
                          selected: _medicineType == 'Injection',
                          onTap: () => _setType('Injection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Label(strings['dosage_optional'] ?? 'Dosage (Optional)'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _doseCtrl,
                      hint: 'e.g., 500mg or 1 tablet',
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid ? kPrimary : const Color(0xFFD0D0D0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isFormValid
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicationScheduleScreen(
                                      medicineName: _nameCtrl.text.trim(),
                                      medicineType: _medicineType,
                                      dosage: _doseCtrl.text.trim(),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          strings['next'] ?? 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _setType(String value) {
    setState(() => _medicineType = value);
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _TextField({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: kPrimary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: kPlaceholder,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
      style: const TextStyle(
        color: kTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? kPrimary : kFieldBorder;
    final Color bgColor = selected ? const Color(0xFFE6F3F0) : Colors.white;
    final Color textColor = selected ? kPrimary : const Color(0xFF6F7780);
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: textColor),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}