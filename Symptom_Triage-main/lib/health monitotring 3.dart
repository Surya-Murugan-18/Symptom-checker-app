import 'package:flutter/material.dart';
import 'dart:async';
import 'package:symtom_checker/health%20monitotring%204.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({Key? key}) : super(key: key);

  @override
  State<ConnectDevicePage> createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  bool _bluetoothPermission = false;
  bool _locationPermission = false;
  bool _isSearching = true;
  List<DeviceInfo> _devices = [];
  int? _selectedDeviceIndex;

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
      _devices = [];
    });

    // Search for 5 seconds then show devices
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final strings = AppStrings.data[AppState.selectedLanguage]!;
        setState(() {
          _isSearching = false;
          _devices = [
            DeviceInfo(
              name: 'ESP32 Health Tracker',
              type: strings['iot_device'] ?? 'IoT Device',
              icon: Icons.developer_board,
            ),
            DeviceInfo(
              name: 'Galaxy Watch 5',
              type: strings['smart_watch'] ?? 'Smart Watch',
              icon: Icons.watch,
            ),
            DeviceInfo(
              name: 'Fitbit Charge',
              type: strings['fitness_band'] ?? 'Fitness Band',
              icon: Icons.monitor_heart_outlined,
            ),
          ];
        });
      }
    });
  }

  bool get _canContinue =>
      _bluetoothPermission && _locationPermission && _selectedDeviceIndex != null;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final maxWidth = isDesktop ? 500.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: maxWidth,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 24,
              vertical: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    child: Text(
                      strings['connect_device_title'] ?? 'Connect Your Device',
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
  
                  // Required Permissions 
                  Text(
                    strings['required_permissions'] ?? 'REQUIRED PERMISSIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
  
                  // Bluetooth Permission
                  _buildPermissionCard(
                    icon: Icons.bluetooth,
                    title: strings['bluetooth_access'] ?? 'Bluetooth Access',
                    isSelected: _bluetoothPermission,
                    onTap: () {
                      setState(() {
                        _bluetoothPermission = !_bluetoothPermission;
                      });
                    },
                    isDesktop: isDesktop,
                  ),
                  const SizedBox(height: 12),
  
                  // Location Permission
                  _buildPermissionCard(
                    icon: Icons.location_on_outlined,
                    title: strings['location_access'] ?? 'Location Access',
                    isSelected: _locationPermission,
                    onTap: () {
                      setState(() {
                        _locationPermission = !_locationPermission;
                      });
                    },
                    isDesktop: isDesktop,
                  ),
  
                  const SizedBox(height: 32),
  
                  // Available Devices Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings['available_devices'] ?? 'AVAILABLE DEVICES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_isSearching)
                        Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF199A8E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              strings['searching'] ?? 'Searching...',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF199A8E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
  
                  // Devices List or Placeholder
                  SizedBox(
                    height: 300, // Give it a fixed height within the scroll view
                    child: _isSearching
                        ? _buildSearchingPlaceholder(isDesktop)
                        : _buildDevicesList(isDesktop),
                  ),
  
                  // Continue Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 60 : 56,
                    child: ElevatedButton(
                      onPressed: _canContinue
                          ? () {
                              // Navigate to device connected page
                              final selectedDevice = _devices[_selectedDeviceIndex!];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeviceConnectedPage(
                                    deviceName: selectedDevice.name,
                                    deviceType: selectedDevice.type,
                                    deviceIcon: selectedDevice.icon,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF199A8E),
                        disabledBackgroundColor: const Color(0xFF199A8E).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        strings['continue_btn'] ?? 'Continue',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDesktop,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 20,
          vertical: isDesktop ? 20 : 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF199A8E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF199A8E) : Colors.grey[600],
              size: isDesktop ? 26 : 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 17 : 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF199A8E),
                size: isDesktop ? 24 : 22,
              )
            else
              Container(
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingPlaceholder(bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDevicePlaceholder(isDesktop),
          const SizedBox(height: 12),
          _buildDevicePlaceholder(isDesktop),
          const SizedBox(height: 12),
          _buildDevicePlaceholder(isDesktop),
        ],
      ),
    );
  }

  Widget _buildDevicePlaceholder(bool isDesktop) {
    return Container(
      height: isDesktop ? 80 : 70,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildDevicesList(bool isDesktop) {
    return ListView.separated(
      itemCount: _devices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = _devices[index];
        final isSelected = _selectedDeviceIndex == index;
        return _buildDeviceCard(device, isDesktop, isSelected, () {
          setState(() {
            _selectedDeviceIndex = _selectedDeviceIndex == index ? null : index;
          });
        });
      },
    );
  }

  Widget _buildDeviceCard(DeviceInfo device, bool isDesktop, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 20,
          vertical: isDesktop ? 20 : 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF199A8E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: isDesktop ? 50 : 44,
              height: isDesktop ? 50 : 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                device.icon,
                color: Colors.grey[700],
                size: isDesktop ? 28 : 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.type,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF199A8E),
                size: isDesktop ? 24 : 22,
              )
            else
              Container(
                width: isDesktop ? 24 : 22,
                height: isDesktop ? 24 : 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DeviceInfo {
  final String name;
  final String type;
  final IconData icon;

  DeviceInfo({
    required this.name,
    required this.type,
    required this.icon,
  });
}
