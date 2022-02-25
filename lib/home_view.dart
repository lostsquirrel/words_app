import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words_app/bind_view.dart';

import 'providers/user.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    user.tryAutoLogin().then((user) =>
        {Navigator.pushReplacementNamed(context, BindView.routerName)});

    return Container();
  }
}
