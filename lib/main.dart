import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/prefs_provider.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled Fraunces font is under the SIL Open Font License, which asks to ship its text.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const ['Fraunces'],
      await rootBundle.loadString('assets/google_fonts/OFL.txt'),
    );
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Draw behind the system bars on every Android version, so the system button
  // area is always reported to the app (see the bottom strip in app.dart).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final prefs = await SharedPreferences.getInstance();
  final tokens = TokenStore();
  await tokens.load();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
      child: const FreshHenApp(),
    ),
  );
}
