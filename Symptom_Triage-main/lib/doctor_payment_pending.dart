import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/doctor_payment_pendingdetails.dart';

class DoctorPaymentPending extends StatefulWidget {
  const DoctorPaymentPending({Key? key}) : super(key: key);

  @override
  State<DoctorPaymentPending> createState() => _DoctorPaymentPendingState();
}

class _DoctorPaymentPendingState extends State<DoctorPaymentPending> {
  final List<Map<String, dynamic>> pendingPayments = [
    {
      'name': 'Priya Sharma',
      'age': 28,
      'gender': 'Female',
      'date': 'Jan 15, 2024 at 2:00 PM',
    },
    {
      'name': 'Vikram Singh',
      'age': 42,
      'gender': 'Male',
      'date': 'Jan 15, 2024 at 4:30 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pending Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            itemCount: pendingPayments.length,
            itemBuilder: (context, index) {
              final payment = pendingPayments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PaymentCard(
                  name: payment['name'],
                  age: payment['age'],
                  gender: payment['gender'],
                  date: payment['date'],
                  isDesktop: isDesktop,
                  onViewDetails: () {
                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorPaymentPendingDetails()),
                      );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String name;
  final int age;
  final String gender;
  final String date;
  final bool isDesktop;
  final VoidCallback onViewDetails;

  const PaymentCard({
    Key? key,
    required this.name,
    required this.age,
    required this.gender,
    required this.date,
    required this.isDesktop,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$age yrs • $gender',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Payment Pending',
                    style: TextStyle(
                      color: Color.fromARGB(255, 124, 75, 1),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
  child: OutlinedButton.icon(
    onPressed: onViewDetails,
    icon: const FaIcon(
      FontAwesomeIcons.eye,
      size: 14,
      color: Colors.black,
    ),
    label: const Text(
      'View Details',
      style: TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(44), // 🔑 MATCH Container height
      padding: EdgeInsets.zero, // 🔑 REMOVE default padding
      side: const BorderSide(
        color: Color(0xFFE0E0E0),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.white,
      alignment: Alignment.center,
    ),
  ),
),

                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 203, 241, 237),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.clock,
                          size: 14,
                          color: const Color(0xFF199A8E),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Waiting...',
                          style: TextStyle(
                            color: const Color(0xFF199A8E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
