import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/services/notification_service.dart';
import 'user_session.dart';
import 'about_sev-ai.dart';
import 'account_login.dart';
import 'emergency_contact_page.dart';
import 'health_assements.dart';
import 'homepage.dart';
import 'message.dart';
import 'privacy_notifications.dart';
import 'safety_information.dart';
import 'schedule.dart';
import 'edit_profile.dart';
import 'ambulance.dart';
import 'signin.dart';
import 'language/app_state.dart';
import 'language/app_language.dart';
import 'language/app_strings.dart';
import 'widgets/avatar_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color appColor = const Color(0xFF199A8E);
  final Color titleColor = Colors.black;
  final Color backgroundColor = Colors.white;
  int _selectedIndex = 4;
  bool isLoading = true;
  Map<String, dynamic>? healthVitals;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);
    await _fetchUserProfile();
    await _fetchLatestVitals();
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchUserProfile() async {
    final userId = UserSession().userId;
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        UserSession sess = UserSession();
        sess.gender = data['gender'];
        sess.dob = data['dob'];
        sess.location = data['location'];
        sess.contact = data['contact'];
        sess.language = data['language'];
        sess.hasChronicIllness = data['hasChronicIllness'];
        sess.chronicIllnessDetails = data['chronicIllnessDetails'];
        sess.takesRegularMedicine = data['takesRegularMedicine'];
        sess.weight = data['weight'];
        sess.bloodPressureLevel = data['bloodPressureLevel'];
        sess.photoUrl = data['photoUrl'];
      }

      // Fetch emergency contacts
      final emergencyResp = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$userId/emergency"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      if (emergencyResp.statusCode == 200) {
        final List<dynamic> contacts = jsonDecode(emergencyResp.body);
        UserSession().emergencyContacts = contacts.map((c) => {
          "id": c['id'],
          "name": c['name'],
          "phone": c['phone'],
          "relationship": c['relation'],
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> _fetchLatestVitals() async {
    final email = UserSession().email;
    if (email == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.healthLatest}/$email"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );

      if (response.statusCode == 200) {
        setState(() {
          healthVitals = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching vitals: $e");
    }
  }

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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ambulance Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final Uri phoneUri = Uri(scheme: 'tel', path: '108');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AmbulancePage()),
                    );
                  },
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
                  onPressed: () async {
                    Navigator.pop(context);
                    final userId = UserSession().userId;
                    if (userId != null) {
                      // Try session first
                      if (UserSession().emergencyContacts != null && UserSession().emergencyContacts!.isNotEmpty) {
                        final phone = UserSession().emergencyContacts![0]['phone'].toString();
                        final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                          return;
                        }
                      }

                      try {
                        final response = await http.get(
                          Uri.parse('${ApiConfig.baseUrl}/users/$userId/emergency'),
                          headers: {"Authorization": "Bearer ${UserSession().token}"},
                        );
                        if (response.statusCode == 200) {
                          final List<dynamic> contacts = json.decode(response.body);
                          if (contacts.isNotEmpty) {
                            final firstContact = contacts[0];
                            final phone = firstContact['phone'].toString();
                            final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                              return;
                            }
                          }
                        }
                      } catch (e) {
                        debugPrint('Error fetching emergency contact: $e');
                      }
                    }
                    
                    // Fallback to 112
                    final Uri fallbackUri = Uri(scheme: 'tel', path: '112');
                    if (await canLaunchUrl(fallbackUri)) {
                      await launchUrl(fallbackUri);
                    }
                  },
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Profile
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 24 : 32,
                    horizontal: isMobile ? 16 : 32,
                  ),
                  child: Column(
                    children: [
                      // Profile Section
                      Column(
                        children: [
                          // Profile Image with Edit Button
                          Stack(
                            children: [
                                Container(
                                  width: isMobile ? 120 : 140,
                                  height: isMobile ? 120 : 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                  ),
                                  child: AvatarImage(
                                    imageUrl: UserSession().photoUrl,
                                    width: isMobile ? 120 : 140,
                                    height: isMobile ? 120 : 140,
                                    borderRadius: isMobile ? 60 : 70, // Half of width/height
                                  ),
                                ),
                              // Edit Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: isMobile ? 36 : 44,
                                  height: isMobile ? 36 : 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        // Navigate to edit profile page
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const EditProfilePage(),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadProfileData();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(50),
                                      child: Icon(
                                        Icons.edit,
                                        size: isMobile ? 16 : 20,
                                        color: appColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          // Profile Name
                          Text(
                            UserSession().fullName,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 28),
                      // Health Stats
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildHealthStat(
                                icon: Icons.favorite,
                                label: AppStrings.s('heart_rate', 'Heart rate'),
                                value: healthVitals != null 
                                    ? '${healthVitals!['heartRate']}bpm' 
                                    : '-- bpm',
                                isMobile: isMobile,
                              ),
                              Container(
                                width: 1,
                                height: isMobile ? 60 : 80,
                                color: Colors.white30,
                              ),
                              _buildHealthStat(
                                icon: Icons.bloodtype,
                                label: AppStrings.s('spo2', 'SpO2'),
                                value: healthVitals != null 
                                    ? '${healthVitals!['spo2']}%' 
                                    : '-- %',
                                isMobile: isMobile,
                              ),
                              Container(
                                width: 1,
                                height: isMobile ? 60 : 80,
                                color: Colors.white30,
                              ),
                              _buildHealthStat(
                                icon: Icons.scale,
                                label: AppStrings.s('weight', 'Weight'),
                                value: '${UserSession().weight ?? '103'}lbs',
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Menu Section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 16 : 24,
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: FontAwesomeIcons.userCircle,
                        title: AppStrings.s('account_login', 'Account Login'),
                        onTap: () {
                          Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AccountLoginPage()),
              );
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.shieldAlt,
                        title: AppStrings.s('privacy_notifications', 'Privacy and Notifications'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyNotificationsPage(),
                            ),
                          );
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.language,
                        title: AppStrings.s('language', 'Language'),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.clipboardCheck,

                        title: AppStrings.s('health_assessments', 'Health Assessments'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HealthHistoryPage(),
                            ),
                          );
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.phoneAlt,
                        title: AppStrings.s('emergency_contacts', 'Emergency Contacts'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          ).then((_) => _loadProfileData());
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.circleInfo,
                        title: AppStrings.s('about_sev_ai', 'About SEV-AI'),
                        onTap: () {
                          Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AboutSevAIPage(),
                                          ),
                                        );
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.triangleExclamation,
                        title: AppStrings.s('safety_information', 'Safety Information'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SafetyInformationPage(),
                            ),
                          );
                        },
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      _buildMenuItem(
                        icon: FontAwesomeIcons.rightFromBracket,
                        title: AppStrings.s('logout', 'Logout'),
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        isMobile: isMobile,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),

                // Bottom spacing for navigation bar
                SizedBox(height: isMobile ? 80 : 0),
              ],
            ),
          ),
          // Bottom Navigation Bar (Mobile Only)
          if (isMobile)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigation(),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthStat({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Container(
          width: isMobile ? 40 : 50,
          height: isMobile ? 40 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          label,
          style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.white70),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isMobile,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 40 : 48,
                  height: isMobile ? 40 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLogout
                        ? Colors.red.shade50
                        : appColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red.shade400 : appColor,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red.shade400 : titleColor,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red.shade400 : Colors.grey,
              size: isMobile ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HealthcareHomePage()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Message()),
              );
              break;

            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SchedulePage()),
              );
              break;
            case 4:
              break;
          }
        },
        items: [
          _navItem(FontAwesomeIcons.home, 0),
          _navItem(FontAwesomeIcons.envelope, 1),
           _callNavItem(),
          _navItem(FontAwesomeIcons.calendarAlt, 3),
          _navItem(FontAwesomeIcons.user, 4),
        ],
      ),
    );
  }

BottomNavigationBarItem _callNavItem() {
  return BottomNavigationBarItem(
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
              angle: 2.4,
              child: Icon(
                FontAwesomeIcons.phone,
                size: 28,
                color: _selectedIndex == 2
                    ? Colors.white
                    : Colors.grey,
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
  );
}


  BottomNavigationBarItem _navItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? const Color(0xFF199A8E)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: _selectedIndex == index ? Colors.white : Colors.grey,
        ),
      ),
      label: '',
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: appColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logout Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF199A8E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFF199A8E),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Dialog Text
                Text(
                  AppStrings.s('logout_confirm', 'Are you sure to log out of\nyour account?'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      NotificationService().stopPolling();
                      UserSession().clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.s('logout', 'Log Out'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF199A8E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    AppStrings.s('cancel', 'Cancel'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.s('select_language', 'Select Language')),
          content: SingleChildScrollView(
            child: ListBody(
              children: AppLanguage.values.map((lang) {
                return ListTile(
                  title: Text(lang.name.toUpperCase()),
                  onTap: () {
                    setState(() {
                      AppState.selectedLanguage = lang;
                      UserSession().language = lang.name;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language changed to ${lang.name}')),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
