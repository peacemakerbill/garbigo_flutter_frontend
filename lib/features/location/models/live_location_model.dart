class LiveLocationModel {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LiveLocationModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LiveLocationModel.fromJson(Map<String, dynamic> json) {
    return LiveLocationModel(
      userId: json['userId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}