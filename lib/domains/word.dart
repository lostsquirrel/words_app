class Phonetic {
  final String value;
  final String file;

  const Phonetic({required this.value, required this.file});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(value: json['value'], file: json['file']);
  }
}

class Word {
  final int id;
  final int guid;
  final String word;
  final List<Phonetic> phonetics;
  final String description;
  final int score;

  const Word({
    required this.id,
    required this.guid,
    required this.word,
    required this.phonetics,
    required this.description,
    required this.score,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    var _phonetics = json['phonetic'].cast<Map<String, dynamic>>();
    var phonetics =
        _phonetics.map<Phonetic>((p) => Phonetic.fromJson(p)).toList();

    return Word(
      id: json['id'],
      guid: json['guid'],
      word: json['word'],
      phonetics: phonetics,
      description: json['description'],
      score: json['score'],
    );
  }
}
