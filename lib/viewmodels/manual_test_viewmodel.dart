import 'package:flutter/material.dart';

import '../models/manual_test_model.dart';
import '../services/manual_test_service.dart';
import '../services/user_service.dart';

class ManualTestViewModel extends ChangeNotifier {
  ManualTestModel _manualTestData = ManualTestModel.defaultValues();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ManualTestModel get manualTestData => _manualTestData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Water intake (1.0-4.0 liters)
  double get waterIntake => _manualTestData.waterIntake;

  // Sleep hours (6.0-10.0 hours)
  double get sleepHours => _manualTestData.sleepHours;

  // Steps (1000-10000 steps)
  int get steps => _manualTestData.steps;

  // Update water intake
  void updateWaterIntake(double value) {
    if (value >= 1.0 && value <= 5.0) {
      _manualTestData = _manualTestData.copyWith(waterIntake: value);
      notifyListeners();
    }
  }

  // Update sleep hours
  void updateSleepHours(double value) {
    if (value >= 5.0 && value <= 10.0) {
      _manualTestData = _manualTestData.copyWith(sleepHours: value);
      notifyListeners();
    }
  }

  // Update steps
  void updateSteps(int value) {
    if (value >= 1000 && value <= 12000) {
      _manualTestData = _manualTestData.copyWith(steps: value);
      notifyListeners();
    }
  }

  // Submit manual test data
  Future<bool> submitManualTest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get user details
      final userDetails = await UserService.getUserDetails();
      if (userDetails == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final email = userDetails['email'] ?? '';
      if (email.isEmpty) {
        _errorMessage = 'User email not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Submit data
      final result = await ManualTestService.submitManualTest(
        manualTestData: _manualTestData,
        email: email,
      );

      _isLoading = false;

      if (result['success']) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to submit manual test';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  // Reset to default values
  void resetToDefaults() {
    _manualTestData = ManualTestModel.defaultValues();
    _errorMessage = null;
    notifyListeners();
  }
}
