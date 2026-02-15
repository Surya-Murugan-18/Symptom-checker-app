import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  // Device data
  final List<Map<String, dynamic>> _devices = [
    {
      'name': 'ESP32 Health Tracker',
      'icon': Icons.developer_board,
      'battery': 100,
      'isConnected': true,
      'lastSyncedKey': 'just_now',
    },
    {
      'name': 'Galaxy Watch 5',
      'icon': Icons.watch,
      'battery': 84,
      'isConnected': false,
      'lastSyncedKey': 'just_now',
    },
    {
      'name': 'Fitbit Charge',
      'icon': Icons.monitor_heart_outlined,
      'battery': 92,
      'isConnected': false,
      'lastSyncedKey': 'just_now', // Simplified for now since relative time needs a formatter
    },
  ];

  void _toggleConnection(int index) {
    setState(() {
      _devices[index]['isConnected'] = !_devices[index]['isConnected'];
      if (_devices[index]['isConnected']) {
        _devices[index]['lastSyncedKey'] = 'just_now';
      }
    });
  }

  void _addNewDevice() {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    // Handle add new device functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings['add_new_device'] ?? 'Add New Device'),
        content: Text(strings['device_pairing_msg'] ?? 'Device pairing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              strings['ok'] ?? 'OK',
              style: const TextStyle(color: Color(0xFF199A8E)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['connected_devices_title'] ?? 'Connected Devices',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 16,
            ),
            children: [
              // Device Cards
              ..._devices.asMap().entries.map((entry) {
                final index = entry.key;
                final device = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDeviceCard(
                    strings: strings,
                    name: device['name'],
                    icon: device['icon'],
                    battery: device['battery'],
                    isConnected: device['isConnected'],
                    lastSynced: strings[device['lastSyncedKey']] ?? device['lastSyncedKey'],
                    onButtonPressed: () => _toggleConnection(index),
                  ),
                );
              }).toList(),

              const SizedBox(height: 8),

              // Add New Device Button
              _buildAddDeviceButton(strings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required Map<String, String> strings,
    required String name,
    required IconData icon,
    required int battery,
    required bool isConnected,
    required String lastSynced,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Header
          Row(
            children: [
              // Device Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF199A8E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Device Info
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Battery Icon and Percentage
                        const Icon(
                          Icons.battery_std,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$battery%',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),

                        if (isConnected) ...[
                          const SizedBox(width: 12),
                          // Connected Status
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF199A8E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings['connected_status'] ?? 'Connected',
                            style: const TextStyle(
                              color: Color(0xFF199A8E),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Last Synced
          Text(
            '${strings['last_synced'] ?? 'Last synced'}: $lastSynced',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          // Connect/Disconnect Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.white : const Color(0xFF199A8E),
                foregroundColor: isConnected ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isConnected
                      ? const BorderSide(color: Color(0xFFE0E0E0), width: 1)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                isConnected ? (strings['disconnect_btn'] ?? 'Disconnect') : (strings['connect_btn'] ?? 'Connect'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isConnected ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDeviceButton(Map<String, String> strings) {
    return InkWell(
      onTap: _addNewDevice,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF199A8E),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: DashedBorder(
          color: const Color(0xFF199A8E),
          strokeWidth: 2,
          dashLength: 8,
          gapLength: 6,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: Color(0xFF199A8E),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  strings['add_new_device'] ?? 'Add New Device',
                  style: const TextStyle(
                    color: Color(0xFF199A8E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Dashed Border Widget
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 3,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BorderRadius borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height),
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ),
      );

    // Create dashed path
    Path dashedPath = Path();
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final double nextDistance = distance + dashLength;
        final PathMetric extractPath = pathMetric;
        dashedPath.addPath(
          extractPath.extractPath(distance, nextDistance),
          Offset.zero,
        );
        distance = nextDistance + gapLength;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
