import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/domain/song.dart';
import '../models/request/add_song_request.dart';
import '../data/song_api.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';


class SongController extends ChangeNotifier {
  final SongApi _songService;
  late AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  
  List <Song> _songs = [];
  List<Song> _searchResults = [];
  Song? _currentSong;

  List<Song> _activeQueue = [];

  List<Song>? _originalQueue;
  int _queueIndex = -1;
  bool _shuffleEnabled = false;
  bool _isNavigating = false;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isUploading = false;

  String? _errorMessage;
  String? _uploadError;
  
  SongController() : _songService = SongApi() {
      _initializeAudioPlayer();
  }


  List<Song> get songs => _songs;
  List<Song> get searchResults => _searchResults;
  Song? get currentSong => _currentSong;
  List<Song> get currentQueue => _activeQueue;
  List<Song> get activeQueue => _activeQueue;
  bool get shuffleEnabled => _shuffleEnabled;
  AudioPlayer get audioPlayer => _audioPlayer;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isUploading => _isUploading;
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffling => _shuffleEnabled;

  String? get errorMessage => _errorMessage;
  String? get uploadError => _uploadError;

  bool get hasActiveSong => _currentSong != null;

  void setQueue(List<Song> queue, {Song? startSong}) {
    _originalQueue = List<Song>.from(queue);

    if(_shuffleEnabled) {
      _activeQueue = List<Song>.from(_originalQueue!)..shuffle();
    }else {
      _activeQueue = List<Song>.from(_originalQueue!);
    }

    if(_activeQueue.isEmpty) {
      _queueIndex = -1;
      notifyListeners();
      return;
    }

    if(startSong != null) {
      final idx = _activeQueue.indexWhere((s) => s.id == startSong.id);
      _queueIndex = idx >= 0 ? idx : 0;
    } else {
      _queueIndex = 0;
    }
    notifyListeners();
  }

  void _handleSongComplete() {
    if(_activeQueue.isNotEmpty) {
      playNext();
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners();
      if(playerState.processingState == ProcessingState.completed) {
        _handleSongComplete();
      }
    });

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if(index != null && _activeQueue.isNotEmpty && index < _activeQueue.length) {
        _queueIndex = index;
        _currentSong = _activeQueue[index];
      }
    });
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;

    if (_activeQueue.isNotEmpty) {
      final current = _currentSong;

      if (_shuffleEnabled) {
        _originalQueue = List<Song>.from(_activeQueue);
        _activeQueue = List<Song>.from(_activeQueue)..shuffle();
      } else {
        if (_originalQueue != null) {
          final currentId = current?.id;
          _activeQueue = List<Song>.from(_originalQueue!);
          if (currentId != null) {
            _queueIndex = _activeQueue.indexWhere((s) => s.id == currentId);
            if (_queueIndex < 0) _queueIndex = 0;
          } else {
            _queueIndex = 0;
          }
          _originalQueue = null;
        } else {
          _activeQueue.sort((a, b) {
            final ai = _songs.indexWhere((s) => s.id == a.id);
            final bi = _songs.indexWhere((s) => s.id == b.id);
            return ai.compareTo(bi);
          });
          if (current != null) {
            _queueIndex = _activeQueue.indexWhere((s) => s.id == current.id);
            if (_queueIndex < 0) _queueIndex = 0;
          }
        }
      }
    }

    if(_currentSong != null) {
      _updatePlayerPlaylistSilently();
    }
    notifyListeners();
  }

  Future<void> fetchSongs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _songs = await _songService.getSongs();
    } catch (e) {
      _errorMessage = "Failed to load music catalogue: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _songService.searchSong(query.trim());
    } catch (e) {
      _errorMessage = "Couldn't find songs: $e";
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> addSong({
    required AddSongRequest request,
    required File audiofile,
  }) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final Song newSong = await _songService.addSong(request, audiofile);
      _songs = [..._songs, newSong];
      return true;
    } catch (e) {
      _uploadError = "Failed to upload song: $e";
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> selectSong(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      setQueue(queue, startSong: song);
    } else if (_activeQueue.isEmpty) {
      setQueue(_songs, startSong: song);
    } else {
      final idx = _activeQueue.indexWhere((s) => s.id == song.id);
      _queueIndex = idx >= 0 ? idx : 0;
    }

    _currentSong = song;
    _errorMessage = null;
    notifyListeners();

    try {
      final playlist = ConcatenatingAudioSource(
        children: _activeQueue.map((s) {
          return AudioSource.uri(
            AppConfig.uri(s.streamUrl), // Sanitizes URL format
            tag: MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist,
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: _queueIndex,
        initialPosition: Duration.zero,
      );

      await _audioPlayer.play();
    } catch (e) {
      _errorMessage = "couldn't play song $e";
      notifyListeners();
    }
  }

  Future<void> _updatePlayerPlaylistSilently() async {
    try {
      final playlist = ConcatenatingAudioSource(
        children: _activeQueue.map((s) {
          return AudioSource.uri(
            AppConfig.uri(s.streamUrl),
            tag: MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist,
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: _queueIndex,
        initialPosition: _audioPlayer.position,
      );
    } catch (e) {
      // Preserve silent failure but capture error for debugging
      _errorMessage = 'Failed to update player playlist: $e';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (!hasActiveSong) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> playNext() async {
    if (_activeQueue.isEmpty || _isNavigating) return;
    _isNavigating = true;

    try {
      if (_queueIndex < 0) _queueIndex = 0;
      final currentIndex = _audioPlayer.currentIndex ?? _queueIndex;

      if (_audioPlayer.hasNext) {
        try {
          await _audioPlayer.seekToNext();
          return;
        } catch (_) {
        }
      }
      _queueIndex = (currentIndex + 1) % _activeQueue.length;
      await _audioPlayer.seek(Duration.zero, index: _queueIndex);
    } catch (e) {
      _errorMessage = 'Failed to skip to next song: $e';
      notifyListeners();
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> playPrevious() async {
    if (_activeQueue.isEmpty || _isNavigating) return;
    _isNavigating = true;

    try {
      if (_queueIndex < 0) _queueIndex = 0;
      final currentIndex = _audioPlayer.currentIndex ?? _queueIndex;

      if (_audioPlayer.hasPrevious) {
        try {
          await _audioPlayer.seekToPrevious();
          return;
        } catch (_) {
        }
      }
      _queueIndex =
          (currentIndex - 1) < 0 ? _activeQueue.length - 1 : currentIndex - 1;
      await _audioPlayer.seek(Duration.zero, index: _queueIndex);
    } catch (e) {
      _errorMessage = 'Failed to skip to previous song: $e';
      notifyListeners();
    } finally {
      _isNavigating = false;
    }
  }

  Future<void> _disposeAudioPlayer() async {
    await _playerStateSubscription?.cancel();
    await _currentIndexSubscription?.cancel();

    try {
      await _audioPlayer.dispose();
    } catch (_) {
      // Ignore dispose failures during cleanup.
    }

    _playerStateSubscription = null;
    _currentIndexSubscription = null;
  }

  Future<void> stopAndClear() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    } catch (_) {
      // Ignore failures while cleaning up on logout.
    }

    await _disposeAudioPlayer();
    _initializeAudioPlayer();

    _currentSong = null;
    _activeQueue = [];
    _originalQueue = null;
    _shuffleEnabled = false;
    _queueIndex = -1;
    _searchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _disposeAudioPlayer();
    super.dispose();
  }

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );
}

//helper for the progress bar
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}