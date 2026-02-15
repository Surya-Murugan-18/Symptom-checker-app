import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class AmbulancePage extends StatefulWidget {
  const AmbulancePage({Key? key}) : super(key: key);

  @override
  State<AmbulancePage> createState() => _AmbulancePageState();
}

class _AmbulancePageState extends State<AmbulancePage> {
final MapController _mapController = MapController();

  final TextEditingController _searchController = TextEditingController();
  
  // Default location (Alexandria, Virginia)
  final LatLng _currentLocation = const LatLng(13.0105, 80.1234);
  final String _address = "Sairam Campus , Sai leo Nagar , West Tambaram, Chennai - 600045";
  
List<Marker> _markers = [];
List<CircleMarker> _circles = [];


  @override
  void initState() {
    super.initState();
    _initializeMapElements();
  }

  void _initializeMapElements() {
  // Clear old data (important if rebuild happens)
  _markers.clear();
  _circles.clear();

  // 📍 Current location marker
  _markers.add(
    Marker(
      point: _currentLocation,
      width: 40,
      height: 40,
      child: const Icon(
        Icons.my_location,
        color: Colors.teal,
        size: 36,
      ),
    ),
  );

  // 🏥 Nearby hospital 1
  _markers.add(
    Marker(
      point: const LatLng(13.0120, 80.1210),
      width: 40,
      height: 40,
      child: const Icon(
        Icons.local_hospital,
        color: Colors.red,
        size: 36,
      ),
    ),
  );

  // 🏥 Nearby hospital 2
  _markers.add(
    Marker(
      point: const LatLng(13.0085, 80.1255),
      width: 40,
      height: 40,
      child: const Icon(
        Icons.local_hospital,
        color: Colors.red,
        size: 36,
      ),
    ),
  );

  // 🔵 Radius circle (1.5 km)
  _circles.add(
    CircleMarker(
      point: _currentLocation,
      radius: 1500, // meters
      color: const Color(0xFF00BFA5).withOpacity(0.15),
      borderStrokeWidth: 2,
      borderColor: const Color(0xFF00BFA5),
    ),
  );
}



  @override
  void dispose() {
    _searchController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            _buildAppBar(context, isDesktop, strings),
            
            // Map Section
            Expanded(
              child: Stack(
                children: [
                  // Google Map
                FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _currentLocation,
    initialZoom: 14,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.symtom_checker',
    ),
    MarkerLayer(markers: _markers),
    CircleLayer(circles: _circles),
  ],
),



                  
                  // Search Bar Overlay
                  Positioned(
                    top: 16,
                    left: isDesktop ? screenWidth * 0.25 : 16,
                    right: isDesktop ? screenWidth * 0.25 : 16,
                    child: _buildSearchBar(isDesktop, strings),
                  ),
                ],
              ),
            ),
            
            // Bottom Address Confirmation Section
            _buildAddressConfirmation(context, isDesktop, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDesktop, Map<String, String> strings) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
  children: [
    IconButton(
      onPressed: () {
        Navigator.pop(context); // 👈 back action
      },
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 20,
      ),
      splashRadius: 22, // nice touch effect
     
    ),
    Expanded(
      child: Center(
        child: Text(
          AppStrings.s('ambulance_page_title', 'Ambulance'),
          style: TextStyle(
            fontSize: isDesktop ? 22 : 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    ),
    const SizedBox(width: 48), // balance IconButton width
  ],
),

    );
  }

  Widget _buildSearchBar(bool isDesktop, Map<String, String> strings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.s('search_location_hint', 'Search location, ZIP code...'),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: isDesktop ? 24 : 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isDesktop ? 20 : 16,
          ),
        ),
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAddressConfirmation(BuildContext context, bool isDesktop, Map<String, String> strings) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.s('confirm_address_title', 'Confirm your address'),
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          
          // Address Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFE53935),
                    size: 24,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: Text(
                    _address,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          
          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle location confirmation
                _confirmLocation(context, strings);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 20 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
                child: Text(
                AppStrings.s('confirm_location_btn', 'Confirm Location'),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Bottom indicator (iOS style)
          if (!isDesktop) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmLocation(BuildContext context, Map<String, String> strings) {
    // Show confirmation dialog or navigate to next screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppStrings.s('location_confirmed_title', 'Location Confirmed'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${AppStrings.s('ambulance_request_sent_msg', 'Ambulance request has been sent to:')}\n\n$_address',
          style: const TextStyle(
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.s('ok', 'OK'),
              style: const TextStyle(
                color: Color(0xFF00BFA5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
