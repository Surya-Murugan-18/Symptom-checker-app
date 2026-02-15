import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/chatdoctor.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

class BookingDoctorPage extends StatefulWidget {
  final String doctorName;
  final String specialization;
  final double rating;
  final String distanceText;
  final DateTime appointmentDateTime;
  final int? doctorId;
  final int? appointmentId; // If present, this is a payment flow
  final String? photoUrl;

  const BookingDoctorPage({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.rating,
    required this.distanceText,
    required this.appointmentDateTime,
    this.doctorId,
    this.appointmentId,
    this.photoUrl,
  });

  @override
  State<BookingDoctorPage> createState() => _BookingDoctorPageState();
}

class _BookingDoctorPageState extends State<BookingDoctorPage> {
  late double consultationFee;
  late double adminFee;
  late double totalAmount;

  final TextEditingController reasonController = TextEditingController();
  String selectedReason = 'General Consultation';

  String selectedPaymentMethod = 'VISA';
  IconData selectedPaymentIcon = FontAwesomeIcons.ccVisa;
  Color selectedPaymentColor = Colors.black87;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    consultationFee = 50.0;
    adminFee = 5.0;
    totalAmount = consultationFee + adminFee;
    reasonController.text = "Requested via Mobile App"; // default notes
  }

  void _changePaymentMethod() {
    final List<Map<String, dynamic>> paymentMethods = [
      {'name': 'VISA', 'icon': FontAwesomeIcons.ccVisa, 'color': const Color.fromARGB(255, 2, 36, 64)},
      {'name': 'Debit Card', 'icon': FontAwesomeIcons.creditCard, 'color': Colors.black87},
      {'name': 'PhonePe', 'icon': FontAwesomeIcons.phone, 'color': const Color(0xFF5F259F)},
      {'name': 'Google Pay', 'icon': FontAwesomeIcons.google, 'color': const Color(0xFF4285F4)},
      {'name': 'UPI', 'icon': FontAwesomeIcons.indianRupeeSign, 'color': const Color(0xFF0F9D58)},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.s('select_payment_method', 'Select Payment Method'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ...paymentMethods.map((method) => ListTile(
                leading: FaIcon(method['icon'] as IconData, color: method['color'] as Color),
                title: Text(method['name'] as String),
                trailing: selectedPaymentMethod == method['name'] ? const Icon(Icons.check_circle, color: Color(0xFF17A697)) : null,
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = method['name'] as String;
                    selectedPaymentIcon = method['icon'] as IconData;
                    selectedPaymentColor = method['color'] as Color;
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction() {
    if (widget.appointmentId != null) {
      _startStripePayment();
    } else {
      _confirmBooking();
    }
  }

  // Real Stripe Payment Flow (Mobile) / Simulated Flow (Web)
  Future<void> _startStripePayment() async {
    setState(() => _isProcessing = true);

    if (kIsWeb) {
      // Simulate a professional payment flow for Web demo
      await Future.delayed(const Duration(seconds: 2));
      _confirmPaymentOnBackend();
      return;
    }

    try {
      // 1. Create PaymentIntent on the backend
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession().token}',
        },
        body: json.encode({
          'amount': totalAmount.toInt(),
          'currency': 'usd',
          'appointmentId': widget.appointmentId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create PaymentIntent");
      }

      final data = json.decode(response.body);
      final clientSecret = data['clientSecret'];

      // 2. Initialize Payment Sheet (Mobile Only)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Sev-ai Healthcare',
          style: ThemeMode.light,
        ),
      );

      // 3. Display Payment Sheet (Mobile Only)
      await Stripe.instance.presentPaymentSheet();

      // 4. If successful, update the appointment status on the backend
      _confirmPaymentOnBackend();

    } catch (e) {
      if (e is StripeException) {
        debugPrint("Stripe error: ${e.error.localizedMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Cancelled or Failed: ${e.error.localizedMessage}")),
        );
      } else {
        debugPrint("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _confirmPaymentOnBackend() async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/appointments/${widget.appointmentId}/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession().token}',
        },
        body: json.encode({
          'paymentMethod': 'Stripe',
          'paymentId': 'STRIPE-${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        _confirmPaymentSuccess();
      }
    } catch (e) {
      debugPrint("Error updating payment on backend: $e");
    }
  }

  void _confirmBooking() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession().token}',
        },
        body: json.encode({
          'patientId': userId,
          'doctorId': widget.doctorId ?? 1,
          'date': DateFormat('yyyy-MM-dd').format(widget.appointmentDateTime),
          'time': DateFormat('hh:mm a').format(widget.appointmentDateTime),
          'reason': selectedReason,
          'notes': reasonController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showBookingRequestedPopup();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showBookingRequestedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.send, color: Color(0xFF17A697), size: 64),
            const SizedBox(height: 16),
            Text(AppStrings.s('request_sent', 'Request Sent'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(AppStrings.s('request_sent_desc', 'Your booking request has been sent. You will be notified once the doctor accepts it.'), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A697)),
              child: Text(AppStrings.s('back_to_home', 'Back to Home'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF17A697), size: 64),
            const SizedBox(height: 16),
            Text(AppStrings.s('payment_success', 'Payment Success'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatDoctorScreen(doctorName: widget.doctorName, isPaid: true, doctorId: widget.doctorId, appointmentId: widget.appointmentId)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A697)),
              child: Text(AppStrings.s('chat_now', 'Chat Now'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.s('appointment_title', 'Appointment')),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Simple Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      AvatarImage(
                        imageUrl: widget.photoUrl,
                        width: 60,
                        height: 60,
                        borderRadius: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(widget.specialization, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.calendar_today, AppStrings.s('date_label', 'Date'), DateFormat('EEEE, MMM dd, yyyy').format(widget.appointmentDateTime)),
                _buildInfoRow(Icons.access_time, AppStrings.s('time_label', 'Time'), DateFormat('hh:mm a').format(widget.appointmentDateTime)),
                
                if (widget.appointmentId == null) ...[
                  _buildInfoRow(Icons.question_mark, AppStrings.s('reason_label', 'Reason'), selectedReason, onTap: _changeReason),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.s('notes_to_doctor', 'Notes to Doctor'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppStrings.s('describe_symptoms_hint', 'Describe your symptoms or reason for visit...'),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                  ),
                ],
                
                if (widget.appointmentId != null) ...[
                  const Divider(height: 48),
                  Text(AppStrings.s('payment_details', 'Payment Details'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildPaymentItem(AppStrings.s('consultation_fee', 'Consultation Fee'), '\$${consultationFee.toStringAsFixed(2)}'),
                  _buildPaymentItem(AppStrings.s('admin_fee', 'Admin Fee'), '\$${adminFee.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildPaymentItem(AppStrings.s('total', 'Total'), '\$${totalAmount.toStringAsFixed(2)}', isTotal: true),
                  
                  const SizedBox(height: 24),
                  Text(AppStrings.s('payment_method', 'Payment Method'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _changePaymentMethod,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          FaIcon(selectedPaymentIcon, color: selectedPaymentColor),
                          const SizedBox(width: 12),
                          Text(selectedPaymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(AppStrings.s('change', 'Change'), style: const TextStyle(color: Colors.teal)),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleAction,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A697), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.appointmentId != null ? AppStrings.s('pay_now', 'Pay Now') : AppStrings.s('request_appointment', 'Request Appointment'),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (onTap != null) ...[
            TextButton(onPressed: onTap, child: Text(AppStrings.s('change', 'Change'))),
          ]
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
          Text(amount, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.teal : null)),
        ],
      ),
    );
  }

  void _changeReason() {
    final List<String> reasons = [
      AppStrings.s('general_consultation', 'General Consultation'),
      AppStrings.s('follow_up_visit', 'Follow-up Visit'),
      AppStrings.s('fever_cold', 'Fever & Cold'),
      AppStrings.s('physical_checkup', 'Physical Checkup'),
      AppStrings.s('report_review', 'Report Review'),
      AppStrings.s('other_reason', 'Other'),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.s('select_reason', 'Select Reason'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...reasons.map((reason) => ListTile(
              title: Text(reason),
              trailing: selectedReason == reason ? const Icon(Icons.check, color: Color(0xFF17A697)) : null,
              onTap: () {
                setState(() => selectedReason = reason);
                Navigator.pop(context);
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}
