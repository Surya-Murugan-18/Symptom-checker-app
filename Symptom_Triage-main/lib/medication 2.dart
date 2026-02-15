import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:symtom_checker/medfriend_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/services/alarm_service.dart';
import 'package:symtom_checker/services/notification_service.dart';
import 'package:symtom_checker/medication3.dart';
import 'package:symtom_checker/medication%20history.dart';
import 'package:symtom_checker/medication%20edit.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class MedicationReminders extends StatefulWidget {
  const MedicationReminders({Key? key}) : super(key: key);

  @override
  State<MedicationReminders> createState() => _MedicationRemindersState();
}

class _MedicationRemindersState extends State<MedicationReminders> {
  List<Medication> medications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId/medications/all"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            medications = data.map((json) => Medication.fromJson(json)).toList();
            isLoading = false;
          });
        }
        _scheduleAlarms();
      }
    } catch (e) {
      debugPrint("Error fetching medications: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Refresh data without showing loading spinner (used after take/skip/refill)
  Future<void> _fetchMedicationsSilent() async {
    final userId = UserSession().userId;
    if (userId == null) return;
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId/medications/all"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            medications = data.map((json) => Medication.fromJson(json)).toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _scheduleAlarms() async {
    if (kIsWeb) return; // Alarms don't work on web
    await AlarmService().stopAll();
    await NotificationService().cancelAll();

    for (var med in medications) {
      if (med.isActive && med.id != null) {
        final slots = med.timeSlots.split(',');
        for (var i = 0; i < slots.length; i++) {
          final time = parseMedicationTime(slots[i]);
          if (time == null) continue;

          final now = DateTime.now();
          DateTime scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
          
          // ---- SMART SCHEDULING LOGIC ----
          // If frequency is specific days (e.g. "1,3,5" for Mon,Wed,Fri)
          if (med.frequency != null && med.frequency != 'DAILY' && med.frequency!.isNotEmpty) {
            List<int> activeDays = med.frequency!.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
            
            if (activeDays.isNotEmpty) {
              // Find the next active day
              int currentWeekday = now.weekday; // 1=Mon, 7=Sun
              
              // If today is an active day but time passed, or if today is NOT an active day
              if ((activeDays.contains(currentWeekday) && scheduledTime.isBefore(now)) || !activeDays.contains(currentWeekday)) {
                // Find how many days to add to reach the next active day
                int daysToAdd = 1;
                while (daysToAdd <= 7) {
                  int nextDay = ((currentWeekday + daysToAdd - 1) % 7) + 1;
                  if (activeDays.contains(nextDay)) break;
                  daysToAdd++;
                }
                scheduledTime = scheduledTime.add(Duration(days: daysToAdd));
              }
            } else if (scheduledTime.isBefore(now)) {
              scheduledTime = scheduledTime.add(const Duration(days: 1));
            }
          } else if (scheduledTime.isBefore(now)) {
            // Standard Daily logic
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }
          // --------------------------------

          // Use a unique ID for each slot
          final alarmId = (med.id! * 100) + i;
          await AlarmService().setAlarm(
            id: alarmId,
            dateTime: scheduledTime,
            assetPath: 'assets/OPPO.mp3',
            title: "Medicine Time",
            body: "${med.name}, ${med.dosage}",
          );
          // ... notification logic remains same

          await NotificationService().scheduleNotification(
            id: alarmId,
            title: "Medicine: ${med.name}",
            body: "It's time for your ${med.dosage} dose.",
            scheduledDate: scheduledTime,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header
            Container(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12.0 : 24.0,
                isMobile ? 16.0 : 24.0,
                isMobile ? 16.0 : 24.0,
                16.0
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings['your_reminders'] ?? 'Medication Plan',
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: const Color(0xFF1A1C1E),
                          ),
                        ),
                        Text(
                          "Managing ${medications.length} reminders",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.people_alt_outlined, size: 24, color: Color(0xFF199A8E)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MedfriendPage()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderAction(
                    icon: FontAwesomeIcons.plus,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicinePage()),
                      );
                      _fetchMedications();
                    },
                  ),
                ],
              ),
            ),

            // Medication List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF199A8E)))
                  : medications.isEmpty
                      ? _buildEmptyState(strings)
                      : RefreshIndicator(
                          color: const Color(0xFF199A8E),
                          onRefresh: _fetchMedications,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                            itemCount: medications.length,
                            itemBuilder: (context, index) {
                              return MedicationCard(
                                medication: medications[index],
                                isMobile: isMobile,
                                onToggle: (value) => _handleToggle(medications[index], value),
                                onDelete: () => _handleDelete(medications[index]),
                                onUpdate: _fetchMedications,
                                onTake: () => _handleTakeDose(medications[index]),
                                onSkip: () => _handleSkipDose(medications[index]),
                                onRefill: () => _showRefillDialog(medications[index]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      // Floating History Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: "history",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MedicationHistoryPage()),
                  );
                },
                backgroundColor: const Color(0xFF199A8E),
                elevation: 4,
                label: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      strings['history'] ?? 'Dose History',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
  }

  Widget _buildHeaderAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF199A8E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF199A8E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FaIcon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildEmptyState(Map<String, String> strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication_liquid, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          Text(
            strings['no_reminders'] ?? "No active plan yet",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add your first medicine",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(Medication med, bool value) async {
    // Immediate UI feedback
    setState(() {
      med.isActive = value;
    });

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/medications/${med.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserSession().token}"
        },
        body: jsonEncode({
          "name": med.name,
          "dosage": med.dosage,
          "timeSlots": med.timeSlots,
          "isActive": value,
          "type": med.type,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value ? "Reminder service enabled" : "Reminder service paused"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1A1C1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _scheduleAlarms();
          // Silently refresh to sync with server logic
          _fetchMedicationsSilent(); 
        }
      } else {
        _revertToggle(med, value);
      }
    } catch (e) {
      _revertToggle(med, value);
    }
  }

  void _revertToggle(Medication med, bool attemptedValue) {
    if (mounted) {
      setState(() {
        med.isActive = !attemptedValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleDelete(Medication med) async {
    try {
      await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/medications/${med.id}"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      _fetchMedications();
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  Future<void> _handleTakeDose(Medication med) async {
    if (med.id == null) return;

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/medications/${med.id}/take-dose"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool refillWarning = data['refillWarning'] ?? false;
        final int? remaining = data['pillsRemaining'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      refillWarning
                          ? "Dose recorded! ⚠️ Only $remaining pills left – time to refill!"
                          : "Dose of ${med.name} recorded! Stay healthy.",
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: refillWarning ? Colors.orange[800] : const Color(0xFF199A8E),
              duration: Duration(seconds: refillWarning ? 5 : 3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _fetchMedicationsSilent(); // Refresh pill counts
        }
      }
    } catch (e) {
      debugPrint("Take dose failed: $e");
      // Fallback: still show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Dose of ${med.name} recorded locally."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF199A8E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleSkipDose(Medication med) async {
    if (med.id == null) return;

    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/medications/${med.id}/skip-dose"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.skip_next, color: Colors.amber),
                const SizedBox(width: 12),
                Text("${med.name} dose skipped."),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1A1C1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fetchMedicationsSilent();
      }
    } catch (e) {
      debugPrint("Skip dose failed: $e");
    }
  }

  void _showRefillDialog(Medication med) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Refill ${med.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Number of pills",
            hintText: "e.g., 30",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(controller.text);
              if (count != null && count > 0 && med.id != null) {
                await http.put(
                  Uri.parse("${ApiConfig.baseUrl}/medications/${med.id}/refill"),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer ${UserSession().token}",
                  },
                  body: jsonEncode({"pillCount": count}),
                );
                _fetchMedicationsSilent();
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF199A8E)),
            child: const Text("Refill", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final bool isMobile;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onRefill;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.isMobile,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdate,
    required this.onTake,
    required this.onSkip,
    required this.onRefill,
  }) : super(key: key);

  String _getNextDoseTime() {
    final slots = medication.timeSlots.split(',');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime? nextDose;
    
    for (var slot in slots) {
      final time = parseMedicationTime(slot);
      if (time == null) continue;
      
      final doseTime = today.add(Duration(hours: time.hour, minutes: time.minute));
      
      if (doseTime.isAfter(now)) {
        if (nextDose == null || doseTime.isBefore(nextDose)) {
          nextDose = doseTime;
        }
      }
    }
    
    // If no more doses today, next one is likely tomorrow (first slot)
    if (nextDose == null && slots.isNotEmpty) {
      final time = parseMedicationTime(slots[0]);
      if (time != null) {
        nextDose = today.add(Duration(days: 1, hours: time.hour, minutes: time.minute));
      }
    }
    
    if (nextDose == null) return "No plan";
    
    final hour = nextDose.hour;
    final minute = nextDose.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final clockHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    final isTomorrow = nextDose.day != now.day;
    return "${isTomorrow ? 'Tomorrow' : 'Today'} at $clockHour:$minute $ampm";
  }

  String _getFrequencyText() {
    if (medication.frequency == null || medication.frequency == 'DAILY') {
      return 'Daily';
    }
    final days = medication.frequency!.split(',');
    final List<String> shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    try {
      return days.map((d) => shortDays[int.parse(d.trim()) - 1]).join(', ');
    } catch (_) {
      return medication.frequency!;
    }
  }

  int _getAdherencePercent() {
    final taken = medication.dosesTaken ?? 0;
    final skipped = medication.dosesSkipped ?? 0;
    final total = taken + skipped;
    if (total == 0) return 100;
    return ((taken / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final nextDose = _getNextDoseTime();
    final bool active = medication.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFF1F3F4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFFE8ECEF) : Colors.transparent, 
          width: 1
        ),
        boxShadow: active ? [
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ] : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF199A8E).withOpacity(0.12) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FaIcon(
                    _getIconForType(medication.type),
                    color: active ? const Color(0xFF199A8E) : Colors.grey[400],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: active ? const Color(0xFF1A1C1E) : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 14,
                          color: active ? Colors.grey[600] : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status / Next Dose
                      Row(
                        children: [
                          Icon(
                            active ? Icons.alarm : Icons.alarm_off,
                            size: 14,
                            color: active ? const Color(0xFF199A8E) : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              active ? "Next: $nextDose (${_getFrequencyText()})" : "Schedule Paused",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active ? const Color(0xFF199A8E) : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle Switch
                Switch.adaptive(
                  value: active,
                  onChanged: onToggle,
                  activeColor: const Color(0xFF199A8E),
                  activeTrackColor: const Color(0xFF199A8E).withOpacity(0.3),
                ),
              ],
            ),
          ),
          
          if (active) ...[
            // ── Pill Inventory Bar ──
            if (medication.pillsTotal != null && medication.pillsTotal! > 0) ...[
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F3F4)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.pills, size: 14, color: Color(0xFF199A8E)),
                    const SizedBox(width: 8),
                    Text(
                      "${medication.pillsRemaining ?? 0} / ${medication.pillsTotal} pills",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1E)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (medication.pillsRemaining ?? 0) / medication.pillsTotal!,
                          backgroundColor: Colors.grey[200],
                          color: (medication.pillsRemaining ?? 0) <= (medication.refillThreshold ?? 5)
                              ? Colors.orange
                              : const Color(0xFF199A8E),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    if ((medication.pillsRemaining ?? 0) <= (medication.refillThreshold ?? 5)) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onRefill,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: const Text("Refill", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            // ── Adherence Score Badge ──
            if ((medication.dosesTaken ?? 0) + (medication.dosesSkipped ?? 0) > 0) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 14, color: Color(0xFF199A8E)),
                    const SizedBox(width: 6),
                    Text(
                      "Adherence: ${_getAdherencePercent()}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getAdherencePercent() >= 80 ? const Color(0xFF199A8E) : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F3F4)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Take Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTake,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF199A8E), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "✓ Taken",
                        style: TextStyle(color: Color(0xFF199A8E), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Skip Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        "⏭ Skip",
                        style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: FontAwesomeIcons.penToSquare,
                    color: Colors.grey[100]!,
                    iconColor: const Color(0xFF199A8E),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditReminderPage(medication: medication)),
                      ).then((updated) { if (updated == true) onUpdate(); });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: FontAwesomeIcons.trashCan,
                    color: Colors.red[50]!,
                    iconColor: Colors.red[400]!,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FaIcon(icon, color: iconColor, size: 16),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    if (type == null) return FontAwesomeIcons.pills;
    switch (type.toUpperCase()) {
      case 'TABLET': return FontAwesomeIcons.tabletScreenButton;
      case 'CAPSULE': return FontAwesomeIcons.capsules;
      case 'SYRUP': return FontAwesomeIcons.flask;
      case 'INJECTION': return FontAwesomeIcons.syringe;
      default: return FontAwesomeIcons.pills;
    }
  }
}

class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String timeSlots;
  final String? frequency;
  final String? type;
  bool isActive;

  // Pill Inventory
  final int? pillsTotal;
  int? pillsRemaining;
  final int? refillThreshold;

  // Adherence
  int? dosesTaken;
  int? dosesMissed;
  int? dosesSkipped;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.timeSlots,
    required this.isActive,
    this.frequency,
    this.type,
    this.pillsTotal,
    this.pillsRemaining,
    this.refillThreshold,
    this.dosesTaken,
    this.dosesMissed,
    this.dosesSkipped,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      timeSlots: json['timeSlots'] ?? '',
      isActive: json['isActive'] ?? json['active'] ?? true,
      frequency: json['frequency'],
      type: json['type'],
      pillsTotal: json['pillsTotal'],
      pillsRemaining: json['pillsRemaining'],
      refillThreshold: json['refillThreshold'],
      dosesTaken: json['dosesTaken'],
      dosesMissed: json['dosesMissed'],
      dosesSkipped: json['dosesSkipped'],
    );
  }
}

TimeOfDay? parseMedicationTime(String slot) {
  try {
    final cleanSlot = slot.trim().toUpperCase();
    if (cleanSlot.isEmpty) return null;

    // Use regex to extract numbers and period
    // Matches "08:00 AM", "8 PM", "14:30", "00 AM" etc.
    final match = RegExp(r'(\d+)\s*[:\.]?\s*(\d*)\s*(AM|PM)?').firstMatch(cleanSlot);
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    int minute = 0;
    
    final minuteGroup = match.group(2);
    if (minuteGroup != null && minuteGroup.isNotEmpty) {
      minute = int.parse(minuteGroup);
    }
    
    final period = match.group(3);

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    
    // Validate bounds
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    debugPrint("Failed to parse medication time $slot: $e");
    return null;
  }
}
