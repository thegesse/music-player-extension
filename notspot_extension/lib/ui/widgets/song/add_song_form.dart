import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/songs/models/request/add_song_request.dart';
import '../../../features/songs/state/song_controller.dart';

class AddSongForm extends StatefulWidget {
  const AddSongForm({super.key});

  @override
  State<AddSongForm> createState() => _AddSongFormState();
}

class _AddSongFormState extends State<AddSongForm> {
  final _formKey = GlobalKey<FormState>();
  final _songTitleController = TextEditingController();
  final _songArtistController = TextEditingController();

  File? _selectAudioFile;
  String? _selectedFileName;
  bool _fileHasError = false;

  // Muted Lo-fi Amber Accent Color
  static const Color _accentColor = Color(0xFFE5BA73);
  // Cozy Deep Slate Input Background
  static const Color _inputBgColor = Color(0xFF141519);

  @override
  void dispose() {
    _songArtistController.dispose();
    _songTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickMp3File() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _selectAudioFile = File(result.files.single.path!);
      _selectedFileName = result.files.single.name;
      _fileHasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final register = context.watch<SongController>();

    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: _accentColor,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SONG TITLE FIELD ---
            SizedBox(
              height: 40, // Uniform tight height
              child: TextFormField(
                controller: _songTitleController,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                decoration: _buildInputDecoration(
                  label: 'Title',
                  icon: Icons.title_rounded,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '' : null, // Clean, empty error string to preserve compact layout
              ),
            ),
            const SizedBox(height: 12),

            // --- SONG ARTIST FIELD ---
            SizedBox(
              height: 40, // Uniform tight height
              child: TextFormField(
                controller: _songArtistController,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                decoration: _buildInputDecoration(
                  label: 'Artist',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '' : null,
              ),
            ),
            const SizedBox(height: 12),

            // --- FILE PICKER SELECTION BUTTON DECK ---
            InkWell(
              onTap: _pickMp3File,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectAudioFile != null
                      ? _accentColor.withOpacity(0.04)
                      : _inputBgColor,
                  border: Border.all(
                    color: _fileHasError
                        ? Colors.redAccent.withOpacity(0.6)
                        : (_selectAudioFile != null
                            ? _accentColor.withOpacity(0.3)
                            : Colors.white.withOpacity(0.03)),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _fileHasError
                            ? Colors.red.withOpacity(0.1)
                            : (_selectAudioFile != null
                                ? _accentColor.withOpacity(0.1)
                                : Colors.white.withOpacity(0.02)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectAudioFile != null
                            ? Icons.audiotrack_rounded
                            : Icons.file_upload_outlined,
                        color: _fileHasError
                            ? Colors.redAccent
                            : (_selectAudioFile != null
                                ? _accentColor
                                : Colors.white38),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? 'Select audio file',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: _fileHasError
                                  ? Colors.redAccent
                                  : Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Format: .mp3 assets',
                            style: TextStyle(color: Colors.white30, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_fileHasError)
              const Padding(
                padding: EdgeInsets.only(top: 4.0, left: 8.0),
                child: Text(
                  'Please select an MP3 track',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
            const SizedBox(height: 16),

            if (register.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  register.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- SAVE SONG SUBMIT ELEVATED BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 38, // Slid down to match compact desktop proportions
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: const Color(0xFF141519), // Dark text contrast against amber
                  disabledBackgroundColor: _accentColor.withOpacity(0.2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: register.isLoading ? null : _handleSave,
                child: register.isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF141519),
                        ),
                      )
                    : const Text("Save Track"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white30, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white38, size: 16),
      filled: true,
      fillColor: _inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
        borderSide: const BorderSide(color: _accentColor, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      // Hide messy inline validator layout spacing variations
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  void _handleSave() async {
    final formValid = _formKey.currentState!.validate();
    if (_selectAudioFile == null) {
      setState(() => _fileHasError = true);
    }

    if (formValid && _selectAudioFile != null) {
      final success = await context.read<SongController>().addSong(
            request: AddSongRequest(
              title: _songTitleController.text.trim(),
              artist: _songArtistController.text.trim(),
            ),
            audiofile: _selectAudioFile!,
          );

      if (success && mounted) {
        context.go('/'); // Fixed: Redirects to your clean root mini player layout path directly!
      }
    }
  }
}