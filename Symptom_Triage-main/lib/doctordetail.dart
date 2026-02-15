import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/bookingdoctor.dart';
import 'package:symtom_checker/services/doctor_service.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:intl/intl.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';


class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({
    super.key,
    this.doctorName = 'Dr. Marcus Horizon',
    this.speciality = 'Cardiologist',
    this.rating = 4.7,
    this.distanceText = '800m away',
    this.photoUrl,
    this.doctorId,
    this.appointmentId,
    this.isRescheduling = false,
  });

  final String doctorName;
  final String speciality;
  final double rating;
  final String distanceText;
  final String? photoUrl;
  final int? doctorId;
  final int? appointmentId;
  final bool isRescheduling;

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  static const Color _primary = Color(0xFF16B3A6);
  static const Color _textMuted = Color(0xFF77838F);
  static const Color _border = Color(0xFFE4E6EA);

  late final List<DateTime> _dates;
  int _selectedDate = 0; // Default to first date (today/next available)
  String? _selectedTime = '09:00 AM'; // Default to first slot

  final DoctorService _doctorService = DoctorService();
  Doctor? _doctor; // live data from API
  bool _isLoadingProfile = false;

  final List<String> _timeSlots = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  // Accessors that prefer live data over widget params
  String get _doctorName => _doctor?.fullName ?? widget.doctorName;
  String get _speciality => _doctor?.specialization ?? widget.speciality;
  double get _rating => _doctor?.rating ?? widget.rating;
  String get _distanceText => _doctor?.location ?? widget.distanceText;
  String? get _photoUrl => _doctor?.photoUrl ?? widget.photoUrl;
  String? get _qualification => _doctor?.qualification;
  int? get _experienceYears => _doctor?.experienceYears;
  String? get _hospital => _doctor?.hospital;
  double? get _consultationFee => _doctor?.consultationFee;

  String _getAboutText(String specialty) {
    final key = '${specialty.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}_desc';
    return AppStrings.s(key, AppStrings.s('general_desc', 'An experienced medical professional dedicated to providing high-quality healthcare services.'));
  }

  /// Combined date + time from selected date index and time slot string (e.g. "09:00 AM").
  DateTime get _appointmentDateTime {
    final date = _dates[_selectedDate];
    final timeStr = _selectedTime ?? '09:00 AM';
    try {
      final parsed = DateFormat('hh:mm a').parse(timeStr);
      return DateTime(date.year, date.month, date.day, parsed.hour, parsed.minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 9, 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _dates = List<DateTime>.generate(
      31,
      (int i) => DateTime.now().add(Duration(days: i)),
    );
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    if (widget.doctorId == null) return;
    setState(() => _isLoadingProfile = true);
    try {
      final doctor = await _doctorService.fetchDoctorById(widget.doctorId!);
      if (mounted) {
        setState(() {
          _doctor = doctor;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.s('doctor_detail', 'Doctor Detail'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
  
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth > 640;
          final double panelWidth = wide ? 520 : double.infinity;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AvatarImage(
                          imageUrl: _photoUrl,
                          width: 96,
                          height: 96,
                          borderRadius: 12,
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _doctorName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _speciality,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F8F2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.star,
                                          color: _primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: _primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.place,
                                          color: _textMuted,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _distanceText,
                                            style: const TextStyle(
                                              color: _textMuted,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.s('experience', 'Experience'),
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_experienceYears ?? 5} ${AppStrings.s('years', 'Years')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Extra info chips (from live data)
                    if (_doctor != null) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (_experienceYears != null)
                            _infoChip(Icons.work_outline, '$_experienceYears ${AppStrings.s('yrs_experience', 'yrs experience')}'),
                          if (_qualification != null)
                            _infoChip(Icons.school_outlined, _qualification!),
                          if (_hospital != null)
                            _infoChip(Icons.local_hospital_outlined, _hospital!),
                          if (_consultationFee != null)
                            _infoChip(Icons.currency_rupee, _consultationFee!.toStringAsFixed(0)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.s('about', 'About'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReadMoreText(
                      text: _getAboutText(_speciality),
                    ),

                    const SizedBox(height: 24),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildTimeGrid(),
                    const SizedBox(height: 22),

					

SafeArea(
  child: Row(
    children: <Widget>[
      SizedBox(
        width: 56,
        height: 56,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 243, 251, 251),
            shape: const CircleBorder(),
            side: const BorderSide(color: _border),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {},
          child: const FaIcon(
            FontAwesomeIcons.commentDots,
            color: _primary,
            size: 25,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (widget.isRescheduling) {
                _handleReschedule(_appointmentDateTime);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDoctorPage(
                      doctorId: widget.doctorId,
                      doctorName: _doctorName,
                      specialization: _speciality,
                      rating: _rating,
                      distanceText: _distanceText,
                      appointmentDateTime: _appointmentDateTime,
                      photoUrl: _photoUrl,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: const StadiumBorder(),
            ),
            child: Text(
              widget.isRescheduling 
                  ? AppStrings.s('reschedule', 'Reschedule Appointment')
                  : AppStrings.s('book_appointment', 'Book Appointment'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final DateTime date = _dates[index];
          final bool selected = index == _selectedDate;
         return MouseRegion(
  cursor: SystemMouseCursors.click, // ✅ hand cursor
  child: GestureDetector(
    onTap: () => setState(() => _selectedDate = index),
    child: Container(
      width: 64,
      decoration: BoxDecoration(
        color: selected ? _primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _weekdayAbbrev(date.weekday),
            style: TextStyle(
              color: selected ? Colors.white : _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  ),
);

        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // ✅ 3 per row
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6, // controls button height
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final time = _timeSlots[index];
        final bool selected = _selectedTime == time;

        return OutlinedButton(
          onPressed: () => setState(() => _selectedTime = time),
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? _primary : Colors.white,
            side: BorderSide(color: selected ? _primary : _border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  String _weekdayAbbrev(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E6EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleReschedule(DateTime newDateTime) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/appointments/${widget.appointmentId}/reschedule"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserSession().token}"
        },
        body: json.encode({
          "date": DateFormat('yyyy-MM-dd').format(newDateTime),
          "time": DateFormat('hh:mm a').format(newDateTime),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.s('reschedule_success_snackbar', 'Appointment rescheduled successfully. Pending doctor approval.'))),
        );
        Navigator.pop(context, true); // Return success to SchedulePage
      }
    } catch (e) {
      debugPrint("Reschedule error: $e");
    }
  }

  // ignore: unused_element - kept for showing "select date and time" validation
  void _showSelectionAlert() {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               Text(
                strings['select_date'] ?? 'Select Date',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
                SizedBox(height: 12),
                Text(
                  'Please choose both date and time to proceed with booking.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 14,
                        color: _primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReadMoreText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ReadMoreText({super.key, required this.text, this.trimLines = 3});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: const TextStyle(
              fontSize: 14,
              color: _DoctorDetailPageState._textMuted,
              height: 1.5,
            ),
          ),
          maxLines: widget.trimLines,
textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool exceeds = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : widget.trimLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: _DoctorDetailPageState._textMuted,
                height: 1.5,
              ),
            ),
            if (exceeds)
              TextButton(
                onPressed: () {
                  setState(() => _expanded = !_expanded);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    color: Color(0xFF16B3A6), // ✅ required color
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
