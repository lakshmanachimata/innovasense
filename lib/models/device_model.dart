class DeviceModel {
  final int id;
  final String deviceName;
  final String deviceText;

  DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceText,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? 0,
      deviceName: json['device_name'] ?? '',
      deviceText: json['device_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_text': deviceText,
    };
  }

  @override
  String toString() {
    return 'DeviceModel(id: $id, deviceName: $deviceName, deviceText: $deviceText)';
  }
}

class DeviceResponse {
  final int code;
  final String message;
  final List<DeviceModel> response;

  DeviceResponse({
    required this.code,
    required this.message,
    required this.response,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      response: (json['response'] as List<dynamic>?)
              ?.map((device) => DeviceModel.fromJson(device))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'response': response.map((device) => device.toJson()).toList(),
    };
  }
}
