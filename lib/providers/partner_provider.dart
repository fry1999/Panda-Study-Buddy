import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/models/partner_status.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';

/// Partner status notifier
class PartnerStatusNotifier extends StateNotifier<PartnerStatusModel?> {
  final Ref ref;

  PartnerStatusNotifier(this.ref) : super(null) {
    _loadPartnerStatus();
  }

  /// Load partner status
  void _loadPartnerStatus() {
    final user = ref.read(authProvider);
    
    if (user == null || !user.hasPartner) {
      state = null;
      return;
    }

    // For now, return dummy data
    // In a real app, this would fetch from Firebase
    state = PartnerStatusModel.dummy(
      name: 'Sarah',
      status: PartnerStatus.studying,
      remainingMinutes: 12,
    );
  }

  /// Refresh partner status
  void refresh() {
    _loadPartnerStatus();
  }

  /// Update partner status (for testing)
  void setDummyStatus(PartnerStatus status, {int? remainingMinutes}) {
    if (state == null) return;
    
    state = PartnerStatusModel.dummy(
      name: state!.partnerName,
      status: status,
      remainingMinutes: remainingMinutes,
    );
  }
}

/// Partner status provider
final partnerStatusProvider =
    StateNotifierProvider<PartnerStatusNotifier, PartnerStatusModel?>((ref) {
  return PartnerStatusNotifier(ref);
});

/// Has partner provider
final hasPartnerProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user?.hasPartner ?? false;
});

/// Room code provider
final roomCodeProvider = Provider<String?>((ref) {
  final user = ref.watch(authProvider);
  return user?.roomCode;
});

