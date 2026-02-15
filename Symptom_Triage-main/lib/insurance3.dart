import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class InsuranceCoverageScreen extends StatelessWidget {
  const InsuranceCoverageScreen({super.key});

  static const Color kPrimary = Color(0xFF199A8E);
  static const Color kPositive = Color(0xFF199A8E);
  static const Color kNegative = Color(0xFFE24242);
  static const Color kLightBg = Color(0xFFF3F4F6);
  static const Color kTitle = Colors.black;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;
    final maxContentWidth = 450.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          strings['coverage_details'] ?? 'Coverage Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? maxContentWidth : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RecommendedCard(),
                  const SizedBox(height: 20),
                  _SectionHeader(title: strings['commonly_covered'] ?? 'Commonly Covered', color: kPositive),
                  const SizedBox(height: 12),
                  _BulletTile(
                    text: strings['doctor_consult_fees'] ?? 'Doctor consultation fees',
                    icon: Icons.check_circle,
                    iconColor: kPositive,
                  ),
                  const SizedBox(height: 10),
                  _BulletTile(
                    text: strings['prescribed_tests'] ?? 'Prescribed diagnostic tests',
                    icon: Icons.check_circle,
                    iconColor: kPositive,
                  ),
                  const SizedBox(height: 10),
                  _BulletTile(
                    text: strings['minor_procedures'] ?? 'Minor procedures (if applicable)',
                    icon: Icons.check_circle,
                    iconColor: kPositive,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: strings['not_covered'] ?? 'May Not Be Covered', color: kNegative),
                  const SizedBox(height: 12),
                  _BulletTile(
                    text: strings['otc_medicines'] ?? 'Over-the-counter (OTC) medicines',
                    icon: Icons.cancel,
                    iconColor: kNegative,
                  ),
                  const SizedBox(height: 10),
                  _BulletTile(
                    text: strings['non_medical_expenses'] ?? 'Non-medical expenses (registration, etc.)',
                    icon: Icons.cancel,
                    iconColor: kNegative,
                  ),
                  const SizedBox(height: 10),
                  _BulletTile(
                    text: strings['vitamins_supplements'] ?? 'Vitamins and supplements',
                    icon: Icons.cancel,
                    iconColor: kNegative,
                  ),
                  const SizedBox(height: 32),
                  _PrimaryButton(
                    label: strings['back_to_overview'] ?? 'Back to Overview',
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6F3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.stethoscope,
                color: Color(0xFF199A8E),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings['recommended_care_label'] ?? 'RECOMMENDED CARE',
                  style: const TextStyle(
                    color: Color(0xFF199A8E),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings['clinic_visit_gp'] ?? 'Clinic Visit – General Physician',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BulletTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  const _BulletTile({
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isPositive
            ? const Color.fromARGB(255, 251, 252, 255)
            : const Color.fromARGB(255, 251, 252, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1C1C1C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isPositive => iconColor.value == InsuranceCoverageScreen.kLightBg;
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: InsuranceCoverageScreen.kPrimary,
          side: const BorderSide(
            color: InsuranceCoverageScreen.kPrimary,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
