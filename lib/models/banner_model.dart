class BannerModel {
  final int id;
  final String imagePath;

  BannerModel({
    required this.id,
    required this.imagePath,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
    };
  }
}

class BannerResponse {
  final int code;
  final String message;
  final List<BannerModel> response;

  BannerResponse({
    required this.code,
    required this.message,
    required this.response,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      response: (json['response'] as List<dynamic>?)
              ?.map((item) => BannerModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
