import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/default_plan.dart';
import 'providers/word_list.dart';
import 'utils.dart';

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

  @override
  void initState() {
    super.initState();
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

  void _memorize(int planId, int wordId, int familarity) {
    memorize(planId, wordId, familarity);
    _toggleNext();
    if (_showDescription) {
      _toggleDescription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => DefaultPlan(),
      child: Consumer<DefaultPlan>(
        builder: (context, defaultPlan, child) {
          defaultPlan.fetchDefaultPlan();
          return ChangeNotifierProvider(
            create: (_) => WordList(),
            child: Consumer<WordList>(builder: (context, wordList, child) {
              var _defaultPlan = defaultPlan.defaultPlan;
              wordList.fetchWords();
              var words = wordList.words;
              var word = words[_index];
              return MaterialApp(
                title: "test",
                home: Scaffold(
                  body: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 150),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                word.word,
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                word.phonetics[0].value,
                                style: const TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                onPressed: () {
                                  // print(word);
                                  _playAudio(word.phonetics[0].file);
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
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 100,
                          left: 100,
                          bottom: 100,
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              TextButton(
                                child: const Text("不认识"),
                                onPressed: () {
                                  _memorize(_defaultPlan!.id, word.id, 0);
                                },
                              ),
                              TextButton(
                                child: const Text("有印象"),
                                onPressed: () {
                                  _memorize(_defaultPlan!.id, word.id, 1);
                                },
                              ),
                              TextButton(
                                child: const Text("已掌握"),
                                onPressed: () {
                                  _memorize(_defaultPlan!.id, word.id, 2);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
