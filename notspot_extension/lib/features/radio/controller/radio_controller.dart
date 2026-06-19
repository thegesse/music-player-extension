import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class RadioController extends ChangeNotifier{
  final AudioPlayer _audioPlayer;

  final Map<String, String> stations = {
    'Lofi Cafe Chilling': 'https://radio.loficafe.net/listen/chilling/radio.mp3',
    'Hotmix Lofi France': 'https://streaming.hotmixradio.com/hotmix-lofi-en-mp3',
    'Z8R Germany Lofi': 'http://icecast.z8r.de:8000/lofi',
    'LITT Live Instrumental': 'https://das-sa39.cdnstream1.com/5582_128',
    'LautFM Lofi HipHop': 'https://lofi.stream.laut.fm/lofi',
  };

  String? _currentStationName;
  bool _isPlaying = false;

  RadioController(this._audioPlayer);

  String? get currentStationName => _currentStationName;
  bool get isPlaying => _isPlaying;
  List<String> get stationNames => stations.keys.toList();

  Future<void> playStation(String name) async {
    final url = stations[name];
    if(url == null) return;

    try {
      _currentStationName = name;
      _isPlaying = true;
      notifyListeners();

      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      print("error loading radio stream: $e");
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playLocalTrack(String name, String urlOrFilePath) async {
  try {
    _currentStationName = name;
    _isPlaying = true;
    notifyListeners();

    // just_audio treats regular internet URLs and local file system paths natively
    if (urlOrFilePath.startsWith('http')) {
      await _audioPlayer.setUrl(urlOrFilePath);
    } else {
      await _audioPlayer.setFilePath(urlOrFilePath);
    }
    _audioPlayer.play();
  } catch (e) {
    print("Error playing library track: $e");
    _isPlaying = false;
    notifyListeners();
  }
}

  void stopRadio() {
    _audioPlayer.stop();
    _isPlaying = false;
    _currentStationName = null;
    notifyListeners();
  }
}