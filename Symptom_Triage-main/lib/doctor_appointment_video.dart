import 'package:flutter/material.dart';
import 'package:symtom_checker/doctor_consultation_report.dart';

class DoctorAppointmentVideo extends StatefulWidget {
  const DoctorAppointmentVideo({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentVideo> createState() => _DoctorAppointmentVideoState();
}

class _DoctorAppointmentVideoState extends State<DoctorAppointmentVideo> {
  bool isMicOn = false;
  bool isVideoOn = true;
  String callTime = '12:34';

  @override
  void initState() {
    super.initState();
  }

  void onMicPressed() {
    setState(() {
      isMicOn = !isMicOn;
    });
    print('Mic button pressed. Mic is now: ${isMicOn ? 'ON' : 'OFF'}');
  }

  void onVideoPressed() {
    setState(() {
      isVideoOn = !isVideoOn;
    });
    print('Video button pressed. Video is now: ${isVideoOn ? 'ON' : 'OFF'}');
  }

  void onDocumentPressed() {
    print('Document button pressed');
    // Add your document/notes functionality here
  }

  void onCallEndPressed() {
    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorConsultationReportPage()),
                      );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 900;
    final bool isTablet = screenSize.width > 600 && screenSize.width <= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main background container
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF2C3E50),
              child: Column(
                children: [
                  // Top Section - Patient Info and Timer
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.04,
                      vertical: screenSize.height * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Patient Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sarah Johnson',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 24 : isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: screenSize.height * 0.005,
                            ),
                            Text(
                              '32 yrs, Female',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        // Timer
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.03,
                            vertical: screenSize.height * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            callTime,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacer
                  SizedBox(height: screenSize.height * 0.05),
                  // Main Video Area
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Video Icon
                          Container(
                            width: isDesktop ? 120 : isTablet ? 100 : 80,
                            height: isDesktop ? 120 : isTablet ? 100 : 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.grey[500],
                              size: isDesktop ? 60 : isTablet ? 50 : 40,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.03),
                          // Connecting Text
                          Text(
                            'Connecting to patient...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer for bottom area
                  SizedBox(height: screenSize.height * 0.08),
                ],
              ),
            ),
            // Video Preview - Bottom Right
            Positioned(
              bottom: screenSize.height * 0.15,
              right: screenSize.width * 0.05,
              child: Container(
                width: isDesktop ? 180 : isTablet ? 140 : 110,
                height: isDesktop ? 240 : isTablet ? 200 : 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[600]!,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.videocam,
                    color: Colors.grey[600],
                    size: isDesktop ? 40 : isTablet ? 32 : 24,
                  ),
                ),
              ),
            ),
            // Bottom Control Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mic Button
                    GestureDetector(
                      onTap: onMicPressed,
                      child: Container(
                        width: isDesktop ? 70 : isTablet ? 60 : 50,
                        height: isDesktop ? 70 : isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: isMicOn
                              ? const Color(0xFF199A8E)
                              : Colors.grey[700],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: isDesktop ? 32 : isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.04),
                    // Video Button
                    GestureDetector(
                      onTap: onVideoPressed,
                      child: Container(
                        width: isDesktop ? 70 : isTablet ? 60 : 50,
                        height: isDesktop ? 70 : isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: isVideoOn
                              ? const Color(0xFF199A8E)
                              : Colors.grey[700],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: isDesktop ? 32 : isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.04),
                    // Document Button
                    GestureDetector(
                      onTap: onDocumentPressed,
                      child: Container(
                        width: isDesktop ? 70 : isTablet ? 60 : 50,
                        height: isDesktop ? 70 : isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description,
                          color: Colors.white,
                          size: isDesktop ? 32 : isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.04),
                    // Call End Button
                    GestureDetector(
                      onTap: onCallEndPressed,
                      child: Container(
                        width: isDesktop ? 70 : isTablet ? 60 : 50,
                        height: isDesktop ? 70 : isTablet ? 60 : 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: isDesktop ? 32 : isTablet ? 28 : 24,
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
  }
}
