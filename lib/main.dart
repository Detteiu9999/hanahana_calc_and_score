// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/slot_analyzer_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(SlotAnalyzerApp());
}

class SlotAnalyzerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '設定判別ツール',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.notoSansJpTextTheme(),
      ),
      home: SlotAnalyzerScreen(),
    );
  }
}