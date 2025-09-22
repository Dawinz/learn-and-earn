class User {
  final String deviceId;
  final String publicKey;
  final String? mobileNumberHash;
  final DateTime? numberLockedUntil;
  final bool isEmulator;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  User({
    required this.deviceId,
    required this.publicKey,
    this.mobileNumberHash,
    this.numberLockedUntil,
    required this.isEmulator,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      deviceId: json['deviceId'],
      publicKey: json['publicKey'],
      mobileNumberHash: json['mobileNumberHash'],
      numberLockedUntil: json['numberLockedUntil'] != null
          ? DateTime.parse(json['numberLockedUntil'])
          : null,
      isEmulator: json['isEmulator'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: DateTime.parse(json['lastActiveAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'publicKey': publicKey,
      'mobileNumberHash': mobileNumberHash,
      'numberLockedUntil': numberLockedUntil?.toIso8601String(),
      'isEmulator': isEmulator,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  bool get hasMobileNumber => mobileNumberHash != null;
  bool get isNumberLocked =>
      numberLockedUntil != null && numberLockedUntil!.isAfter(DateTime.now());
}
