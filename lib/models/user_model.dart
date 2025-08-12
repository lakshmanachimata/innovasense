class UserModel {
  final String username;
  final String cnumber;
  final String userpin;
  final int age;
  final String gender;
  final double height;
  final int weight;

  UserModel({
    required this.username,
    required this.cnumber,
    required this.userpin,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      cnumber: json['cnumber'] ?? '',
      userpin: json['userpin'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      height: (json['height'] ?? 0).toDouble(),
      weight: json['weight'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'cnumber': cnumber,
      'userpin': userpin,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }

  @override
  String toString() {
    return 'UserModel(username: $username, cnumber: $cnumber, age: $age, gender: $gender, height: $height, weight: $weight)';
  }
}
