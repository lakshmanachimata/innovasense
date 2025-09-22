class ManualTestModel {
  final double waterIntake; // 1.0-4.0 liters (0.5 step)
  final double sleepHours; // 6.0-10.0 hours (0.5 step)
  final int steps; // 1000-10000 steps

  ManualTestModel({
    required this.waterIntake,
    required this.sleepHours,
    required this.steps,
  });

  // Default values (lowest values as requested)
  factory ManualTestModel.defaultValues() {
    return ManualTestModel(waterIntake: 1.0, sleepHours: 5.0, steps: 1000);
  }

  Map<String, dynamic> toJson() {
    return {
      'waterIntake': waterIntake,
      'sleepHours': sleepHours,
      'steps': steps,
    };
  }

  factory ManualTestModel.fromJson(Map<String, dynamic> json) {
    return ManualTestModel(
      waterIntake: (json['waterIntake'] ?? 1.0).toDouble(),
      sleepHours: (json['sleepHours'] ?? 6.0).toDouble(),
      steps: json['steps'] ?? 1000,
    );
  }

  ManualTestModel copyWith({
    double? waterIntake,
    double? sleepHours,
    int? steps,
  }) {
    return ManualTestModel(
      waterIntake: waterIntake ?? this.waterIntake,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
    );
  }

  @override
  String toString() {
    return 'ManualTestModel(waterIntake: $waterIntake, sleepHours: $sleepHours, steps: $steps)';
  }
}
