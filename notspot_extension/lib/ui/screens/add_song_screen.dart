import 'package:flutter/material.dart';
import '../widgets/song/add_song_form.dart';

class AddSongScreen extends StatelessWidget {
  const AddSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Muted Lo-fi Theme Constants
    const Color accentColor = Color(0xFFE5BA73); // Muted amber
    const Color bgSlate = Color(0xFF141519);     // Cozy dark background

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E11), // Extra deep back drop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white54), // Low contrast back arrow
        title: const Text(
          'Upload music',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 18, // Desktop optimized font size
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: bgSlate,
              borderRadius: BorderRadius.circular(12), // Snugger, modern corner match
              border: Border.all(
                color: Colors.white.withOpacity(0.02),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380), // Snug width for compact windowing
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon branding indicator top header element
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.library_add_rounded,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Add a New Song",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Fill in the details below to add this track to your local library bank.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Your main internal input form component tree
                  const AddSongForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}