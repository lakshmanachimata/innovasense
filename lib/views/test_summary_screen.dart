import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/hydration_viewmodel.dart';
import 'home_screen.dart';

class TestSummaryScreen extends StatefulWidget {
  final HydrationViewModel hydrationViewModel;
  const TestSummaryScreen({super.key, required this.hydrationViewModel});

  @override
  State<TestSummaryScreen> createState() => _TestSummaryScreenState();
}

class _TestSummaryScreenState extends State<TestSummaryScreen> {
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // innovosens Text
                        const Text(
                          'innovosens',
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
                          // Test Summary Header
                          const Text(
                            'Test Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Hydration Data Cards (if available)
                          Consumer<HydrationViewModel>(
                            builder: (context, hydrationViewModel, child) {
                              if (hydrationViewModel.hasData) {
                                return Column(
                                  children: [
                                    // Basic Info Card
                                    _buildInfoCard('Test Results', {
                                      'BMI':
                                          '${hydrationViewModel.hydrationData?.bmi.toStringAsFixed(2) ?? 'N/A'}',
                                      'TBSA':
                                          '${hydrationViewModel.hydrationData?.tbsa.toStringAsFixed(2) ?? 'N/A'}',
                                      'Sweat Rate':
                                          '${hydrationViewModel.hydrationData?.sweatRate.toStringAsFixed(2) ?? 'N/A'} mL/m²/h',
                                      'Sweat Loss':
                                          '${hydrationViewModel.hydrationData?.sweatLoss.toStringAsFixed(2) ?? 'N/A'} mL',
                                    }),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: 8),
                          // Timestamp
                          const Text(
                            '2025-07-30 15:33:21',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Sweat Loss Section
                          _buildCircularGauge(
                            value:
                                '${widget.hydrationViewModel.hydrationData?.sweatRate.toStringAsFixed(2) ?? 'N/A'} mL/m²/h',
                            label: 'Sweat loss (Approx)',
                            icon: Icons.water_drop,
                            progress: 0.7, // 70% filled
                          ),
                          const SizedBox(height: 20),
                          // Sweat Rate Section
                          _buildCircularGauge(
                            value:
                                '${widget.hydrationViewModel.hydrationData?.sweatLoss.toStringAsFixed(2) ?? 'N/A'} mL',
                            label: 'Sweat Rate (Approx)',
                            icon: Icons.water,
                            progress: 0.65, // 65% filled
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
                            '${widget.hydrationViewModel.sweatRateSummary[0].highLimit ?? 'N/A'} mL',
                            style: TextStyle(
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
}
