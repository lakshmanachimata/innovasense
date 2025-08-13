class UserHistoryModel {
  final int id;
  final int userId;
  final int weight;
  final int height;
  final int sweatPosition;
  final int timeTaken;
  final double bmi;
  final double tbsa;
  final String imagePath;
  final double sweatRate;
  final double sweatLoss;
  final int deviceType;
  final int imageId;
  final String creationDatetime;

  UserHistoryModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.height,
    required this.sweatPosition,
    required this.timeTaken,
    required this.bmi,
    required this.tbsa,
    required this.imagePath,
    required this.sweatRate,
    required this.sweatLoss,
    required this.deviceType,
    required this.imageId,
    required this.creationDatetime,
  });

  factory UserHistoryModel.fromJson(Map<String, dynamic> json) {
    return UserHistoryModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      weight: json['weight'] ?? 0,
      height: json['height'] ?? 0,
      sweatPosition: json['sweat_position'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      bmi: (json['bmi'] ?? 0.0).toDouble(),
      tbsa: (json['tbsa'] ?? 0.0).toDouble(),
      imagePath: json['image_path'] ?? '',
      sweatRate: (json['sweat_rate'] ?? 0.0).toDouble(),
      sweatLoss: (json['sweat_loss'] ?? 0.0).toDouble(),
      deviceType: json['device_type'] ?? 0,
      imageId: json['image_id'] ?? 0,
      creationDatetime: json['creation_datetime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'height': height,
      'sweat_position': sweatPosition,
      'time_taken': timeTaken,
      'bmi': bmi,
      'tbsa': tbsa,
      'image_path': imagePath,
      'sweat_rate': sweatRate,
      'sweat_loss': sweatLoss,
      'device_type': deviceType,
      'image_id': imageId,
      'creation_datetime': creationDatetime,
    };
  }

  @override
  String toString() {
    return 'UserHistoryModel(id: $id, userId: $userId, bmi: $bmi, tbsa: $tbsa, sweatRate: $sweatRate, sweatLoss: $sweatLoss, creationDatetime: $creationDatetime)';
  }
}

class UserHistoryResponse {
  final int code;
  final String message;
  final List<UserHistoryModel> response;

  UserHistoryResponse({
    required this.code,
    required this.message,
    required this.response,
  });

  factory UserHistoryResponse.fromJson(Map<String, dynamic> json) {
    List<UserHistoryModel> historyList = [];
    
    // Handle different response types gracefully
    if (json['response'] != null) {
      if (json['response'] is List) {
        // Normal case: response is a list
        historyList = (json['response'] as List)
            .map((item) => UserHistoryModel.fromJson(item))
            .toList();
      } else if (json['response'] is int) {
        // API returned count instead of list - create empty list
        print('API returned count: ${json['response']}, creating empty history list');
        historyList = [];
      } else if (json['response'] is Map) {
        // API returned single object - wrap in list
        print('API returned single object, wrapping in list');
        historyList = [UserHistoryModel.fromJson(json['response'])];
      } else {
        // Unknown type - log and create empty list
        print('Unknown response type: ${json['response'].runtimeType}, creating empty history list');
        historyList = [];
      }
    }
    
    return UserHistoryResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      response: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'response': response.map((item) => item.toJson()).toList(),
    };
  }
}
