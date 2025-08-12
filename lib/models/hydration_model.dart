class HydrationData {
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

  HydrationData({
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

  factory HydrationData.fromJson(Map<String, dynamic> json) {
    return HydrationData(
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
    return 'HydrationData(id: $id, userId: $userId, weight: $weight, height: $height, bmi: $bmi, tbsa: $tbsa, sweatRate: $sweatRate, sweatLoss: $sweatLoss)';
  }
}

class SweatSummary {
  final int id;
  final String imagePath;
  final String sweatRange;
  final String implications;
  final String recomm;
  final String strategy;
  final String result;
  final String colorcode;

  SweatSummary({
    required this.id,
    required this.imagePath,
    required this.sweatRange,
    required this.implications,
    required this.recomm,
    required this.strategy,
    required this.result,
    required this.colorcode,
  });

  factory SweatSummary.fromJson(Map<String, dynamic> json) {
    return SweatSummary(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      sweatRange: json['sweat_range'] ?? '',
      implications: json['implications'] ?? '',
      recomm: json['recomm'] ?? '',
      strategy: json['strategy'] ?? '',
      result: json['result'] ?? '',
      colorcode: json['colorcode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'sweat_range': sweatRange,
      'implications': implications,
      'recomm': recomm,
      'strategy': strategy,
      'result': result,
      'colorcode': colorcode,
    };
  }
}

class SweatRateSummary {
  final int id;
  final int lowLimit;
  final int highLimit;
  final String hydStatus;
  final String comments;
  final String recomm;
  final String color;

  SweatRateSummary({
    required this.id,
    required this.lowLimit,
    required this.highLimit,
    required this.hydStatus,
    required this.comments,
    required this.recomm,
    required this.color,
  });

  factory SweatRateSummary.fromJson(Map<String, dynamic> json) {
    return SweatRateSummary(
      id: json['id'] ?? 0,
      lowLimit: json['low_limit'] ?? 0,
      highLimit: json['high_limit'] ?? 0,
      hydStatus: json['hyd_status'] ?? '',
      comments: json['comments'] ?? '',
      recomm: json['recomm'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'low_limit': lowLimit,
      'high_limit': highLimit,
      'hyd_status': hydStatus,
      'comments': comments,
      'recomm': recomm,
      'color': color,
    };
  }
}
