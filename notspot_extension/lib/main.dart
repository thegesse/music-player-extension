import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart'; // 💡 Add this import

// Import paths
import 'features/radio/controller/radio_controller.dart';
import 'features/songs/state/song_controller.dart';
import 'ui/screens/main_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  JustAudioMediaKit.ensureInitialized(
    linux: true, // Forces linux native bridge activation
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RadioController>(
          create: (_) => RadioController(audioPlayer),
        ),
        ChangeNotifierProvider<SongController>(
          create: (_) => SongController(),
        ),
      ],
      child: MaterialApp(
        title: 'NotSpot Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE5BA73), 
            surface: Color(0xFF141519),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0E11),
        ),
        home: const MainPlayerScreen(),
      ),
    );
  }
}