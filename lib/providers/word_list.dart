import 'package:flutter/material.dart';

import '../domains/word.dart';
import '../utils.dart';

class WordList extends ChangeNotifier {
  static const planFamiliarUrl = "/plan/familiar";

  final List<Word> _words = [];

  List<Word> get words => _words;

  void fetchWords() async {
    // print("word");
    var json = await sendGet(planFamiliarUrl);
    var _jsonList = json as List<dynamic>;
    var _wordList = _jsonList.map((item) {
      // var _word = item;
      return Word.fromJson(item);
    }).toList();
    _words.clear();
    _words.addAll(_wordList);
    notifyListeners();
  }
}
