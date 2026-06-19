class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://notspot.kaillou.de',
  );
  static Uri get baseUri => Uri.parse(baseUrl);

  static String get origin {
    final port = baseUri.hasPort ? ':{baseUri.port}' : '';
    return '${baseUri.scheme}://${baseUri.host}$port';
  }

  static const String basePath = '/';
  static const String songsPath = '/songs';

  static Uri uri (String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters:
          queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static Uri songsUri() => uri(songsPath);
  static Uri songUri(int songId) => uri('$songsPath/$songId');
  static Uri songStreamUri(int songId) => uri('$songsPath/$songId/stream');
  static Uri searchSongsUri(String query) => uri('$songsPath/search', {'query': query});
}