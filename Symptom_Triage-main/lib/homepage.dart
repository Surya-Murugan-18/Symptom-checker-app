import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/ambulance.dart';
import 'package:symtom_checker/articles.dart';
import 'package:symtom_checker/models/article_model.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'package:symtom_checker/artcile_expand.dart';
import 'package:intl/intl.dart';
import 'package:symtom_checker/chatscreen.dart';
import 'package:symtom_checker/doctordetail.dart';
import 'package:symtom_checker/emergency_contact_page.dart';
import 'package:symtom_checker/finddoctor.dart';
import 'package:symtom_checker/health monitotring 1.dart';
import 'package:symtom_checker/help.dart';
import 'package:symtom_checker/insurance1.dart';
import 'package:symtom_checker/medication remainder.dart';
import 'package:symtom_checker/message.dart';
import 'package:symtom_checker/nearby_hospital.dart';
import 'package:symtom_checker/notification.dart';
import 'package:symtom_checker/pill remainder.dart';
import 'package:symtom_checker/profile.dart';
// Removed Ocr intoduction.dart import
import 'package:symtom_checker/schedule.dart';
import 'package:symtom_checker/top_doctor.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/services/doctor_service.dart';
import 'package:symtom_checker/services/article_service.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:symtom_checker/appointment_list_page.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HealthcareHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Sample data for doctors

class HealthcareHomePage extends StatefulWidget {
  const HealthcareHomePage({Key? key}) : super(key: key);

  @override
  State<HealthcareHomePage> createState() => _HealthcareHomePageState();
}

class _HealthcareHomePageState extends State<HealthcareHomePage> {
  int _selectedIndex = 0;
  bool _showAllDoctors = false;
  
  List<Doctor> _topDoctors = [];
  List<Article> _recentArticles = [];
  bool _isLoading = true;
  final DoctorService _doctorService = DoctorService();
  final ArticleService _articleService = ArticleService();

  // Static fallback articles
  final List<Article> _staticArticles = [
    Article(
      id: 1,
      title: 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
      content: 'Fruits are an excellent source of essential vitamins and minerals, and they are high in fiber. Fruits also provide a wide range of health-boosting antioxidants, including flavonoids.',
      category: 'Nutrition',
      imageUrl: 'assets/article1.png',
      publishedDate: DateTime(2023, 6, 10),
      author: 'Dr. Sarah Johnson',
    ),
    Article(
      id: 2,
      title: 'The Impact of COVID-19 on Healthcare Systems',
      content: 'The COVID-19 pandemic has had a profound impact on healthcare systems worldwide, leading to significant changes in how healthcare is delivered and managed.',
      category: 'COVID-19',
      imageUrl: 'assets/covid.png',
      publishedDate: DateTime(2023, 5, 20),
      author: 'Dr. James Williams',
    ),
    Article(
      id: 3,
      title: 'Simple and Effective Exercises for Better Health',
      content: 'Regular physical activity is one of the most important things you can do for your health. Being physically active can improve your brain health.',
      category: 'Fitness',
      imageUrl: 'assets/article3.png',
      publishedDate: DateTime(2023, 4, 15),
      author: 'Dr. Emily Davis',
    ),
  ];

  // Static fallback doctors
  final List<Doctor> _staticDoctors = [
    Doctor(firstName: 'Marcus', lastName: 'Horizon', specialization: 'Chardiologist', rating: 4.7, distanceText: '800m away', photoUrl: 'assets/D3.png'),
    Doctor(firstName: 'Maria', lastName: 'Elena', specialization: 'Psychologist',   rating: 4.7, distanceText: '800m away', photoUrl: 'assets/D4.png'),
    Doctor(firstName: 'Stevi', lastName: 'Jessi',  specialization: 'Orthopedist',   rating: 4.7, distanceText: '800m away', photoUrl: 'assets/D5.png'),
    Doctor(firstName: 'Shruti', lastName: 'Kedia', specialization: 'Therapist',     rating: 4.7, distanceText: '800m away', photoUrl: 'assets/D2.png'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final doctors = await _doctorService.fetchTopDoctors();
      
      if (mounted) {
        setState(() {
          _topDoctors = doctors.isNotEmpty ? doctors : _staticDoctors;
          _recentArticles = _staticArticles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      if (mounted) {
        setState(() {
          _topDoctors = _staticDoctors;
          _recentArticles = _staticArticles;
          _isLoading = false;
        });
      }
    }
  }

  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleExpandPage(article: article),
      ),
    );
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
                    // Still push the map page in case they want to track
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
                      style: const TextStyle(fontSize: 16),
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
              // Emergency Contact Person Button
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
                    
                    // Fallback to 112 if no contact found or error
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
                      style: const TextStyle(fontSize: 16),
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
              onPressed: () {
                Navigator.pop(context);
              },
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.s('hello', 'Hello,'),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            UserSession().fullName.isNotEmpty ? '${UserSession().fullName}!' : AppStrings.s('user_exclamation', 'User!'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(),
                            ),
                          );
                        },
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Healthcare Chat Banner
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1FA59E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 18,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: Icon(
                            FontAwesomeIcons.robot,
                            color: Color(0xFF1FA59E),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.s('discover_chat', 'Discover our health chat'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            FontAwesomeIcons.anglesRight,
                            color: Color(0xFF1FA59E),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Our Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.s('our_features', 'Our features'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              FontAwesomeIcons.clipboardList, // Symptom Checker
                          label: AppStrings.s('symptom_checker', 'Symptom\nChecker'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              FontAwesomeIcons.stethoscope, // Teleconsultation
                          label: AppStrings.s('teleconsultation', 'Teleconsultation'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FindDoctorsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          icon: FontAwesomeIcons
                              .shieldHeart, // Insurance Assistance
                          label: AppStrings.s('insurance_assistance', 'Insurance\nAssistance'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Insurance1Page(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon:
                              FontAwesomeIcons.heartPulse, // Health Monitoring
                          label: AppStrings.s('health_monitoring', 'Health\nMonitoring'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HealthMonitoringPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          icon: FontAwesomeIcons.pills, // Medication Reminders
                          label: AppStrings.s('medication_reminders', 'Medication\nReminders'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MedicationReminderScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FeatureCard(
                          icon: FontAwesomeIcons.calendarCheck,
                          label: AppStrings.s('my_appointments', 'My\nAppointments'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppointmentListPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Find your desire health solution
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.s('find_solution', 'Find the health solutions you need'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.s('search_hint', 'Search doctors, medicine, articles...'),

                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1FA59E)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 217, 218, 217),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF1FA59E),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Service Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ServiceIcon(
                    icon: FontAwesomeIcons.stethoscope, // Doctor
                    label: AppStrings.s('doctor', 'Doctor'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindDoctorsPage(),
                        ),
                      );
                    },
                  ),

                  _ServiceIcon(
                    icon: FontAwesomeIcons.handHoldingMedical,
                    label: AppStrings.s('quick_help', 'Quick Help'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpPage()),
                      );
                    },
                  ),

                  _ServiceIcon(
                    icon: FontAwesomeIcons.hospital, // Hospital
                    label: AppStrings.s('hospital', 'Hospital'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NearbyHospital(),
                        ),
                      );
                    },
                  ),

                  _ServiceIcon(
                    icon: FontAwesomeIcons.truckMedical, // Ambulance
                    label: AppStrings.s('ambulance', 'Ambulance'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AmbulancePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Family Health Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.s('family_health_title', 'Preparation for your family health'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => HelpPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF1FA59E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                AppStrings.s('learn_more', 'Learn more'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/D2.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // No doctors found localization in list view below

            const SizedBox(height: 24),
            // Top Doctor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.s('top_doctor', 'Top Doctor'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopDoctorPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove extra padding
                      minimumSize: const Size(
                        0,
                        0,
                      ), // Optional: shrink button to text size
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // Optional
                    ),
                    child: Text(
                      AppStrings.s('see_all', 'See all'),
                      style: TextStyle(
                        color: Color(0xFF1FA59E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Doctor Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_topDoctors.isEmpty)
                       Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            AppStrings.s('no_doctors', 'No doctors found'), 
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                    for (
                      int i = 0;
                      i < (_topDoctors.length);
                      i++
                    )
                      Row(
                        children: [
                          _DoctorCard(
                            name: _topDoctors[i].fullName,
                            specialty: _topDoctors[i].specialization ?? AppStrings.s('general_label', 'General'),
                            rating: _topDoctors[i].rating.toString(),
                            distance: _topDoctors[i].distanceText ?? AppStrings.s('unknown_label', 'Unknown'),
                            imagePath: _topDoctors[i].photoUrl,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailPage(
                                    doctorId: _topDoctors[i].id,
                                    doctorName: _topDoctors[i].fullName,
                                    speciality: _topDoctors[i].specialization ?? AppStrings.s('general_label', 'General'),
                                    rating: _topDoctors[i].rating,
                                    distanceText: _topDoctors[i].distanceText ?? AppStrings.s('unknown_label', 'Unknown'),
                                    photoUrl: _topDoctors[i].photoUrl,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < _topDoctors.length - 1)
                            const SizedBox(width: 12),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Health Article
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      AppStrings.s('health_article', 'Health Article'),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticlesPage()),
                      );
                      // See all pressed action
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove default padding
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.s('see_all', 'See all'),
                      style: TextStyle(
                        color: Color(0xFF1FA59E),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
              // Health Article List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : _recentArticles.isEmpty
                      ? Center(child: Text(AppStrings.s('no_articles', 'No articles found'), style: TextStyle(color: Colors.grey[600])))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentArticles.length,
                          itemBuilder: (context, index) {
                            return _buildHealthArticleCard(_recentArticles[index]);
                          },
                        ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Phone button - show emergency popup
            _showEmergencyPopup();
            return;
          }

          if (_selectedIndex == index) return; // prevent re-push

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Message()),
              );
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
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.envelope,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
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
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedIndex == 3
                    ? Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.calendarAlt,
                color: _selectedIndex == 3 ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedIndex == 4
                    ? Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.user,
                color: _selectedIndex == 4 ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            label: '',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget _buildHealthArticleCard(Article article) {
    return InkWell(
      onTap: () => _openArticle(article),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: (article.imageUrl != null && article.imageUrl!.startsWith('http'))
                    ? Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Image.asset(
                        article.imageUrl ?? 'assets/placeholder.png', // Fallback asset
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat("MMM dd, yyyy").format(article.publishedDate)} • 5 ${AppStrings.s('min_read', 'min read')}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.bookmark_border,
                color: Color(0xFF1FA59E),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FeatureCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 110, maxHeight: 110),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1FA59E), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1FA59E), size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1FA59E),
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ServiceIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: const Color(0xFF1FA59E), size: 28),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1FA59E)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String rating;
  final String distance;
  final String? imagePath;
  final VoidCallback onPressed;

  const _DoctorCard({
    Key? key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.distance,
    this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16), // for outline tap effect
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 198, 198, 198),
            ), // outline color
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Column(
            children: [
              // Circular profile image with no background color
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: AvatarImage(
                  imageUrl: imagePath,
                  width: 120,
                  height: 120,
                  borderRadius: 60,
                ),
              ),
              const SizedBox(height: 10),
              // Doctor info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Rating pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1FA59E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Distance with location icon
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                distance,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
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
            ],
          ),
        ),
      ),
    );
  }
}
