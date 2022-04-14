import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

import 'domains/plan.dart';
import 'domains/word.dart';

const phoneticName = ["US", "UK"];
const planDefaultUrl = "/plan/default";
Future<Plan> fetchDefaultPlan() async {
  // print("default");
  var json = await sendGet(planDefaultUrl);
  return Plan.fromJson(json);
}

const planFamiliarUrl = "/plan/familiar";

Future<List<Word>> fetchWords() async {
  // print("word");
  var json = await sendGet(planFamiliarUrl);
  var _jsonList = json as List<dynamic>;
  var _wordList = _jsonList.map((item) {
    // var _word = item;
    return Word.fromJson(item);
  }).toList();
  return List<Word>.from(_wordList);
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
                    return FutureBuilder<List<Word>>(
                        future: _futureWords,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              var words = snapshot.data;
                              var word = words![_index];
                              var _phoneticName = phoneticName[phoneticIndex];
                              var _wordPhonetic = "-";
                              if (word.phonetics.length > phoneticIndex) {
                                _wordPhonetic =
                                    word.phonetics[phoneticIndex].value;
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Spacer(),
                                  Text(
                                    word.word,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    "$_phoneticName[$_wordPhonetic]",
                                    style: const TextStyle(fontSize: 20),
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
                                    maintainAnimation: true,
                                    maintainSize: true,
                                    maintainState: true,
                                    visible: _showDescription,
                                  ),
                                  const Spacer(),
                                  Visibility(
                                    child: TextButton(
                                      child: const Text("点击查看词义"),
                                      onPressed: () {
                                        _toggleDescription();
                                      },
                                    ),
                                    maintainAnimation: true,
                                    maintainSize: true,
                                    maintainState: true,
                                    visible: !_showDescription,
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      OutlinedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text("不认识"),
                                        onPressed: () {
                                          _memorize(
                                              _defaultPlan.id,
                                              _defaultPlan.amountPerDay,
                                              word.id,
                                              0);
                                        },
                                      ),
                                      OutlinedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text("有印象"),
                                        onPressed: () {
                                          _memorize(
                                              _defaultPlan.id,
                                              _defaultPlan.amountPerDay,
                                              word.id,
                                              1);
                                        },
                                      ),
                                      OutlinedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text("已掌握"),
                                        onPressed: () {
                                          _memorize(
                                              _defaultPlan.id,
                                              _defaultPlan.amountPerDay,
                                              word.id,
                                              2);
                                        },
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                          }
                          return const CircularProgressIndicator();
                        });
                  }
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            )),
      ),
    );
  }
}
