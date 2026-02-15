import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class PillReminder extends StatefulWidget {
  const PillReminder({Key? key}) : super(key: key);

  @override
  State<PillReminder> createState() => _PillReminderState();
}

class _PillReminderState extends State<PillReminder> {
  final Color appColor = const Color(0xFF199A8E);
  final Color titleColor = Colors.black;
  final Color backgroundColor = Colors.white;

  // Sample pill data
  final List<Map<String, dynamic>> pills = [
    {
      'name': 'Acarbose',
      'dosage': '50mg',
      'time': '9:30 AM',
      'frequency': 'Every day',
      'icon': Icons.medication,
      'backgroundColor': const Color(0xFFE8D4F1),
      'hasNotification': true,
      'isCompleted': false,
    },
    {
      'name': 'Benefix',
      'dosage': '200mg',
      'time': '10:30 AM',
      'frequency': 'Every day',
      'icon': Icons.healing,
      'backgroundColor': const Color(0xFFD4E8F1),
      'hasNotification': false,
      'isCompleted': false,
    },
    {
      'name': 'Calcium Chloride',
      'dosage': '100mg',
      'time': '1:00 PM',
      'frequency': 'Every week',
      'icon': Icons.science,
      'backgroundColor': const Color(0xFFF1D4D4),
      'hasNotification': true,
      'isCompleted': false,
    },
    {
      'name': 'Fabrazyme',
      'dosage': '400mg',
      'time': '1:30 PM',
      'frequency': 'Every week',
      'icon': Icons.medical_services,
      'backgroundColor': const Color(0xFFD4F1E8),
      'hasNotification': false,
      'isCompleted': false,
    },
    {
      'name': 'Ketoprofen',
      'dosage': '100mg',
      'time': '9:00 PM',
      'frequency': 'Every day',
      'icon': Icons.medication,
      'backgroundColor': const Color(0xFFF5F5F5),
      'hasNotification': true,
      'isCompleted': false,
    },
    {
      'name': 'Adenovirus',
      'dosage': '0-6',
      'time': '9:30 AM',
      'frequency': 'Every day',
      'icon': Icons.vaccines,
      'backgroundColor': const Color(0xFFD4E8F1),
      'hasNotification': true,
      'isCompleted': false,
    },
    {
      'name': 'Macrobid',
      'dosage': '25mg',
      'time': '2:00 PM',
      'frequency': 'Every week',
      'icon': Icons.medication,
      'backgroundColor': const Color(0xFFE8F1D4),
      'hasNotification': false,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : (isTablet ? 24.0 : 40.0),
              vertical: isMobile ? 16.0 : 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, isMobile),
                SizedBox(height: isMobile ? 24 : 32),

                // Today Section
                _buildTodaySection(isMobile),
                SizedBox(height: isMobile ? 16 : 24),

                // Pills List
                _buildPillsList(context, isMobile, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back,
            color: titleColor,
            size: isMobile ? 24 : 28,
          ),
        ),
        Text(
          strings['pill_reminder_title'] ?? 'PILL REMINDER',
          style: TextStyle(
            color: titleColor,
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: isMobile ? 24 : 28),
      ],
    );
  }

  Widget _buildTodaySection(bool isMobile) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEE, dd MMM');
    final formattedDate = dateFormatter.format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings['today_label'] ?? 'Today',
          style: TextStyle(
            color: titleColor,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          formattedDate,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isMobile ? 18 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPillsList(BuildContext context, bool isMobile, bool isTablet) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pills.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: _buildPillCard(context, pills[index], isMobile, isTablet, strings),
        );
      },
    );
  }

  Widget _buildPillCard(
    BuildContext context,
    Map<String, dynamic> pill,
    bool isMobile,
    bool isTablet,
    Map<String, String> strings,
  ) {
    String frequencyLabel = pill['frequency'];
    if (frequencyLabel == 'Every day') frequencyLabel = strings['every_day'] ?? 'Every day';
    else if (frequencyLabel == 'Every week') frequencyLabel = strings['every_week'] ?? 'Every week';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 22 : 16),
        child: Row(
          children: [
            // Pill Icon Container
            Container(
              width: isMobile ? 60 : 80,
              height: isMobile ? 60 : 80,
              decoration: BoxDecoration(
                color: pill['backgroundColor'],
                borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
              ),
              child: Icon(
                pill['icon'],
                size: isMobile ? 42 : 40,
                color: appColor,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),

            // Pill Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pill['name'],
                    style: TextStyle(
                      color: titleColor,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    pill['dosage'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: isMobile ? 4 : 6),
                      Text(
                        pill['time'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          frequencyLabel,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),

            // Right Side Controls
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pills[pills.indexOf(pill)]['hasNotification'] =
                          !pill['hasNotification'];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          pill['hasNotification']
                              ? (strings['notification_enabled'] ?? 'Notification enabled')
                              : (strings['notification_disabled'] ?? 'Notification disabled'),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(
                    pill['hasNotification'] ? Icons.notifications_active : Icons.notifications_none,
                    size: isMobile ? 30 : 24,
                    color: pill['hasNotification'] ? appColor : Colors.grey[400],
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      pills[pills.indexOf(pill)]['isCompleted'] = !pill['isCompleted'];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          pill['isCompleted']
                              ? '${pill['name']} ${strings['marked_completed'] ?? 'marked as completed'}'
                              : '${pill['name']} ${strings['marked_pending'] ?? 'marked as pending'}',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: isMobile ? 28 : 32,
                    height: isMobile ? 28 : 32,
                    decoration: BoxDecoration(
                      color: pill['isCompleted'] ? Colors.red : Colors.white,
                      border: Border.all(
                        color: pill['isCompleted'] ? Colors.red : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: pill['isCompleted']
                        ? Icon(
                            Icons.check,
                            size: isMobile ? 16 : 18,
                            color: Colors.white,
                          )
                        : null,
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
