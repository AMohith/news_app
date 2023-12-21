import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@CopyWith()
@JsonSerializable()
class Article {
  const Article({
    this.source = '',
    this.author = '',
    this.title = '',
    this.description = '',
    this.content = '',
    this.url = '',
    this.publishedAt = '',
  });

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

  final String source;

  final String title;

  final String author;

  final String description;

  final String content;

  final String url;

  final String publishedAt;

  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  List<Object?> get props => [
        source,
        author,
        title,
        description,
        content,
        url,
        publishedAt,
      ];
}
