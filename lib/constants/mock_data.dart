import '../models/types.dart';

final mockOngoingGames = <OngoingGame>[
  OngoingGame(id: '1', account: 'VIP-G881', buyIn: 250000, cashOut: 0, table: 'Bacc-01', gameType: 'LIVE', status: 'Active'),
  OngoingGame(id: '2', account: 'AGENT-KRX', buyIn: 120000, cashOut: 20000, table: 'Roulette-04', gameType: 'TELEBET', status: 'Active'),
  OngoingGame(id: '3', account: 'VIP-J99', buyIn: 500000, cashOut: 480000, table: 'Bacc-03', gameType: 'LIVE', status: 'Settling'),
  OngoingGame(id: '4', account: 'VIP-A40', buyIn: 75000, cashOut: 0, table: 'Poker-02', gameType: 'LIVE', status: 'Active'),
];

final mockDailySettlement = <SettlementData>[
  SettlementData(date: 'Mon', numGames: 12, buyIn: 1200000, rolling: 4500000, winLoss: 350000, commission: 45000, expenses: 12000),
  SettlementData(date: 'Tue', numGames: 18, buyIn: 2100000, rolling: 6200000, winLoss: -120000, commission: 62000, expenses: 15000),
  SettlementData(date: 'Wed', numGames: 15, buyIn: 1800000, rolling: 5800000, winLoss: 450000, commission: 58000, expenses: 13500),
  SettlementData(date: 'Thu', numGames: 22, buyIn: 3200000, rolling: 8900000, winLoss: 890000, commission: 89000, expenses: 22000),
  SettlementData(date: 'Fri', numGames: 28, buyIn: 4500000, rolling: 12000000, winLoss: -540000, commission: 120000, expenses: 31000),
  SettlementData(date: 'Sat', numGames: 35, buyIn: 6200000, rolling: 18500000, winLoss: 1200000, commission: 185000, expenses: 45000),
  SettlementData(date: 'Sun', numGames: 30, buyIn: 5500000, rolling: 15200000, winLoss: 780000, commission: 152000, expenses: 38000),
];

final mockMarkers = <MarkerEntry>[
  MarkerEntry(guest: 'Golden Dragon Agency', agent: 'John Smith (VIP-88)', balance: 1500000, limit: 2000000, lastUpdate: '10:45 AM'),
  MarkerEntry(guest: 'Silver Tiger Agency', agent: 'Jane Doe (VIP-12)', balance: 800000, limit: 1000000, lastUpdate: '11:20 AM'),
  MarkerEntry(guest: 'Phoenix Agency', agent: 'Chen Wei (VIP-45)', balance: 4200000, limit: 5000000, lastUpdate: '09:15 AM'),
  MarkerEntry(guest: 'Jade Emperor Agency', agent: 'Sarah Connor (VIP-01)', balance: 250000, limit: 500000, lastUpdate: '12:01 PM'),
  MarkerEntry(guest: 'Infinity Agency', agent: 'Bruce Wayne (VIP-BAT)', balance: 12000000, limit: 15000000, lastUpdate: '11:55 AM'),
];

final mockRanking = <RankingItem>[
  RankingItem(name: 'Agent Golden Dragon', rolling: 45000000, winnings: 3200000, losses: 1500000, rank: 1),
  RankingItem(name: 'VIP Phoenix-01', rolling: 32000000, winnings: 1800000, losses: 2100000, rank: 2),
  RankingItem(name: 'Agent Silver Tiger', rolling: 28000000, winnings: 2500000, losses: 900000, rank: 3),
  RankingItem(name: 'VIP Jade Emperor', rolling: 25000000, winnings: 1200000, losses: 400000, rank: 4),
  RankingItem(name: 'VIP Iron Fist', rolling: 19000000, winnings: 900000, losses: 1200000, rank: 5),
];

final mockNotifications = <NotificationItem>[
  NotificationItem(id: 1, title: 'High Buy-in Detected', message: 'VIP-G881 just added ₱250,000 at Table Bacc-01', time: '2 mins ago', type: 'urgent'),
  NotificationItem(id: 2, title: 'Settlement Complete', message: 'Agent KRX daily settlement has been processed successfully.', time: '15 mins ago', type: 'success'),
  NotificationItem(id: 3, title: 'Marker Alert', message: 'Bruce Wayne usage has reached 80% of current limit.', time: '1 hour ago', type: 'warning'),
  NotificationItem(id: 4, title: 'System Update', message: 'Vantage Suite v2.4 deployment successful.', time: '3 hours ago', type: 'info'),
];
