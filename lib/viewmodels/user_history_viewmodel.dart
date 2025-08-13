import 'package:flutter/material.dart';
import '../models/user_history_model.dart';
import '../services/user_history_service.dart';

class UserHistoryViewModel extends ChangeNotifier {
  List<UserHistoryModel> _userHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _hasData = false;

  // Getters
  List<UserHistoryModel> get userHistory => _userHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _hasData;
  int get historyCount => _userHistory.length;

  // Fetch user history
  Future<void> fetchUserHistory() async {
    try {
      setLoading(true);
      _error = null;

      final response = await UserHistoryService.getUserHistory();
      
      if (response.code == 0) {
        _userHistory = response.response;
        _hasData = _userHistory.isNotEmpty;
        
        if (_userHistory.isEmpty) {
          print('User history loaded: 0 records (empty history)');
          _error = 'No history records found for this user';
        } else {
          print('User history loaded: ${_userHistory.length} records');
        }
      } else {
        _error = response.message;
        _hasData = false;
      }
    } catch (e) {
      _error = e.toString();
      _hasData = false;
      print('Error in ViewModel: $_error');
    } finally {
      setLoading(false);
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _userHistory = [];
    _error = null;
    _hasData = false;
    _isLoading = false;
    notifyListeners();
  }

  // Get formatted data for display
  List<Map<String, dynamic>> getFormattedHistory() {
    return _userHistory.map((history) => {
      'ID': history.id,
      'Date': _formatDateTime(history.creationDatetime),
      'BMI': history.bmi.toStringAsFixed(2),
      'TBSA': history.tbsa.toStringAsFixed(2),
      'Sweat Rate': '${history.sweatRate.toStringAsFixed(2)} mL/m²/h',
      'Sweat Loss': '${history.sweatLoss.toStringAsFixed(2)} mL',
      'Weight': '${history.weight} kg',
      'Height': '${history.height} cm',
      'Device Type': history.deviceType,
      'Time Taken': '${history.timeTaken} min',
    }).toList();
  }

  // Format datetime string
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  // Get history by date range (optional)
  List<UserHistoryModel> getHistoryByDateRange(DateTime startDate, DateTime endDate) {
    return _userHistory.where((history) {
      try {
        final historyDate = DateTime.parse(history.creationDatetime);
        return historyDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               historyDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get latest history (last 5 records)
  List<UserHistoryModel> getLatestHistory({int count = 5}) {
    final sortedHistory = List<UserHistoryModel>.from(_userHistory);
    sortedHistory.sort((a, b) => b.creationDatetime.compareTo(a.creationDatetime));
    return sortedHistory.take(count).toList();
  }

  // Get average BMI
  double getAverageBMI() {
    if (_userHistory.isEmpty) return 0.0;
    final totalBMI = _userHistory.fold(0.0, (sum, history) => sum + history.bmi);
    return totalBMI / _userHistory.length;
  }

  // Get average sweat rate
  double getAverageSweatRate() {
    if (_userHistory.isEmpty) return 0.0;
    final totalSweatRate = _userHistory.fold(0.0, (sum, history) => sum + history.sweatRate);
    return totalSweatRate / _userHistory.length;
  }
}
