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
  final ArticleModel model = ArticleModel();
  Summary? summary;
  Exception? error;
  bool isLoading = false;

  ArticleViewModel() {
    FetchArticle();
  }
  
  Future<void> FetchArticle () async {
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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