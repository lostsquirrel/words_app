import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'domains/http_exception.dart';
import 'providers/user.dart';

class BindView extends StatefulWidget {
  static const String routerName = "bind-view";
  const BindView({Key? key}) : super(key: key);

  @override
  State<BindView> createState() => _BindViewState();
}

class _BindViewState extends State<BindView> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final Map<String, String> _authData = {
    'invite_code': '',
  };

  var _isLoading = false;

  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final scaffold = ScaffoldMessenger.of(context);
    return Scaffold(
      body: Container(
        height: 200,
        constraints: const BoxConstraints(minHeight: 200),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(
          vertical:
              (deviceSize.height - MediaQuery.of(context).viewInsets.bottom) *
                  0.3,
          horizontal: 30,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: '邀请码:',
                    labelStyle: TextStyle(
                      fontSize: 26,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _codeController.clear,
                      padding: EdgeInsets.all(2.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 32) {
                      return "无效的输入";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['invite_code'] = value ?? "";
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      // Invalid!
                      return;
                    }
                    _formKey.currentState!.save();
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      var isSuccess =
                          await Provider.of<User>(context, listen: false).bind(
                        _authData['invite_code'],
                      );
                      if (isSuccess) {
                        scaffold.showSnackBar(
                          const SnackBar(
                            content: Text("加入成功！"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } on HttpException catch (err) {
                      scaffold.showSnackBar(
                        SnackBar(
                          content: Text(err.message),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: const Text('提交'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
