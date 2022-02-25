import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bind_view.dart';
import 'home_view.dart';
import 'providers/user.dart';
import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: User(),
        ),
      ],
      child: Consumer(
        builder: (context, value, child) => MaterialApp(
          title: "背单词",
          home: HomeView(),
          routes: {
            BindView.routerName: (cxt) => BindView(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User user = User();

  @override
  void initState() {
    super.initState();
    user.tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: user.isAuth ? Text("ok") : Text("need bind"),
    );
  }
}
