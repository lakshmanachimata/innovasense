import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../viewmodels/manual_test_viewmodel.dart';

class ManualTestScreen extends StatefulWidget {
  const ManualTestScreen({super.key});

  @override
  State<ManualTestScreen> createState() => _ManualTestScreenState();
}

class _ManualTestScreenState extends State<ManualTestScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ManualTestViewModel(),
      child: Scaffold(
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
                  // Header
                  Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          // Back Button
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
                          const SizedBox(width: 16),
                          // Title
                          const Text(
                            'Manual Test',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Title
                          const Text(
                            'Log Your Daily Activities',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Track your water intake, sleep, and steps',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Circular Sliders
                          Consumer<ManualTestViewModel>(
                            builder: (context, viewModel, child) {
                              return Column(
                                children: [
                                  // Water Intake Slider
                                  _buildCircularSlider(
                                    title: 'Water Intake',
                                    subtitle: 'Liters per day',
                                    value: viewModel.waterIntake,
                                    minValue: 1.0,
                                    maxValue: 5.0,
                                    step: 0.5,
                                    onChanged: viewModel.updateWaterIntake,
                                    color: Colors.blue,
                                    icon: Icons.water_drop,
                                  ),
                                  const SizedBox(height: 20),
                                  // Sleep Hours Slider
                                  _buildCircularSlider(
                                    title: 'Sleep Hours',
                                    subtitle: 'Hours per night',
                                    value: viewModel.sleepHours,
                                    minValue: 5.0,
                                    maxValue: 10.0,
                                    step: 0.5,
                                    onChanged: viewModel.updateSleepHours,
                                    color: Colors.purple,
                                    icon: Icons.bedtime,
                                  ),
                                  const SizedBox(height: 20),
                                  // Steps Slider
                                  _buildCircularSlider(
                                    title: 'Daily Steps',
                                    subtitle: 'Steps walked',
                                    value: viewModel.steps.toDouble(),
                                    minValue: 1000.0,
                                    maxValue: 12000.0,
                                    onChanged: (double value) =>
                                        viewModel.updateSteps(value.round()),
                                    color: Colors.green,
                                    icon: Icons.directions_walk,
                                    showKFormat: true,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 60),
                          // Submit Button
                          Consumer<ManualTestViewModel>(
                            builder: (context, viewModel, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : () async {
                                          final success = await viewModel
                                              .submitManualTest();
                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Manual test submitted successfully!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  viewModel.errorMessage ??
                                                      'Failed to submit',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: viewModel.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSlider({
    required String title,
    required String subtitle,
    required double value,
    required double minValue,
    required double maxValue,
    required Function(double) onChanged,
    required Color color,
    required IconData icon,
    bool showKFormat = false,
    double? step, // Optional step for decimal values
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Title and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          // Sleek Circular Slider
          SleekCircularSlider(
            min: minValue,
            max: maxValue,
            initialValue: value,
            onChange: (double newValue) {
              // Apply step rounding if step is specified
              if (step != null) {
                final roundedValue = (newValue / step).round() * step;
                onChanged(roundedValue);
              } else {
                onChanged(newValue.round().toDouble());
              }
            },
            appearance: CircularSliderAppearance(
              size: 150,
              startAngle: 150,
              angleRange: 240,
              customWidths: CustomSliderWidths(
                trackWidth: 6,
                progressBarWidth: 8,
                shadowWidth: 12,
                handlerSize: 16,
              ),
              customColors: CustomSliderColors(
                trackColor: Colors.white.withOpacity(0.3),
                progressBarColor: color,
                dotColor: Colors.white,
                shadowColor: color.withOpacity(0.2),
                shadowMaxOpacity: 0.3,
              ),
              infoProperties: InfoProperties(
                mainLabelStyle: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                bottomLabelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                bottomLabelText: _getUnit(title),
                modifier: (double value) {
                  if (showKFormat) {
                    return _formatKValue(value);
                  } else if (step != null && step < 1.0) {
                    return value.toStringAsFixed(1);
                  } else {
                    return value.round().toString();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUnit(String title) {
    switch (title) {
      case 'Water Intake':
        return 'Liters';
      case 'Sleep Hours':
        return 'Hours';
      case 'Daily Steps':
        return 'Steps';
      default:
        return '';
    }
  }

  String _formatKValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toString();
  }

  String _formatValue(double value, double? step) {
    if (step != null && step < 1.0) {
      // For decimal values, show 1 decimal place
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }
}
