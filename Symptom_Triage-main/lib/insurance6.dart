import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class ClaimProcessGuide extends StatelessWidget {
  const ClaimProcessGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['claim_process_guide'] ?? 'Claim Process Guide',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
          return Center(
            child: Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 32 : 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      strings['how_to_claim'] ?? 'How to Claim',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildClaimStep(
                      icon: FontAwesomeIcons.building,
                      title: strings['visit_collect'] ?? 'Visit & Collect',
                      description: strings['visit_collect_desc'] ?? 'Inform hospital desk about insurance. Collect all original bills and reports.',
                      showLine: true,
                    ),
                    _buildClaimStep(
                      icon: FontAwesomeIcons.paperPlane,
                      title: strings['submit_documents'] ?? 'Submit Documents',
                      description: strings['submit_documents_desc'] ?? 'Submit claim form along with prescriptions, bills, and discharge summary.',
                      showLine: true,
                    ),
                    const SizedBox(height: 2),
                    _buildClaimStep(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      title: strings['processing_label'] ?? 'Processing',
                      description: strings['processing_desc_full'] ?? 'TPA/Insurer verifies the documents. Queries\n may be raised.',
                      showLine: true,
                    ),
                    _buildClaimStep(
                      icon: FontAwesomeIcons.fileInvoice,
                      title: strings['settlement_label'] ?? 'Settlement',
                      description: strings['settlement_desc_full'] ?? 'Approved amount is transferred to hospital (cashless) or you (reimbursement).',
                      showLine: false,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                       Icon(
                        FontAwesomeIcons.squareCheck,
                        color: const Color(0xFF199A8E),
                        size: 22,
                      ),

                        const SizedBox(width: 14),
                        Text(
                          strings['document_checklist'] ?? 'Document Checklist',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildChecklistItem(strings['original_prescription'] ?? 'Original Doctor\'s Prescription'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(strings['pharmacy_lab_bills'] ?? 'Pharmacy & Lab Bills (GST Paid)'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(strings['discharge_summary'] ?? 'Discharge Summary'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(strings['investigation_reports'] ?? 'Investigation Reports'),
                    const SizedBox(height: 12),
                    _buildChecklistItem(strings['kyc_documents'] ?? 'KYC Documents (Aadhar/PAN)'),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClaimStep({
    required IconData icon,
    required String title,
    required String description,
    required bool showLine,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF199A8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: const Color(0xFF199A8E),
                    size: 20,
                  ),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF199A8E).withOpacity(0.3),
                          Color(0xFF199A8E).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        const SizedBox(width: 14),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
             border: Border.all(
    color: const Color(0xFFD1D5DB), // grey outline
    width: 1,)
          ),
          child: const Icon(
            Icons.square,
            color: const Color(0xFF199A8E),
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}