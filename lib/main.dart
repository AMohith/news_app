import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/bloc/news_articles_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Tiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const NewsListScreen(),
    );
  }
}

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  NewsListScreenState createState() => NewsListScreenState();
}

class NewsListScreenState extends State<NewsListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsArticlesCubit()..fetchArticles(),
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Top Stories',
            ),
          ),
          backgroundColor: Colors.green.shade200,
        ),
        body: BlocBuilder<NewsArticlesCubit, NewsArticlesState>(
          builder: (context, state) {
            if (state is NewsArticlesLoading) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is NewsArticlesSuccess) {
              final articleList = state.articles;

              // list of articles
              return ListView.builder(
                itemCount: articleList.length,
                itemBuilder: (BuildContext context, int index) {
                  final article = articleList[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            article.title,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        leading: const Icon(
                          Icons.dehaze_outlined,
                          size: 18,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1.5,
                        color: Color(0xFFD8D8D8),
                      ),
                    ],
                  );
                },
              );
            }

            if (state is NewsArticlesError) {
              return const Center(
                child: Text(
                  'System error',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.redAccent,
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
