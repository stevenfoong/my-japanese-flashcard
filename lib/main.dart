import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/app_state.dart';
import 'services/speech.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  // Draw the app straight away; saved data loads in the background.
  runApp(const KanaApp());
  Speech.loadIndex();
  await AppState.instance.init();
}

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const ['Klee One font'],
      await rootBundle.loadString('assets/fonts/OFL-KleeOne.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      const ['M PLUS Rounded 1c font'],
      await rootBundle.loadString('assets/fonts/OFL-MPLUSRounded1c.txt'),
    );
  });
}

class KanaApp extends StatelessWidget {
  const KanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => MaterialApp(
        title: 'Kana Cards',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: AppState.instance.themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}
