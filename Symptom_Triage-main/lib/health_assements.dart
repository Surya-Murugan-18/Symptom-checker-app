import 'package:flutter/material.dart';
import 'language/app_state.dart';
import 'language/app_strings.dart';

class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({Key? key}) : super(key: key);

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {

  List<Map<String, dynamic>> _getHealthRecords() {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? {};
    return [
      {
        'date': '15',
        'month': strings['month_dec'] ?? 'Dec',
        'year': '2024',
        'title': strings['fever_headache'] ?? 'Fever & Headache',
        'temp': '101°F',
        'bp': '120/80',
        'hr': null,
        'duration': '45 ${strings['consultation_suffix'] ?? 'min consultation'}',
        'timeAgo': '2 ${strings['days_ago'] ?? 'days ago'}',
      },
      {
        'date': '08',
        'month': strings['month_dec'] ?? 'Dec',
        'year': '2024',
        'title': strings['chest_pain_history'] ?? 'Chest Pain',
        'temp': null,
        'bp': '140/90',
        'hr': '95 bpm',
        'duration': '60 ${strings['consultation_suffix'] ?? 'min consultation'}',
        'timeAgo': '1 ${strings['week_ago'] ?? 'week ago'}',
      },
      {
        'date': '01',
        'month': strings['month_dec'] ?? 'Dec',
        'year': '2024',
        'title': strings['stomach_pain'] ?? 'Stomach Pain',
        'temp': '99°F',
        'bp': null,
        'hr': null,
        'duration': '30 ${strings['consultation_suffix'] ?? 'min consultation'}',
        'timeAgo': '2 ${strings['weeks_ago'] ?? 'weeks ago'}',
      },
      {
        'date': '24',
        'month': strings['month_nov'] ?? 'Nov',
        'year': '2024',
        'title': strings['cough_cold'] ?? 'Cough & Cold',
        'temp': '98.6°F',
        'bp': null,
        'hr': null,
        'duration': '25 ${strings['consultation_suffix'] ?? 'min consultation'}',
        'timeAgo': '3 ${strings['weeks_ago'] ?? 'weeks ago'}',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
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
          AppStrings.data[AppState.selectedLanguage]?['health_history_title'] ?? 'Health History',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 800 ? 800 : constraints.maxWidth;
          double horizontalPadding = constraints.maxWidth > 800 ? 40 : 16;
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  // Listen to history button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        // Handle listen to history
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          
                         
                          
                        ],
                      ),
                    ),
                  ),
                  
                  // Warning banner
                  
                  
                  // Filter buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Handle date range filter
                            },
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFF199A8E),
                            ),
                            label: Text(
                              AppStrings.data[AppState.selectedLanguage]?['date_range'] ?? 'Date Range',
                              style: const TextStyle(
                                color: Color(0xFF199A8E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF199A8E),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Handle urgency level filter
                            },
                            icon: const Icon(
                              Icons.filter_list,
                              size: 18,
                              color: Color(0xFF199A8E),
                            ),
                            label: Text(
                              AppStrings.data[AppState.selectedLanguage]?['urgency_level'] ?? 'Urgency Level',
                              style: const TextStyle(
                                color: Color(0xFF199A8E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF199A8E),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Health records list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      itemCount: _getHealthRecords().length,
                      itemBuilder: (context, index) {
                        final record = _getHealthRecords()[index];
                        return _buildHealthRecordCard(record);
                      },
                    ),
                  ),
                  
                  // Bottom action buttons
                  Container(
                    padding: EdgeInsets.all(horizontalPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle download all
                              },
                              icon: const Icon(
                                Icons.download,
                                size: 20,
                              ),
                              label: Text(
                                AppStrings.data[AppState.selectedLanguage]?['download_all'] ?? 'Download All',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF199A8E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Handle clear history
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Color(0xFFE53935),
                              ),
                              label: Text(
                                AppStrings.data[AppState.selectedLanguage]?['clear_history'] ?? 'Clear History',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE53935),
                                  width: 1.5,
                                ),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthRecordCard(Map<String, dynamic> record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date section
            Container(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    record['date'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    record['month'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    record['year'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Vitals
                  Row(
                    children: [
                      if (record['temp'] != null) ...[
                        Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${AppStrings.data[AppState.selectedLanguage]?['temp_label'] ?? 'Temp'}: ${record['temp']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (record['hr'] != null) ...[
                        Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${AppStrings.data[AppState.selectedLanguage]?['hr_label'] ?? 'HR'}: ${record['hr']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (record['bp'] != null) ...[
                        Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${AppStrings.data[AppState.selectedLanguage]?['bp_label'] ?? 'BP'}: ${record['bp']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Consultation info
                  Text(
                    '${record['duration']} • ${record['timeAgo']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Details and download buttons
           Column(
  children: [
    IconButton(
      onPressed: () {
        // Navigate to details page
      },
      icon: const Icon(
        Icons.info_outline,
        size: 30,
      ),
      color: const Color(0xFF199A8E),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    const SizedBox(height: 8),

    // OUTLINED DOWNLOAD BUTTON
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          
          color: Colors.grey.shade400,
          
          width: 1.0,
        ),
      ),
      child: IconButton(
        onPressed: () {
          // Handle download
        },
        icon: const Icon(
          Icons.download_outlined,
          size: 18,
        ),
        color: Colors.grey[600],
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    ),
  ],
),

          ],
        ),
      ),
    );
  }
}
