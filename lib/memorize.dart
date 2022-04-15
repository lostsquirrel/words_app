import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'domains/familiarity.dart';
import 'domains/plan.dart';
import 'domains/word.dart';
import 'utils.dart';

const phoneticName = ["US", "UK"];
const planDefaultUrl = "/plan/default";
Future<Plan> fetchDefaultPlan() async {
  // print("default");
  var responseBody = await sendGet(planDefaultUrl);
  final parsed = jsonDecode(responseBody) as Map<String, dynamic>;
  return Plan.fromJson(parsed);
}

const planFamiliarUrl = "/plan/familiar";

List<Word> parseWords(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Word>((json) => Word.fromJson(json)).toList();
}

Future<List<Word>> fetchWords() async {
  // print("word");
  var responseBody = await sendGet(planFamiliarUrl);
  return parseWords(responseBody);
}

class Memorize extends StatefulWidget {
  const Memorize({Key? key}) : super(key: key);
  @override
  State<Memorize> createState() => _MemorizeState();
}

const planMemorizeUrl = "/plan/memorize";

class _MemorizeState extends State<Memorize> {
  int _index = 0;
  bool _showDescription = false;

  AudioPlayer audioPlayer = AudioPlayer();
  late Future<Plan> _futureDefaultPlan;
  late Future<List<Word>> _futureWords;
  @override
  void initState() {
    super.initState();
    _futureDefaultPlan = fetchDefaultPlan();
    _futureWords = fetchWords();
  }

  Future<void> memorize(int planId, int wordId, int familarity) async {
    sendPost(
      planMemorizeUrl,
      {
        "plan_id": planId,
        "word_id": wordId,
        "familarity": familarity,
      },
    );
  }

  void _toggleNext() {
    setState(() {
      _index++;
    });
  }

  void _toggleDescription() {
    setState(() {
      _showDescription = !_showDescription;
    });
  }

  void _playAudio(String url) async {
    await audioPlayer.play(url);
  }

  void _memorize(int planId, int amountPerDay, int wordId, int familarity) {
    memorize(planId, wordId, familarity);
    var maxIndex = amountPerDay - 1;
    if (_index == maxIndex) {
      setState(() {
        _futureWords = fetchWords();
        _index = 0;
      });
    } else {
      _toggleNext();
    }

    if (_showDescription) {
      _toggleDescription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '背单词',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('背单词'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Plan>(
            future: _futureDefaultPlan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  var _defaultPlan = snapshot.data;
                  var phoneticIndex = _defaultPlan!.phonetic;
                  return _wordMemorizing(phoneticIndex, _defaultPlan);
                }
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<Word>> _wordMemorizing(
      int phoneticIndex, Plan _defaultPlan) {
    return FutureBuilder<List<Word>>(
        future: _futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var words = snapshot.data;
              var word = words![_index];
              var _phoneticName = phoneticName[phoneticIndex];
              var _wordPhonetic = "-";
              if (word.phonetics.length > phoneticIndex) {
                _wordPhonetic = word.phonetics[phoneticIndex].value;
              }

              return Column(
                // mainAxisAlignment: MainAxisAlignment.center,

                mainAxisSize: MainAxisSize.max,

                children: <Widget>[
                  Flexible(
                    child: Column(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(top: 100),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  word.word,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  "$_phoneticName[$_wordPhonetic]",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                IconButton(
                                  onPressed: () {
                                    // print(word);
                                    _playAudio(
                                        word.phonetics[phoneticIndex].file);
                                  },
                                  // ignore: prefer_const_constructors
                                  icon: Icon(
                                    Icons.volume_mute,
                                    size: 35,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Visibility(
                                  child: Text(
                                    word.description,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  visible: _showDescription,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          child: TextButton(
                            child: const Text("点击查看词义"),
                            onPressed: () {
                              _toggleDescription();
                            },
                          ),
                          visible: !_showDescription,
                        ),
                      ],
                    ),
                  ),
                  // const Divider(height: 1.0),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 100.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFamiliarButton(
                            _defaultPlan, word, Familiarity.unfamiliar()),
                        _buildFamiliarButton(
                            _defaultPlan, word, Familiarity.familiar()),
                        _buildFamiliarButton(
                            _defaultPlan, word, Familiarity.mastered()),
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
          }
          return const CircularProgressIndicator();
        });
  }

  OutlinedButton _buildFamiliarButton(
      Plan _defaultPlan, Word word, Familiarity familiarity) {
    return OutlinedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      child: Text(familiarity.desc),
      onPressed: () {
        _memorize(_defaultPlan.id, _defaultPlan.amountPerDay, word.id,
            familiarity.level);
      },
    );
  }
}
