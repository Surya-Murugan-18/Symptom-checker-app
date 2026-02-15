import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/medication%202.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class MedicationHistoryPage extends StatefulWidget {
  const MedicationHistoryPage({Key? key}) : super(key: key);

  @override
  State<MedicationHistoryPage> createState() => _MedicationHistoryPageState();
}

class _MedicationHistoryPageState extends State<MedicationHistoryPage> {
  List<Medication> medicationHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId/medications/history"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          medicationHistory = data.map((json) => Medication.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: EdgeInsets.only(left: isMobile ? 16 : 24),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFF199A8E),
                size: isMobile ? 24 : 28,
              ),
            ),
          ),
        ),
        title: Text(
          strings['history'] ?? 'History',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : medicationHistory.isEmpty
              ? Center(child: Text(strings['no_history'] ?? "No history available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicationHistory.length,
                          itemBuilder: (context, index) {
                            return MedicationHistoryCard(
                              record: medicationHistory[index],
                              isMobile: isMobile,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            strings['history_tracking_only'] ?? 'This history is for personal tracking only.',
                            style: TextStyle(
                              color: const Color(0xFFB0B0B0),
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class MedicationHistoryCard extends StatelessWidget {
  final Medication record;
  final bool isMobile;

  const MedicationHistoryCard({
    Key? key,
    required this.record,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 0,
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5),
              ),
              child: const Center(
                child: Icon(
                  Icons.history,
                  color: Color(0xFF199A8E),
                  size: 24,
                ),
              ),
            ),
            // Medication Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.dosage} • ${record.timeSlots}',
                    style: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                strings['history']?.toUpperCase() ?? 'HISTORY',
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
