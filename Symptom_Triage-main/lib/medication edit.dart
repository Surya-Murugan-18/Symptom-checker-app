import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/medication%202.dart';

class EditReminderPage extends StatefulWidget {
  final Medication? medication;

  const EditReminderPage({Key? key, this.medication}) : super(key: key);

  @override
  State<EditReminderPage> createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  late TextEditingController _medicineNameController;
  late TextEditingController _dosageController;
  
  String _selectedTime = 'Morning';
  late TimeOfDay _selectedTimeOfDay;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _medicineNameController = TextEditingController(text: widget.medication?.name ?? '');
    _dosageController = TextEditingController(text: widget.medication?.dosage ?? '');
    
    // Parse time from medication timeSlots (robustly)
    if (widget.medication != null && widget.medication!.timeSlots.isNotEmpty) {
      final time = parseMedicationTime(widget.medication!.timeSlots);
      if (time != null) {
        _selectedTimeOfDay = time;
      } else {
        _selectedTimeOfDay = const TimeOfDay(hour: 8, minute: 0);
      }
    } else {
      _selectedTimeOfDay = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeOfDay,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF199A8E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTimeOfDay) {
      setState(() {
        _selectedTimeOfDay = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (widget.medication?.id == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/medications/${widget.medication!.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserSession().token}"
        },
        body: jsonEncode({
          "name": _medicineNameController.text.trim(),
          "dosage": _dosageController.text.trim(),
          "timeSlots": "${_selectedTimeOfDay.hour.toString().padLeft(2, '0')}:${_selectedTimeOfDay.minute.toString().padLeft(2, '0')}",
          "isActive": widget.medication!.isActive,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update medication")),
        );
      }
    } catch (e) {
      debugPrint("Error updating medication: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteReminder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (widget.medication?.id != null) {
                  await http.delete(
                    Uri.parse("${ApiConfig.baseUrl}/medications/${widget.medication!.id}"),
                    headers: {"Authorization": "Bearer ${UserSession().token}"},
                  );
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final maxWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF199A8E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Reminder',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 24,
            vertical: 20,
          ),
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine Name Field
                      const Text(
                        'Medicine Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _medicineNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter medicine name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF199A8E)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dosage Field
                      const Text(
                        'Dosage',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          hintText: 'Enter dosage',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF199A8E)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reminder Time Section
                      const Text(
                        'Reminder Time',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Time Selection Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeOption(
                              icon: Icons.wb_sunny_outlined,
                              label: 'Morning',
                              isSelected: _selectedTime == 'Morning',
                              onTap: () {
                                setState(() {
                                  _selectedTime = 'Morning';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeOption(
                              icon: Icons.wb_sunny,
                              label: 'Afternoon',
                              isSelected: _selectedTime == 'Afternoon',
                              onTap: () {
                                setState(() {
                                  _selectedTime = 'Afternoon';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeOption(
                              icon: Icons.nightlight_outlined,
                              label: 'Night',
                              isSelected: _selectedTime == 'Night',
                              onTap: () {
                                setState(() {
                                  _selectedTime = 'Night';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time Picker
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey.shade600),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedTimeOfDay.hour.toString().padLeft(2, '0')}:${_selectedTimeOfDay.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 62),

                      // Save Changes Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF199A8E),
                            padding: const EdgeInsets.symmetric(vertical: 26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delete Reminder Button
                      Center(
                        child: TextButton.icon(
                          onPressed: _deleteReminder,
                          icon: const FaIcon(
                            FontAwesomeIcons.trashCan,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Delete Reminder',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTimeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF199A8E).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF199A8E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF199A8E) : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF199A8E) : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
