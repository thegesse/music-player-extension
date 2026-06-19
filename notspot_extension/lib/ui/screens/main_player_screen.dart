import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/general/searchbar.dart';
import '../../features/radio/controller/radio_controller.dart';
import '../../features/songs/state/song_controller.dart';

class MainPlayerScreen extends StatelessWidget {
  const MainPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgSlate = Color(0xFF0D0E11);
    const Color panelBg = Color(0xFF141519);
    const Color accentAmber = Color(0xFFE5BA73);

    return Scaffold(
      backgroundColor: bgSlate,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔍 SECTION 1: COMPACT SEARCH BAR DECK
              const Searchbar(),
              const SizedBox(height: 16),

              // 🎛️ SECTION 2: THE MAIN SPLIT WORKSPACE GRID
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // 🎵 LEFT COLUMN: Your Dynamic Server-Side Track Collection
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: panelBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Action Headers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Your Collection",
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Shuffle Play',
                                      icon: const Icon(Icons.shuffle_rounded, color: accentAmber, size: 20),
                                      onPressed: () {
                                        // context.read<SongController>().toggleShuffle();
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      tooltip: 'Upload Music Asset',
                                      icon: const Icon(Icons.add_box_rounded, color: Colors.white54, size: 20),
                                      onPressed: () => context.go('/add-song'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            
                            // Dynamic Server Songs Consumer Loop
                            Expanded(
                              child: Consumer<SongController>(
                                builder: (context, songCtrl, child) {
                                  if (songCtrl.isLoading) {
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  }

                                  if (songCtrl.songs.isEmpty) {
                                    return const Center(
                                      child: Text("Library empty. Upload a track!", 
                                          style: TextStyle(color: Colors.white24, fontSize: 13)),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: songCtrl.songs.length,
                                    itemBuilder: (context, index) {
                                      final song = songCtrl.songs[index];
                                      
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.music_note_rounded, color: Colors.white38, size: 18),
                                        title: Text(song.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                        subtitle: Text(song.artist, style: const TextStyle(color: Colors.white30, fontSize: 11)),
                                        trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white24, size: 16),
                                        onTap: () {
                                          // context.read<RadioController>().playLocalTrack(song.title, song.audioUrl);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 📻 RIGHT COLUMN: Live Lo-Fi Radio Deck Card
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: panelBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lo-Fi Radio Tuner",
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            
                            Expanded(
                              child: Consumer<RadioController>(
                                builder: (context, radioCtrl, child) {
                                  return ListView.separated(
                                    itemCount: radioCtrl.stationNames.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final station = radioCtrl.stationNames[index];
                                      final isPlaying = radioCtrl.currentStationName == station;
                                      return ListTile(
                                        dense: true,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        tileColor: isPlaying ? accentAmber.withOpacity(0.08) : Colors.white.withOpacity(0.02),
                                        title: Text(station, style: TextStyle(color: isPlaying ? accentAmber : Colors.white70, fontSize: 13)),
                                        trailing: Icon(isPlaying ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: isPlaying ? accentAmber : Colors.white24, size: 16),
                                        onTap: () => radioCtrl.playStation(station),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 🎵 SECTION 3: CURRENTLY PLAYING BAR & TERMINATE ENGINE DECK
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.02)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.music_note_rounded, color: accentAmber, size: 22),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("No Track Active", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                            SizedBox(height: 2),
                            Text("Select an asset or stream station", style: TextStyle(color: Colors.white30, fontSize: 11)),
                          ],
                        )
                      ],
                    ),
                    
                    IconButton(
                      tooltip: 'Stop Engine & Close App',
                      icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        context.read<RadioController>().stopRadio();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}