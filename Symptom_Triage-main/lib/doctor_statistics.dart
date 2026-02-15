import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:symtom_checker/doctor_consult.dart';
import 'package:symtom_checker/doctor_dashboard.dart';
import 'package:symtom_checker/doctordetail.dart';
import 'package:symtom_checker/doctordocuments.dart';
import 'package:symtom_checker/doctorsignin.dart';

class DoctorStatistics extends StatefulWidget {
  const DoctorStatistics({Key? key}) : super(key: key);

  @override
  State<DoctorStatistics> createState() => _DoctorStatisticsState();
}

class _DoctorStatisticsState extends State<DoctorStatistics> {
  int _selectedIndex = 3; // Stats tab
  String _trendFilter = 'Daily';
  final Color _primaryColor = const Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Row(
                children: [
                  // Back Arrow
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Center Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Right spacer to balance center alignment
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Divider(color: Colors.grey[300], height: 1, thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Stats Cards Section
                      _buildStatsCardsSection(isDesktop),

                      const SizedBox(height: 32),

                      // Appointment Trends Section
                      _buildAppointmentTrendsSection(isDesktop),

                      const SizedBox(height: 32),

                      // Patient Age Distribution Section
                      _buildPatientAgeDistributionSection(isDesktop),

                      const SizedBox(height: 32),

                      // Patient Condition Categories Section
                      _buildPatientConditionCategoriesSection(isDesktop),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatsCardsSection(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 3 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isDesktop ? 20 : 16,
      mainAxisSpacing: isDesktop ? 20 : 16,
      childAspectRatio: isDesktop ? 1.3 : 0.9,
      children: [
        _buildStatCard('₹45,000', 'Total Earnings', FontAwesomeIcons.indianRupeeSign, const Color(0xFF4CAF50), isDesktop),
        _buildStatCard('156', 'Total Bookings', FontAwesomeIcons.calendar, const Color(0xFF2196F3), isDesktop),
        _buildStatCard('142', 'Completed', FontAwesomeIcons.circleCheck, _primaryColor, isDesktop),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color iconColor,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 60 : 50,
            height: isDesktop ? 60 : 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: isDesktop ? 28 : 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTrendsSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Appointment Trends',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTrendButton('Daily', isDesktop),
                  _buildTrendButton('Weekly', isDesktop),
                  _buildTrendButton('Monthly', isDesktop),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildBarChart(isDesktop),
      ],
    );
  }

  Widget _buildTrendButton(String label, bool isDesktop) {
    final isSelected = _trendFilter == label;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _trendFilter = label;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? _primaryColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDesktop) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.6, 0.45, 0.75, 0.5, 0.85, 0.55, 0.9];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(days.length, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isDesktop ? 35 : 28,
                height: (isDesktop ? 150 : 120) * heights[index],
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                days[index],
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPatientAgeDistributionSection(bool isDesktop) {
    final ageGroups = [
      {'range': '18-25', 'percentage': 15, 'count': '23'},
      {'range': '26-35', 'percentage': 35, 'count': '24'},
      {'range': '36-45', 'percentage': 25, 'count': '39'},
      {'range': '46-55', 'percentage': 15, 'count': '39'},
      {'range': '55+', 'percentage': 10, 'count': '18'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Age Distribution',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            children: List.generate(ageGroups.length, (index) {
              final group = ageGroups[index];
              final percentage = group['percentage'] as int;
              final count = group['count'] as String;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < ageGroups.length - 1 ? 20 : 0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: isDesktop ? 64 : 56,
                      child: Text(
                        group['range'] as String,
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barHeight = isDesktop ? 20.0 : 20.0;
                          final maxWidth = constraints.maxWidth;
                          final minFill = isDesktop ? 34.0 : 30.0;
                          final fill = (percentage / 100) * maxWidth;
                          var filledWidth = fill < minFill ? minFill : fill;
                          if (filledWidth > maxWidth) {
                            filledWidth = maxWidth;
                          }

                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Container(
                                width: filledWidth,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      count,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 12 : 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: isDesktop ? 44 : 40,
                      child: Text(
                        '${percentage}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientConditionCategoriesSection(bool isDesktop) {
    final conditions = [
      {'label': 'Stable', 'percentage': 65, 'color': const Color(0xFF4CAF50)},
      {'label': 'Good', 'percentage': 25, 'color': const  Color(0xFF199A8E)},
      {'label': 'Critical', 'percentage': 10, 'color': const Color(0xFFE91E63)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Condition Categories',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[200]!, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(conditions.length, (index) {
              final condition = conditions[index];
              final percentage = condition['percentage'] as int;
              final color = condition['color'] as Color;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < conditions.length - 1 ? 20 : 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            condition['label'] as String,
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: isDesktop ? 14 : 14,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${percentage}%',
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
          _buildNavItem(FontAwesomeIcons.envelope, 'Messages', 1),
          _buildNavItem(LucideIcons.messageSquare, 'Consults', 2),
          _buildNavItem(FontAwesomeIcons.bell, 'Notifications', 3),
          _buildNavItem(FontAwesomeIcons.user, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboard()),
          );
          break;

        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDetailPage()),
          );
          break;

        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorConsult()),
          );
          break;

        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DoctorSignIn()),
          );
          break;

        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDocuments()),
          );
          break;
      }
    },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 28,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          Icon(
            icon,
            color: isSelected ? _primaryColor : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
