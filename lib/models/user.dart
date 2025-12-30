import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  int currentStreak;
  
  @HiveField(4)
  int totalBamboo;
  
  @HiveField(5)
  String? partnerId;
  
  @HiveField(6)
  String? roomCode;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime? lastSessionDate;
  
  @HiveField(9)
  String? avatarUrl;

  @HiveField(10)
  String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.currentStreak = 0,
    this.totalBamboo = 0,
    this.partnerId,
    this.roomCode,
    required this.createdAt,
    this.lastSessionDate,
    this.avatarUrl,
    this.photoUrl,
  });
  
  /// Check if user has a partner
  bool get hasPartner => partnerId != null && partnerId!.isNotEmpty;
  
  /// Check if user is in a room
  bool get isInRoom => roomCode != null && roomCode!.isNotEmpty;
  
  /// Update bamboo count
  void addBamboo(int amount) {
    totalBamboo += amount;
  }
  
  /// Update streak
  void incrementStreak() {
    currentStreak++;
  }
  
  void resetStreak() {
    currentStreak = 0;
  }
  
  /// Create a guest user
  factory User.guest({
    required String id,
  }) {
    return User(
      id: id,
      name: 'Guest',
      email: '',
      createdAt: DateTime.now(),
      photoUrl: '',
    );
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, streak: $currentStreak, bamboo: $totalBamboo)';
  }
}

