class Transaction {
  final String id;
  final String title;
  final int amount;
  final DateTime timestamp;
  final String type; // 'earned' or 'spent'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.type,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: json['amount'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      type: json['type'] ?? 'earned',
    );
  }
}
