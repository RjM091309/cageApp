enum ViewType { realTime, daily, monthly, marker, ranking }

class OngoingGame {
  final String id;
  final String account;
  final int buyIn;
  final String table;
  final String gameType; // e.g. LIVE, TELEBET
  final String status; // 'Active' | 'Settling'

  OngoingGame({
    required this.id,
    required this.account,
    required this.buyIn,
    required this.table,
    required this.gameType,
    required this.status,
  });
}

class SettlementData {
  final String date;
  final int numGames;
  final int buyIn;
  final int rolling;
  final int winLoss;
  final int commission;
  final int expenses;

  SettlementData({
    required this.date,
    required this.numGames,
    required this.buyIn,
    required this.rolling,
    required this.winLoss,
    required this.commission,
    required this.expenses,
  });
}

class RankingItem {
  final String name;
  final int rolling;
  final int winnings;
  final int losses;
  final int rank;

  RankingItem({
    required this.name,
    required this.rolling,
    required this.winnings,
    required this.losses,
    required this.rank,
  });
}

class MarkerEntry {
  final String guest;   // Agency name (right side of card, below date/time)
  final String agent;   // "NAME (AGENT CODE)" left side of card
  final int balance;
  final int limit;
  final String lastUpdate;

  MarkerEntry({
    required this.guest,
    required this.agent,
    required this.balance,
    required this.limit,
    required this.lastUpdate,
  });
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final String type; // urgent, success, warning, info
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        message: message,
        time: time,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}
