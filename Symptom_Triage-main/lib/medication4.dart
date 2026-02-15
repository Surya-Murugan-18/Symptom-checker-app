import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/medication5.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';


class MedicationScheduleScreen extends StatefulWidget {
  final String medicineName;
  final String medicineType;
  final String dosage;

  const MedicationScheduleScreen({
    Key? key,
    this.medicineName = '',
    this.medicineType = 'Tablet',
    this.dosage = '',
  }) : super(key: key);

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  String selectedReminderTime = 'morning';
  String selectedFrequency = 'daily';
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime selectedDate = DateTime.now();
  bool repeatUntilStopped = true;
  
  // Weekly selection: index 0 is Monday, index 6 is Sunday
  List<bool> selectedDays = List.generate(7, (index) => true);
  final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> fullDayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Pill inventory
  final TextEditingController _pillCountController = TextEditingController();

String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year && 
           date.month == today.month && 
           date.day == today.day;
  }
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 32.0;

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
          strings['set_schedule'] ?? 'Set Schedule',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Reminder Time Section
              Text(
                strings['reminder_time'] ?? 'Reminder Time',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Time of Day Selection
              SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildTimeButton(
        strings['morning'] ?? 'Morning',
        'morning',
        FontAwesomeIcons.sun, // ☀️ Morning
      ),
      const SizedBox(width: 12),
      _buildTimeButton(
        strings['afternoon'] ?? 'Afternoon',
        'afternoon',
        FontAwesomeIcons.cloudSun, // ⛅ Afternoon
      ),
      const SizedBox(width: 12),
      _buildTimeButton(
        strings['night'] ?? 'Night',
        'night',
        FontAwesomeIcons.moon, // 🌙 Night
      ),
    ],
  ),
),

              const SizedBox(height: 16),
              // Time Picker
              _buildTimePicker(),
              
              const SizedBox(height: 24),
              // Day Selection Section
              Text(
                strings['select_days'] ?? 'Selected Days',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildDaySelector(),
              
              const SizedBox(height: 24),
              // Pill Count Section
              Text(
                strings['pill_count'] ?? 'Pill Count (Optional)',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_liquid, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _pillCountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: strings['enter_pill_count'] ?? 'How many pills do you have? (e.g., 30)',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Duration Section
              Text(
                strings['duration'] ?? 'Duration',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Start Date
             _buildScheduleTab(isMobile),
const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, String value, IconData icon) {
    final isSelected = selectedReminderTime == value;
    return GestureDetector(
      onTap: () => setState(() => selectedReminderTime = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F4F1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF199A8E) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF199A8E) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF199A8E) : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildTimePicker() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.access_time,
          color: Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),

        /// Selected Time Text (UPDATES LIVE)
        Expanded(
          child: Text(
            _formatTime(selectedTime),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        /// Clock button
        IconButton(
          icon: const Icon(
            Icons.schedule,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF199A8E),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() => selectedTime = picked); 
            }
          },
        ),
      ],
    ),
  );
}


  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = selectedDays[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDays[index] = !selectedDays[index];
              // If at least one day is unselected, change frequency label to 'selective'
              bool allSelected = selectedDays.every((day) => day);
              selectedFrequency = allSelected ? 'daily' : 'weekly';
            });
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF199A8E) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF199A8E) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                dayLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScheduleTab(bool isMobile) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        // ───── Start Date Row ─────
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    useMaterial3: true,
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF00897B), // ✔ same green
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                    datePickerTheme: DatePickerThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      headerBackgroundColor: Color(0xFF00897B),
                      headerForegroundColor: Colors.white,
                      todayBorder: BorderSide(color: Color(0xFF00897B)),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  strings['start_date'] ?? 'Start Date',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _isToday(selectedDate) 
                      ? (strings['today'] ?? 'Today') 
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ───── Divider ─────
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade300,
        ),

        // ───── Repeat Toggle Row ─────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings['repeat_until_stopped'] ?? 'Repeat until stopped',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.scale(
                scale: isMobile ? 0.8 : 1.0,
                child: Switch(
                  value: repeatUntilStopped,
                  onChanged: (value) =>
                      setState(() => repeatUntilStopped = value),
                  activeColor: const Color(0xFF199A8E),
                  activeTrackColor: const Color(0xFF199A8E),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



  Widget _buildSaveButton() {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Construct a string of selected days: "1,3,5" (Mon, Wed, Fri)
          List<int> activeDays = [];
          for (int i = 0; i < selectedDays.length; i++) {
            if (selectedDays[i]) activeDays.add(i + 1); // 1-7 for Mon-Sun
          }
          final daysString = activeDays.join(',');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmReminderPage(
                medicineName: widget.medicineName,
                dosage: widget.dosage,
                time: _formatTime(selectedTime),
                frequency: daysString.isEmpty ? 'DAILY' : daysString,
                type: widget.medicineType,
                pillCount: int.tryParse(_pillCountController.text),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF199A8E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          strings['save_reminder'] ?? 'Save Reminder',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}