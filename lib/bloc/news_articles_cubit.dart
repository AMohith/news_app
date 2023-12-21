import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/article.dart';
import 'package:news_app/worker_isolate.dart';

part 'news_articles_state.dart';

class NewsArticlesCubit extends Cubit<NewsArticlesState> {
  NewsArticlesCubit() : super(const NewsArticlesInitial());

  List<Article> _articles = [];

  /// Cubit method to fetch articles from the API.
  /// A new isolate i.e, [WorkerIsolate] is created to fetch and map article objects.
  Future<void> fetchArticles() async {
    emit(const NewsArticlesLoading());

    try {
      final WorkerIsolate worker = WorkerIsolate();
      await worker.isReady;

      _articles = await worker.fetch();
      log('articles fetched');
      worker.dispose();

      if (_articles.isNotEmpty) {
        emit(NewsArticlesSuccess(articles: _articles));
      } else {
        emit(const NewsArticlesError(message: 'No Articles found'));
      }
    } catch (e) {
      log(e.toString());
      emit(const NewsArticlesError(message: 'Error while fetching articles'));
    }
  }
}
