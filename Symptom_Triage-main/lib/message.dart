import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:symtom_checker/chatdoctor.dart';
import 'package:symtom_checker/homepage.dart';
import 'package:symtom_checker/profile.dart';
import 'package:symtom_checker/schedule.dart';
import 'package:symtom_checker/language/app_strings.dart';

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  int _selectedIndex = 1;
  // ignore: unused_field - setter used by tab UI when All/Group/Private tabs are enabled
  int _selectedTab = 1;
  List<Doctor> conversationDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final userId = UserSession().userId;
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/messages/conversations/$userId"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          conversationDoctors = data.map((json) => Doctor.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching conversations: $e");
      setState(() => isLoading = false);
    }
  }

  // Method to show emergency popup
  void _showEmergencyPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppStrings.s('emergency_services', 'Emergency Services'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {},
                  icon: Icon(FontAwesomeIcons.ambulance, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      AppStrings.s('call_ambulance', 'Call Ambulance'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1FA59E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(FontAwesomeIcons.userDoctor, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      AppStrings.s('emergency_contact_person', 'Emergency Contact Person'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1FA59E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.s('cancel', 'Cancel'),
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 15 : 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.s('message_title', 'Message'),
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 4 : 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.grey.shade600,
                        size: isMobile ? 22 : 24,
                      ),
                      padding: EdgeInsets.zero, // keeps size tight
                      constraints:
                          const BoxConstraints(), // prevents extra space
                      splashRadius: 22,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: 2.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                /*  children: [
                    _buildTab(
                      label: 'All',
                      index: 0,
                      isActive: _selectedIndex == 0,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    _buildTab(
                      label: 'Group',
                      index: 1,
                      isActive: _selectedIndex == 1,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    _buildTab(
                      label: 'Private',
                      index: 2,
                      isActive: _selectedIndex == 2,
                    ),
                  ], */
                ),
              ),
            ),

            // Messages List
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : conversationDoctors.isEmpty
                  ? Center(child: Text(AppStrings.s('no_conversations_yet', 'No conversations yet')))
                  : ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 12 : 16,
                ),
                itemCount: conversationDoctors.length,
               itemBuilder: (context, index) {
                  final doctor = conversationDoctors[index];
                  return Column(
                    children: [
                      _buildMessageTile(doctor, isMobile),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          
        },
        backgroundColor: const Color(0xFF1ABFB8),
        child: const FaIcon(
          FontAwesomeIcons.commentDots,
          color: Colors.white,
          size: 25,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMessageTile(Doctor doctor, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDoctorScreen(
                doctorName: doctor.fullName,
                doctorImage: doctor.photoUrl ?? "assets/D6.jpg",
                doctorId: doctor.id,
                isPaid: true, // Assuming if they are in conv list, they paid or it's allowed
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Profile Picture
            AvatarImage(
              imageUrl: doctor.photoUrl,
              width: 56,
              height: 56,
              borderRadius: 28,
            ),
            SizedBox(width: isMobile ? 12 : 16),
            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    doctor.specialization ?? AppStrings.s('specialist_label', 'Specialist'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            // Time and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.s('active_status', 'Active'),
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,

      onTap: (index) {
        if (index == 2) {
          // Phone button - show emergency popup
          _showEmergencyPopup();
          return;
        }

        if (_selectedIndex == index) return;

        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthcareHomePage()),
            );
            break;

          case 1:
            break;

          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            );
            break;

          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
            break;
        }
      },

      items: [
        BottomNavigationBarItem(
          icon: _navIcon(FontAwesomeIcons.home, 0),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(FontAwesomeIcons.envelope, 1),
          label: '',
        ),
        BottomNavigationBarItem(
            icon: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? const Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 📞 Tilted call icon (TOP)
                  Positioned(
                    top: 8,
                    child: Transform.rotate(
                      angle: 2.4, // 👈 tilt here
                      child: Icon(
                        FontAwesomeIcons.phone,
                        size: 28,
                        color: _selectedIndex == 2 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),

                  // 🔴 e symbol (BOTTOM)
                  Positioned(
                    bottom: -12,
                    child: Text(
                      'e',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 39,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            label: '',
          ),
        BottomNavigationBarItem(
          icon: _navIcon(FontAwesomeIcons.calendarAlt, 3),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(FontAwesomeIcons.user, 4),
          label: '',
        ),
      ],
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _selectedIndex == index
            ? const Color(0xFF1FA59E)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.grey,
        size: 24,
      ),
    );
  }
}

class MessageData {
  final String name;
  final String message;
  final String time;
  final bool isRead;
  final String image;

  MessageData({
    required this.name,
    required this.message,
    required this.time,
    required this.isRead,
    required this.image,
  });
}
