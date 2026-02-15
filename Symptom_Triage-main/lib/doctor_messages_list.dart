import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';
import 'doctor_chat_detail.dart';
import 'doctor_dashboard.dart';
import 'doctor_consult.dart';
import 'doctor_notifications.dart';
import 'doctor-Profile.dart';

class DoctorMessagesList extends StatefulWidget {
  const DoctorMessagesList({Key? key}) : super(key: key);

  @override
  State<DoctorMessagesList> createState() => _DoctorMessagesListState();
}

class _DoctorMessagesListState extends State<DoctorMessagesList> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;
  final Color _primaryColor = const Color(0xFF199A8E);
  
  List<dynamic> _patients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchPatients();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPatients = _patients.where((patient) {
        final fName = patient['firstName']?.toString().toLowerCase() ?? '';
        final lName = patient['lastName']?.toString().toLowerCase() ?? '';
        final fullName = "$fName $lName";
        return fullName.contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  Future<void> _fetchPatients() async {
    final docId = DoctorSession().doctorId;
    if (docId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/messages/conversations/doctor/$docId"),
        headers: {"Authorization": "Bearer ${DoctorSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _patients = data;
            _filteredPatients = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching patients: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final maxWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF9E9E9E),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              
              // Messages List
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                    ? const Center(child: Text("No conversations found"))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    final fName = patient['firstName'] ?? '';
                    final lName = patient['lastName'] ?? '';
                    final fullName = "$fName $lName".trim();
                    final initials = (fName.isNotEmpty ? fName[0] : "") + (lName.isNotEmpty ? lName[0] : "");
                    
                    return _buildPatientItem(
                      id: patient['id'],
                      name: fullName.isEmpty ? "Patient" : fullName,
                      initials: initials.isEmpty ? "?" : initials.toUpperCase(),
                      photoUrl: patient['photoUrl'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPatientItem({
    required int id,
    required String name,
    required String initials,
    String? photoUrl,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorChatDetail(
              name: name,
              initials: initials,
              isOnline: true,
              patientId: id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Using AvatarImage for dynamic photos
            AvatarImage(
              imageUrl: photoUrl,
              width: 50,
              height: 50,
              borderRadius: 25,
            ),
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Recent", // Placeholder for time
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Click to open chat",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
          _buildNavItem(LucideIcons.messageSquare, 'Messages', 1),
          _buildNavItem(FontAwesomeIcons.calendarCheck, 'Consults', 2),
          _buildNavItem(FontAwesomeIcons.bell, 'Notifications', 3),
          _buildNavItem(FontAwesomeIcons.user, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex == index) return;
        setState(() {
          _selectedIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorDashboard()),
            );
            break;
          case 1:
            // Already here
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorConsult()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DoctorNotifications()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorProfile()),
            );
            break;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 28,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          Icon(
            icon,
            color: isSelected ? _primaryColor : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
