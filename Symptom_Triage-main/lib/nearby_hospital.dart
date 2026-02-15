import 'package:flutter/material.dart';
import 'hospital_map_view.dart';
import 'package:symtom_checker/language/app_strings.dart';

const Color appColor = Color(0xFF199A8E);
const Color titleColor = Colors.black;
const Color backgroundColor = Colors.white;

class NearbyHospital extends StatelessWidget {
  const NearbyHospital({Key? key}) : super(key: key);

  static void _showCallDialog(BuildContext context, String hospitalName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(AppStrings.s('call_hospital_title', 'Call Hospital')),
          content: Text(AppStrings.s('calling_hospital_msg', 'Calling {hospitalName}...').replaceAll('{hospitalName}', hospitalName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
              AppStrings.s('ok', 'OK'),
              style: TextStyle(
                color: Colors.black, // 👈 black color
                fontWeight: FontWeight.w600,
              ),
            ),
            ),
          ],
        );
      },
    );
  }

  static List<HospitalData> _getHospitals() {
    return [
      HospitalData(
        name: 'Madras Medical College ',
        location: AppStrings.s('location_chennai_tn', 'Chennai, Tamil Nadu'),
        rating: '5.0 (6K)',
        imageUrl: 'assets/clinic1.jpg',
        latitude: 13.0827,
        longitude: 80.2707,
      ),
      HospitalData(
        name: 'Stanley Medical College',
        location: AppStrings.s('location_chennai_tn', 'Chennai, Tamil Nadu'),
        rating: '4.9 (5K)',
        imageUrl: 'assets/clinic2.jpg',
        latitude: 13.1200,
        longitude: 80.2865,
      ),
      HospitalData(
        name: 'Kilpauk Medical College',
        location: AppStrings.s('location_chennai_tn', 'Chennai, Tamil Nadu'),
        rating: '4.8 (4K)',
        imageUrl: 'assets/clinic1.jpg',
        latitude: 13.0780,
        longitude: 80.2410,
      ),
      HospitalData(
        name: 'Christian Medical College ',
        location: AppStrings.s('location_vellore_tn', 'Vellore, Tamil Nadu'),
        rating: '5.0 (8K)',
        imageUrl: 'assets/clinic2.jpg',
        latitude: 12.9165,
        longitude: 79.1325,
      ),
      HospitalData(
        name: 'Tirunelveli Medical College',
        location: AppStrings.s('location_tirunelveli_tn', 'Tirunelveli, Tamil Nadu'),
        rating: '4.8 (3K)',
        imageUrl: 'assets/clinic1.jpg',
        latitude: 8.7139,
        longitude: 77.7567,
      ),
      HospitalData(
        name: 'Sri Ramachandra Medical College',
        location: AppStrings.s('location_chennai_tn', 'Chennai, Tamil Nadu'),
        rating: '5.0 (6K)',
        imageUrl: 'assets/clinic2.jpg',
        latitude: 13.0316,
        longitude: 80.1810,
      ),
      HospitalData(
        name: 'Erode Government Hospital',
        location: AppStrings.s('location_erode_tn', 'Erode, Tamil Nadu'),
        rating: '4.7 (2K)',
        imageUrl: 'assets/hospital7.jpg',
        latitude: 11.3410,
        longitude: 77.7172,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final hospitals = _getHospitals();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.s('nearby_hospitals_title', 'Nearby Hospitals'),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hospital List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              itemCount: hospitals.length,
              addRepaintBoundaries: true,
              itemBuilder: (context, index) {
                return _buildHospitalCard(hospitals[index], isSmallScreen, index, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHospitalCard(HospitalData hospital, bool isSmallScreen, int hospitalIndex, BuildContext context) {
    final imageSize = isSmallScreen ? 80.0 : 100.0;
    final cardHeight = isSmallScreen ? 120.0 : 140.0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalMapView(
              hospitalName: hospital.name,
              hospitalAddress: hospital.location,
              hospitalLat: hospital.latitude,
              hospitalLng: hospital.longitude,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
        height: cardHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Hospital Image
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 18.0 : 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: _getHospitalImageColor(hospitalIndex),
                  child: Image.asset(
                    hospital.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: isSmallScreen ? 30 : 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Hospital Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8.0 : 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hospital.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: isSmallScreen ? 12 : 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hospital.location,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: isSmallScreen ? 12 : 14, color: appColor),
                        SizedBox(width: 4),
                        Text(
                          hospital.rating,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Call Button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 28.0 : 12.0),
              child: FloatingActionButton(
                mini: isSmallScreen,
                backgroundColor: appColor,
                onPressed: () {
                  _showCallDialog(context, hospital.name);
                },
                child: Icon(
                  Icons.phone,
                  color: backgroundColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getHospitalImageColor(int index) {
    final colors = [
      Colors.blue[100],
      Colors.purple[100],
      Colors.green[100],
      Colors.pink[100],
      Colors.blue[50],
      Colors.cyan[100],
      Colors.purple[100],
    ];
    return colors[index % colors.length] ?? Colors.grey[100]!;
  }
}

class HospitalData {
  final String name;
  final String location;
  final String rating;
  final String imageUrl;
  final double latitude;
  final double longitude;

  HospitalData({
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}
