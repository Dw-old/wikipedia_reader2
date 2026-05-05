import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'summary.dart';

void main() {
  runApp(const MainApp());
}

class ArticleModel {
  Future<Summary> getRandomArticleSummary() async {
    final uri = Uri.https('en.wikipedia.org', '/api/rest_v1/page/random/summary');
    final response = await get(uri);

    if (response.statusCode != 200) {
      throw const HttpException('Failed to load article summary');
    }
    return Summary.fromJson(jsonDecode(response.body) as Map<String, Object?>);
  }
}

class ArticleViewModel extends ChangeNotifier {
  final ArticleModel model;
  Summary? summary;
  Exception? error;
  bool isLoading = false;

  ArticleViewModel(this.model) {
    fetchArticle();
  }
  
  Future<void> fetchArticle() async {
    isLoading = true;
    notifyListeners();
    try {
      summary = await model.getRandomArticleSummary();
      error = null;
    } on HttpException catch (e) {
      error = e;
      summary = null;
    }
    isLoading = false;
    notifyListeners();
  }
}

class ArticleView extends StatefulWidget {
  ArticleView({super.key});

  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  final viewModel = ArticleViewModel(ArticleModel());

  @override
  void initState() {
    super.initState();
    viewModel.fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ArticleWidget extends StatelessWidget {
  final Summary summary;
  const ArticleWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            if (summary.hasImage == true) Image.network(summary.originalImage!.source),
            Text(summary.titles.normalized, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.displaySmall),

            if (summary.description != null)
            Text(summary.description!, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),

            Text(summary.extract)
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ArticleViewModel(ArticleModel());

    return MaterialApp( 
      home: Scaffold(
        appBar: AppBar(
          title: Text("Wikipedia"), 
        ),
        body:  Center(
          child: Text('loading...'),
        ),
      ),
    );
  }
}