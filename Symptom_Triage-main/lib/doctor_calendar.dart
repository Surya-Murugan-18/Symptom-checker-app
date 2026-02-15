import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorCalendar extends StatefulWidget {
  const DoctorCalendar({Key? key}) : super(key: key);

  @override
  State<DoctorCalendar> createState() => _DoctorCalendarState();
}

class _DoctorCalendarState extends State<DoctorCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String _selectedFilter = 'Today';
  int _selectedIndex = 0;

  // Sample appointments data
  final List<Map<String, dynamic>> _appointments = [
    {
      'name': 'Sarah Johnson',
      'initials': 'SJ',
      'time': '10:30 AM',
      'category': 'General',
      'status': 'Upcoming',
      'date': DateTime(2024, 1, 15),
    },
    {
      'name': 'Raj Patel',
      'initials': 'RP',
      'time': '11:30 AM',
      'category': 'Cardiology',
      'status': 'Upcoming',
      'date': DateTime(2024, 1, 15),
    },
  ];

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = lastDay.day;

    List<DateTime> days = [];
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(date.year, date.month, i));
    }
    return days;
  }

  int _getFirstDayOfWeekOffset(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

  List<Map<String, dynamic>> _getFilteredAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return _appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment['date'].year,
        appointment['date'].month,
        appointment['date'].day,
      );

      if (_selectedFilter == 'Today') {
        return appointmentDate.isAtSameMomentAs(selectedDay);
      } else if (_selectedFilter == 'Upcoming') {
        return appointmentDate.isAfter(today) ||
            appointmentDate.isAtSameMomentAs(today);
      } else if (_selectedFilter == 'Completed') {
        return appointmentDate.isBefore(today);
      }
      return true;
    }).toList();
  }

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
                  // 🔹 Back Arrow (Left)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // 🔹 Center Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Right spacer to balance center alignment
                  const SizedBox(width: 48), // same width as IconButton
                ],
              ),
            ),

            Divider(color: Colors.grey[300], height: 16, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Month/Year Navigation
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chevron_left,
                                      color: Colors.black,
                                    ),
                                    onPressed: _previousMonth,
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMMM yyyy',
                                    ).format(_focusedDate),
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black,
                                    ),
                                    onPressed: _nextMonth,
                                  ),
                                ],
                              ),
                            ),

                            // Weekday Headers
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children:
                                    [
                                          'Sun',
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                        ]
                                        .map(
                                          (day) => Expanded(
                                            child: Center(
                                              child: Text(
                                                day,
                                                style: TextStyle(
                                                  fontSize: isDesktop ? 14 : 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),

                            // Calendar Grid
                            _buildCalendarGrid(isDesktop),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        height: 16,
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),

                      // Filter Buttons
                      Row(
                        children: [
                          _buildFilterButton('Today', isDesktop),
                          const SizedBox(width: 12),
                          _buildFilterButton('Upcoming', isDesktop),
                          const SizedBox(width: 12),
                          _buildFilterButton('Completed', isDesktop),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Appointments Section
                      Text(
                        '${DateFormat('MMMM d').format(_selectedDate)} Appointments',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Appointments List
                      _buildAppointmentsList(isDesktop),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDesktop),
    );
  }

  Widget _buildCalendarGrid(bool isDesktop) {
    final daysInMonth = _getDaysInMonth(_focusedDate);
    final offset = _getFirstDayOfWeekOffset(_focusedDate);
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth.length + offset,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox();
        }

        final date = daysInMonth[index - offset];
        final isSelected =
            date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final isToday =
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF199A8E)
                  : isToday
                  ? const Color(0xFF199A8E).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? const Color(0xFF199A8E)
                        : Colors.black,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (_hasAppointments(date))
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF199A8E),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasAppointments(DateTime date) {
    return _appointments.any((appointment) {
      final appointmentDate = appointment['date'] as DateTime;
      return appointmentDate.year == date.year &&
          appointmentDate.month == date.month &&
          appointmentDate.day == date.day;
    });
  }

  Widget _buildFilterButton(String label, bool isDesktop) {
    final isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 14 : 12,
            horizontal: isDesktop ? 20 : 16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF199A8E) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(bool isDesktop) {
    final filteredAppointments = _getFilteredAppointments();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No appointments found',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return _buildAppointmentCard(appointment, isDesktop);
      },
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    bool isDesktop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isDesktop ? 50 : 45,
            height: isDesktop ? 50 : 45,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                appointment['initials'],
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Appointment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['name'],
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isDesktop ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment['time'],
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment['category'],
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appointment['status'],
              style: TextStyle(
                fontSize: isDesktop ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF199A8E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF199A8E),
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: isDesktop ? 13 : 13,
        unselectedFontSize: isDesktop ? 13 : 13,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          _navItem(FontAwesomeIcons.house, 'Home'),
          _navItem(FontAwesomeIcons.envelope, 'Messages'),
          _navItem(FontAwesomeIcons.message, 'Consults'),
          _navItem(FontAwesomeIcons.bell, 'Notifications'),
          _navItem(FontAwesomeIcons.user, 'Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon, size: 28, color: Colors.grey.shade400),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 4,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(icon, size: 26, color: const Color(0xFF199A8E)),
        ],
      ),
    );
  }
}
