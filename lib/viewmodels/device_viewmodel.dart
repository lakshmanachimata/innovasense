import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';

class DeviceViewModel extends ChangeNotifier {
  List<DeviceModel> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<DeviceModel> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDevices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final deviceResponse = await DeviceService.getDevices();
      _devices = deviceResponse.response;
      
      print('Devices loaded: ${_devices.length}');
      for (var device in _devices) {
        print('Device: ${device.deviceName} (ID: ${device.id})');
      }
    } catch (e) {
      _error = e.toString();
      print('Error in DeviceViewModel: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DeviceModel? getDeviceById(int id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
