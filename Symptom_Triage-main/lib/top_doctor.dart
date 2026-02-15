import 'package:flutter/material.dart';
import 'package:symtom_checker/doctordetail.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:symtom_checker/services/doctor_service.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';

import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class TopDoctorPage extends StatefulWidget {
  final String? specialty;

  const TopDoctorPage({Key? key, this.specialty}) : super(key: key);

  @override
  State<TopDoctorPage> createState() => _TopDoctorPageState();
}

class _TopDoctorPageState extends State<TopDoctorPage> {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => isLoading = true);
    try {
      List<Doctor> fetched;
      if (widget.specialty != null) {
        fetched = await _doctorService.searchVerifiedDoctors(widget.specialty!);
      } else {
        fetched = await _doctorService.fetchTopDoctors();
      }
      setState(() {
        doctors = fetched;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching top doctors: $e");
      setState(() {
        doctors = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Localization
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;
    
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button, title, and menu icon
            _buildHeader(context, isMobile, strings),
            // Doctors list
            Expanded(child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _buildDoctorsList(isMobile, isTablet, strings)),
          ],
        ),
      ),
    );
  }

  // Header widget
  Widget _buildHeader(BuildContext context, bool isMobile, Map<String, String> strings) {
    String title = widget.specialty ?? strings['top_doctor']!;
    // Try to translate specialty if possible (e.g. Cardiologist -> இதய நிபுணர்)
    if (widget.specialty != null) {
       title = strings[widget.specialty!.toLowerCase()] ?? widget.specialty!;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 24.0,
        vertical: isMobile ? 12.0 : 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: isMobile ? 20 : 24,
              color: Colors.black,
            ),
            splashRadius: 22, 
          ),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          // Menu icon
          Icon(Icons.more_vert, size: isMobile ? 20 : 24, color: Colors.black),
        ],
      ),
    );
  }

  // Doctors list widget
  Widget _buildDoctorsList(bool isMobile, bool isTablet, Map<String, String> strings) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16.0
            : isTablet
            ? 24.0
            : 32.0,
        vertical: isMobile ? 12.0 : 16.0,
      ),
      child: isTablet
          ? _buildGridView(strings)
          : Column(
              children: List.generate(
                doctors.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 12.0 : 16.0),
                  child: InkWell(
                    onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailPage(
                              doctorId: doctors[index].id,
                              doctorName: doctors[index].fullName,
                              speciality: doctors[index].specialization ?? 'General',
                              rating: doctors[index].rating,
                              distanceText: '800${strings['m']} ${strings['away']}', // Localized
                              photoUrl: doctors[index].photoUrl ?? 'assets/D6.jpg',
                            ),
                          ),
                        );
                    },
                    child: _buildDoctorCard(doctors[index], isMobile, strings),
                  ),
                ),
              ),
            ),
    );
  }

  // Grid view for tablet/desktop
  Widget _buildGridView(Map<String, String> strings) {
     // Calculate ratio to maintain fixed height ~150px
    double width = MediaQuery.of(context).size.width;
    double itemWidth = (width - 48) / 2;
    double desiredHeight = 160; 
    double ratio = itemWidth / desiredHeight;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: ratio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailPage(
                  doctorId: doctors[index].id,
                  doctorName: doctors[index].fullName,
                  speciality: doctors[index].specialization ?? 'General',
                  rating: doctors[index].rating,
                  distanceText: '800${strings['m']} ${strings['away']}',
                  photoUrl: doctors[index].photoUrl ?? 'assets/D6.jpg',
                ),
              ),
            );
          },
          child: _buildDoctorCard(doctors[index], false, strings),
        );
      },
    );
  }

  // Individual doctor card
  Widget _buildDoctorCard(Doctor doctor, bool isMobile, Map<String, String> strings) {
    // Translate specialty if possible
    String spec = doctor.specialization ?? 'General';
    spec = strings[spec.toLowerCase()] ?? spec;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor image and info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Doctor image
            AvatarImage(
              imageUrl: doctor.photoUrl,
              width: isMobile ? 100 : 80,
              height: isMobile ? 100 : 80,
              borderRadius: 8,
            ),
              SizedBox(width: isMobile ? 32 : 16),
              // Doctor details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor name
                    Text(
                      doctor.fullName,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    // Doctor specialty
                    Text(
                      spec, // Localized
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 6 : 10),
                    // Rating and Distance row
                    Wrap(
                      spacing: isMobile ? 8 : 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: isMobile ? 14 : 16,
                              color: const Color(0xFF00BFA5),
                            ),
                            SizedBox(width: isMobile ? 4 : 6),
                            Text(
                              doctor.rating.toString(),
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: isMobile ? 14 : 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: isMobile ? 2 : 6),
                            Flexible(
                              child: Text(
                                '800${strings['m']} ${strings['away']}', // Localized
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Redundant DoctorModel class removed.
