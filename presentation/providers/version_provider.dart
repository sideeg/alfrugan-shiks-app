// lib/presentation/providers/version_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/services/version_service.dart';

class VersionState {
  final bool updateRequired;
  final String? requiredVersion;
  final String? currentVersion;
  final bool isLoading;

  const VersionState({
    this.updateRequired = false,
    this.requiredVersion,
    this.currentVersion,
    this.isLoading = false,
  });

  VersionState copyWith({
    bool? updateRequired,
    String? requiredVersion,
    String? currentVersion,
    bool? isLoading,
  }) =>
      VersionState(
        updateRequired: updateRequired ?? this.updateRequired,
        requiredVersion: requiredVersion ?? this.requiredVersion,
        currentVersion: currentVersion ?? this.currentVersion,
        isLoading: isLoading ?? this.isLoading,
      );
}

final versionProvider =
    StateNotifierProvider<VersionNotifier, VersionState>((_) {
  return VersionNotifier();
});

class VersionNotifier extends StateNotifier<VersionState> {
  VersionNotifier() : super(const VersionState(isLoading: true));

  /// Check if update is required
  Future<void> checkVersion(String minimumRequiredVersion) async {
    state = state.copyWith(isLoading: true);
    try {
      final current = await VersionService.getCurrentVersion();
      final updateRequired =
          await VersionService.isUpdateRequired(minimumRequiredVersion);
      print(
          "DEBUG: Current Version: $current, Required: $minimumRequiredVersion");

      state = VersionState(
        updateRequired: updateRequired,
        requiredVersion: minimumRequiredVersion,
        currentVersion: current,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Reset version state after update
  void resetVersion() {
    state = const VersionState(updateRequired: false);
  }
}
