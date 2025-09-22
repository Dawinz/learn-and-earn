enum PayoutStatus { pending, paid, rejected }

extension PayoutStatusExtension on PayoutStatus {
  String get value {
    switch (this) {
      case PayoutStatus.pending:
        return 'pending';
      case PayoutStatus.paid:
        return 'paid';
      case PayoutStatus.rejected:
        return 'rejected';
    }
  }

  static PayoutStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PayoutStatus.pending;
      case 'paid':
        return PayoutStatus.paid;
      case 'rejected':
        return PayoutStatus.rejected;
      default:
        throw ArgumentError('Invalid payout status: $value');
    }
  }
}

class Payout {
  final String id;
  final String deviceId;
  final double amountUsd;
  final PayoutStatus status;
  final String? reason;
  final DateTime requestedAt;
  final DateTime? paidAt;
  final String? txRef;
  final String? adminNotes;
  final String signature;
  final String nonce;

  Payout({
    required this.id,
    required this.deviceId,
    required this.amountUsd,
    required this.status,
    this.reason,
    required this.requestedAt,
    this.paidAt,
    this.txRef,
    this.adminNotes,
    required this.signature,
    required this.nonce,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['_id'] ?? json['id'],
      deviceId: json['deviceId'],
      amountUsd: json['amountUsd'].toDouble(),
      status: PayoutStatusExtension.fromString(json['status']),
      reason: json['reason'],
      requestedAt: DateTime.parse(json['requestedAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      txRef: json['txRef'],
      adminNotes: json['adminNotes'],
      signature: json['signature'],
      nonce: json['nonce'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'amountUsd': amountUsd,
      'status': status.value,
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'txRef': txRef,
      'adminNotes': adminNotes,
      'signature': signature,
      'nonce': nonce,
    };
  }

  bool get isPending => status == PayoutStatus.pending;
  bool get isPaid => status == PayoutStatus.paid;
  bool get isRejected => status == PayoutStatus.rejected;
}

class CooldownStatus {
  final bool isOnCooldown;
  final DateTime? nextPayoutAt;
  final String? reason;
  final int cooldownHours;

  CooldownStatus({
    required this.isOnCooldown,
    this.nextPayoutAt,
    this.reason,
    required this.cooldownHours,
  });

  factory CooldownStatus.fromJson(Map<String, dynamic> json) {
    return CooldownStatus(
      isOnCooldown: json['isOnCooldown'] ?? false,
      nextPayoutAt: json['nextPayoutAt'] != null
          ? DateTime.parse(json['nextPayoutAt'])
          : null,
      reason: json['reason'],
      cooldownHours: json['cooldownHours'] ?? 48,
    );
  }
}
