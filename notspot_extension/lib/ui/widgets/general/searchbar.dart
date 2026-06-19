import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';


class Searchbar extends StatefulWidget{
  const Searchbar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE5BA73), // Warm, low-fatigue amber accent
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40, // Tight, sleek desktop height
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xFFE5BA73),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                onChanged: (value) {
                  // Calls your song controller filter logic directly
                  context.read<SongController>().searchSongs(value);
                },
                decoration: InputDecoration(
                  fillColor: const Color(0xFF141519), // Cozy deep slate background
                  filled: true,
                  hintText: 'Search tracks...',
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                    fontSize: 13,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(Icons.search_rounded, color: Colors.white38, size: 18),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 32),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0), // Centers text vertically
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5BA73), width: 1.0),
                  ),
                ),
              ),
            ),
          ),

          // Muted Tune/Filter Action Button
          GestureDetector(
            onTap: () {
              // Handle sorting options menu later
            },
            child: Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
