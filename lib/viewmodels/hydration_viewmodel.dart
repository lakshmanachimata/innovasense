import 'package:flutter/material.dart';
import '../models/hydration_model.dart';

class HydrationViewModel extends ChangeNotifier {
  HydrationData? _hydrationData;
  List<SweatSummary> _sweatSummary = [];
  List<SweatRateSummary> _sweatRateSummary = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  HydrationData? get hydrationData => _hydrationData;
  List<SweatSummary> get sweatSummary => _sweatSummary;
  List<SweatRateSummary> get sweatRateSummary => _sweatRateSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _hydrationData != null;

  // Set hydration data from API response
  void setHydrationData(Map<String, dynamic> response) {
    try {
      _error = null;
      
      if (response['code'] == 0) {
        // Parse main response data
        _hydrationData = HydrationData.fromJson(response['response']);
        
        // Parse sweat summary
        if (response['sweatsummary'] != null) {
          _sweatSummary = (response['sweatsummary'] as List)
              .map((item) => SweatSummary.fromJson(item))
              .toList();
        }
        
        // Parse sweat rate summary
        if (response['sweatratesummary'] != null) {
          _sweatRateSummary = (response['sweatratesummary'] as List)
              .map((item) => SweatRateSummary.fromJson(item))
              .toList();
        }
        
        print('Hydration data set successfully: ${_hydrationData?.id}');
        print('Sweat summary count: ${_sweatSummary.length}');
        print('Sweat rate summary count: ${_sweatRateSummary.length}');
      } else {
        _error = response['message'] ?? 'Unknown error';
        print('Error setting hydration data: $_error');
      }
    } catch (e) {
      _error = 'Failed to parse hydration data: $e';
      print('Exception setting hydration data: $_error');
    }
    
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _hydrationData = null;
    _sweatSummary = [];
    _sweatRateSummary = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get formatted data for display
  Map<String, dynamic> getFormattedData() {
    if (_hydrationData == null) return {};
    
    return {
      'basic_info': {
        'ID': _hydrationData!.id,
        'User ID': _hydrationData!.userId,
        'Device Type': _hydrationData!.deviceType,
        'Creation Date': _hydrationData!.creationDatetime,
      },
      'measurements': {
        'Weight (kg)': _hydrationData!.weight,
        'Height (cm)': _hydrationData!.height,
        'BMI': _hydrationData!.bmi.toStringAsFixed(2),
        'TBSA': _hydrationData!.tbsa.toStringAsFixed(2),
      },
      'sweat_analysis': {
        'Sweat Position': _hydrationData!.sweatPosition,
        'Time Taken (min)': _hydrationData!.timeTaken,
        'Sweat Rate': '${_hydrationData!.sweatRate.toStringAsFixed(2)} mL/m²/h',
        'Sweat Loss': '${_hydrationData!.sweatLoss.toStringAsFixed(2)} mL',
      },
      'sweat_summary': _sweatSummary,
      'sweat_rate_summary': _sweatRateSummary,
    };
  }
}
