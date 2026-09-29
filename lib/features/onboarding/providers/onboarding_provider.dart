import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/prefs_provider.dart';

part 'onboarding_provider.g.dart';

const _seenKey = 'onboarding.seen';

@Riverpod(keepAlive: true)
class OnboardingSeen extends _$OnboardingSeen {
  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_seenKey) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPrefsProvider).setBool(_seenKey, true);
    state = true;
  }
}
