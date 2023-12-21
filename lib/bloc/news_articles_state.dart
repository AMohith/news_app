part of 'news_articles_cubit.dart';

abstract class NewsArticlesState extends Equatable {
  const NewsArticlesState();

  @override
  List<Object> get props => [];
}

class NewsArticlesInitial extends NewsArticlesState {
  const NewsArticlesInitial();
}

class NewsArticlesLoading extends NewsArticlesState {
  const NewsArticlesLoading();
}

class NewsArticlesSuccess extends NewsArticlesState {
  const NewsArticlesSuccess({required this.articles});

  final List<Article> articles;

  @override
  List<Object> get props => [articles];
}

class NewsArticlesError extends NewsArticlesState {
  const NewsArticlesError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}