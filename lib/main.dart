import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:moist/app/components/bottom_navbar/bottom_navbar.dart';
import 'package:moist/core/handler/audio_handler.dart';

late AudioPlayerHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  MetadataGod.initialize();
  await FlutterDisplayMode.setHighRefreshRate();
  await Hive.openBox('homeCache');
  await Hive.openBox('songHistory');
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.neal.moist.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  runApp(
    const ProviderScope(
      child: MoistApp(),
    ),
  );
}

class MoistApp extends StatelessWidget {
  const MoistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: const BottomNavBar(),
    );
  }
}
