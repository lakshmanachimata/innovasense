import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_history_model.dart';
import '../viewmodels/device_viewmodel.dart';

class HydrationSummaryScreen extends StatefulWidget {
  final UserHistoryModel historyItem;
  const HydrationSummaryScreen({super.key, required this.historyItem});

  @override
  State<HydrationSummaryScreen> createState() => _HydrationSummaryScreenState();
}

class _HydrationSummaryScreenState extends State<HydrationSummaryScreen> {
  @override
  void initState() {
    super.initState();
    
    // Fetch devices for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceViewModel>().fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logged_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Arrow
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // Hydration Summary Text
                        const Text(
                          'Hydration Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/i_top.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Hydration Summary Header
                          const Text(
                            'Hydration Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Image Display
                          if (widget.historyItem.imagePath.isNotEmpty)
                            Container(
                              width: 200,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.historyItem.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          
                          // Measurements Card
                          _buildInfoCard(
                            'Measurements',
                            {
                              'Test ID': widget.historyItem.id,
                              'Device Type': _getDeviceName(widget.historyItem.deviceType),
                              'Test Date': _formatDateTime(widget.historyItem.creationDatetime),
                              'Weight': '${widget.historyItem.weight} kg',
                              'Height': '${widget.historyItem.height} cm',
                              'BMI': '${widget.historyItem.bmi.toStringAsFixed(2)}',
                              'TBSA': '${widget.historyItem.tbsa.toStringAsFixed(2)}',
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Sweat Analysis Card
                          _buildInfoCard(
                            'Sweat Analysis',
                            {
                              'Sweat Position': widget.historyItem.sweatPosition,
                              'Time Taken': '${widget.historyItem.timeTaken} min',
                              'Sweat Rate': '${widget.historyItem.sweatRate.toStringAsFixed(2)} mL/m²/h',
                              'Sweat Loss': '${widget.historyItem.sweatLoss.toStringAsFixed(2)} mL',
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          const SizedBox(height: 8),
                          // Timestamp
                          Text(
                            _formatDateTime(widget.historyItem.creationDatetime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Sweat Loss Section
                          _buildCircularGauge(
                            value: '${widget.historyItem.sweatLoss.toStringAsFixed(2)} mL',
                            label: 'Sweat loss (Approx)',
                            icon: Icons.water_drop,
                            progress: _calculateSweatLossProgress(widget.historyItem.sweatLoss),
                          ),
                          const SizedBox(height: 20),
                          
                          // Sweat Rate Section
                          _buildCircularGauge(
                            value: '${widget.historyItem.sweatRate.toStringAsFixed(2)} mL/m²/h',
                            label: 'Sweat Rate (Approx)',
                            icon: Icons.water,
                            progress: _calculateSweatRateProgress(widget.historyItem.sweatRate),
                          ),
                          const SizedBox(height: 20),
                          
                          // Drink Water Section
                          const Text(
                            'Drink water:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_calculateRecommendedWaterIntake(widget.historyItem.sweatLoss)} mL',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20), // Extra padding at bottom
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularGauge({
    required String value,
    required String label,
    required IconData icon,
    required double progress,
  }) {
    return Column(
      children: [
        // Circular Gauge
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 8),
                ),
              ),
              // Progress Circle
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF60A5FA), // Light blue color
                  ),
                ),
              ),
              // Icon
              Positioned(
                top: 30,
                child: Icon(icon, color: const Color(0xFF60A5FA), size: 40),
              ),
              // Value Text
              Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Label
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  double _calculateSweatLossProgress(double sweatLoss) {
    // Normalize sweat loss to a 0-1 range for progress indicator
    // Assuming normal range is 0-2000 mL
    const maxSweatLoss = 2000.0;
    return (sweatLoss / maxSweatLoss).clamp(0.0, 1.0);
  }

  double _calculateSweatRateProgress(double sweatRate) {
    // Normalize sweat rate to a 0-1 range for progress indicator
    // Assuming normal range is 0-5000 mL/m²/h
    const maxSweatRate = 5000.0;
    return (sweatRate / maxSweatRate).clamp(0.0, 1.0);
  }

  double _calculateRecommendedWaterIntake(double sweatLoss) {
    // Calculate recommended water intake based on sweat loss
    // General recommendation: replace 1.5x the sweat loss
    return (sweatLoss * 1.5).roundToDouble();
  }

  String _getDeviceName(int deviceId) {
    try {
      final deviceViewModel = context.read<DeviceViewModel>();
      final device = deviceViewModel.getDeviceById(deviceId);
      return device?.deviceName ?? 'Device ID: $deviceId';
    } catch (e) {
      return 'Device ID: $deviceId';
    }
  }
}
