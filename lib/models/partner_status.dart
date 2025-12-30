import 'package:panda_study_buddy/core/constants/app_constants.dart';

/// Partner status model
class PartnerStatusModel {
  final String partnerId;
  final String partnerName;
  final PartnerStatus status;
  final DateTime lastSeen;
  final int? remainingMinutes; // Remaining time in current session
  final String? avatarUrl;

  PartnerStatusModel({
    required this.partnerId,
    required this.partnerName,
    this.status = PartnerStatus.offline,
    required this.lastSeen,
    this.remainingMinutes,
    this.avatarUrl,
  });
  
  /// Check if partner is online
  bool get isOnline => status != PartnerStatus.offline;
  
  /// Check if partner is studying
  bool get isStudying => status == PartnerStatus.studying;
  
  /// Check if partner is on break
  bool get isOnBreak => status == PartnerStatus.onBreak;
  
  /// Get status text
  String get statusText {
    switch (status) {
      case PartnerStatus.online:
        return 'Online';
      case PartnerStatus.offline:
        return 'Offline';
      case PartnerStatus.studying:
        if (remainingMinutes != null) {
          return 'Studying... $remainingMinutes mins remaining';
        }
        return 'Studying...';
      case PartnerStatus.onBreak:
        return 'Partner is also on break';
      case PartnerStatus.resting:
        return 'Resting';
    }
  }
  
  /// Create a dummy partner for testing
  factory PartnerStatusModel.dummy({
    String name = 'Sarah',
    PartnerStatus status = PartnerStatus.studying,
    int? remainingMinutes = 12,
  }) {
    return PartnerStatusModel(
      partnerId: 'partner_001',
      partnerName: name,
      status: status,
      lastSeen: DateTime.now(),
      remainingMinutes: remainingMinutes,
    );
  }
  
  @override
  String toString() {
    return 'PartnerStatus(name: $partnerName, status: $status, remaining: $remainingMinutes)';
  }
}

