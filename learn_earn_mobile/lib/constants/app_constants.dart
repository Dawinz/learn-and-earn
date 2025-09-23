class AppConstants {
  // Coin to Cash Conversion Rate
  // 10 coins = $0.001 (0.1 cents)
  static const double COINS_PER_DOLLAR = 10000.0; // 10,000 coins = $1.00
  static const double CASH_PER_COIN = 0.0001; // 1 coin = $0.0001 (0.01 cents)

  // Minimum payout amounts
  static const int MIN_PAYOUT_COINS = 1000; // 1000 coins = $0.10
  static const double MIN_PAYOUT_CASH = 0.10; // $0.10 minimum payout

  // Conversion helper methods
  static double coinsToCash(int coins) {
    return coins * CASH_PER_COIN;
  }

  static int cashToCoins(double cash) {
    return (cash * COINS_PER_DOLLAR).round();
  }

  static String formatCash(double cash) {
    return '\$${cash.toStringAsFixed(4)}';
  }

  static String formatCashShort(double cash) {
    if (cash >= 1.0) {
      return '\$${cash.toStringAsFixed(2)}';
    } else if (cash >= 0.01) {
      return '\$${cash.toStringAsFixed(3)}';
    } else {
      return '\$${cash.toStringAsFixed(4)}';
    }
  }
}
