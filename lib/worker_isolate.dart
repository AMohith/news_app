import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import 'article.dart';

class WorkerIsolate {
  WorkerIsolate() {
    init();
  }

  late SendPort _sendPort;

  late Isolate _isolate;

  Completer<List<Article>>? _articles;

  /// A Completer indicating the complete spawning of the isolate for further processing.
  final _isolateReady = Completer<void>();

  Future<void> get isReady => _isolateReady.future;

  /// API Key for a mock news api website https://newsapi.org/
  static const String _apiKey = '###';
  final String _baseUrl =
      'https://newsapi.org/v2/everything?q=apple&from=2023-12-20&to=2023-12-20&sortBy=popularity&apiKey=$_apiKey';

  Future<void> init() async {
    final receivePort = ReceivePort();

    receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
    );
  }

  void dispose() {
    _isolate.kill();
  }

  /// method to get list of articles
  Future<List<Article>> fetch() async {
    // sends a url message to the freshly spawned isolate.
    _sendPort.send(_baseUrl);

    _articles = Completer<List<Article>>();
    return _articles!.future;
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
      return;
    }

    if (message is List<Article>) {
      _articles?.complete(message);
      _articles = null;
      return;
    }

    throw UnimplementedError("Undefined behavior for message: $message");
  }

  static void _isolateEntry(dynamic message) {
    late SendPort sendPort;
    final receivePort = ReceivePort();

    // listens to the main isolate's messages.
    receivePort.listen((dynamic message) async {
      assert(message is String);
      final client = http.Client();
      try {
        final articles = await _fetchArticles(client, message);
        sendPort.send(articles);
      } finally {
        client.close();
      }
    });

    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }

  /// Fetches the articles using a mock news API website.
  /// [mapArticles] method parses the response json to [Article] objects
  static Future<List<Article>> _fetchArticles(
      http.Client client, String url) async {
    // maps list of articles from the json
    List<Article> mapArticles({
      required dynamic json,
    }) {
      final Map<String, dynamic> articlesJson = json as Map<String, dynamic>;

      final List<dynamic> jsonList =
          articlesJson.containsKey('articles') ? articlesJson['articles'] : [];

      final List<Article> articles = jsonList
          .map((e) {
            final Map<String, dynamic> article = e as Map<String, dynamic>;

            if (article.containsKey('source')) {
              final Map<String, dynamic> source = article['source'];
              final String sourceName =
                  source.containsKey('name') ? source['name'] : '';

              article.update('source', (value) => sourceName);
            }

            return Article.fromJson(article);
          })
          .takeWhile((a) => a.title != '' && a.author != '')
          .toList();

      return articles;
    }

    final uri = Uri.parse(url);

    try {
      log('started fetching articles');
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        // The article count from this api response is more than 1500.
        // which mocks heavy processing load on the app which is being handled in this new isolate thread.
        final List<Article> articles =
            mapArticles(json: jsonDecode(response.body));

        // Method returns a list of only 10 articles.
        return articles.take(10).toList();
      } else {
        throw NewsApiException(statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NewsApiException(message: "$url couldn't be fetched: $e");
    } on http.ClientException {
      throw const NewsApiException(message: "Connection failed.");
    }
  }
}

/// Custom News API exception with [statusCode] and [message] properties.
class NewsApiException implements Exception {
  final int? statusCode;
  final String? message;

  const NewsApiException({this.statusCode, this.message});
}
