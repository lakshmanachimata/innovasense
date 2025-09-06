class SweatImageModel {
  final int id;
  final String imagePath;
  final String sweatRange;
  final String implications;
  final String recomm;
  final String strategy;
  final String result;
  final String colorcode;

  SweatImageModel({
    required this.id,
    required this.imagePath,
    required this.sweatRange,
    required this.implications,
    required this.recomm,
    required this.strategy,
    required this.result,
    required this.colorcode,
  });

  factory SweatImageModel.fromJson(Map<String, dynamic> json) {
    return SweatImageModel(
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
