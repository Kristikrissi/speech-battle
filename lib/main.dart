import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'screens/home_screen.dart';
import 'screens/game_mode_selection_screen.dart';
import 'screens/hero_selection_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/quick_battle_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/training_screen.dart';
import 'screens/opponent_selection_screen.dart';
import 'screens/player_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/speech_recognition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final speechService = SpeechRecognitionService();
  await speechService.initialize();

  if (kIsWeb) {
    debugPrint('Running in web mode');
    debugPrint('Speech service initialized: ${speechService.isInitialized}');
    debugPrint('Selected locale: ${speechService.currentLocale}');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameState()),
        Provider<SpeechRecognitionService>.value(value: speechService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Речевая битва',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game_modes': (context) => const GameModeSelectionScreen(),
        '/hero_selection': (context) => const HeroSelectionScreen(),
        '/opponent_selection': (context) => const OpponentSelectionScreen(),
        '/campaign': (context) => const CampaignScreen(),
        '/quick_battle': (context) => const QuickBattleScreen(),
        '/tournament': (context) => const TournamentScreen(),
        '/training': (context) => const TrainingScreen(),
        '/profile': (context) => const PlayerProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
