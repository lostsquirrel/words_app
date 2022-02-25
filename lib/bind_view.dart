import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user.dart';
import 'utils.dart';

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

  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    await Provider.of<User>(context, listen: false).bind(
      _authData['invite_code'],
    );
    setState(() {
      // TODO 处理错误信息
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 260,
        constraints: BoxConstraints(minHeight: 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: '邀请码'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 32) {
                      return "无效的输入";
                    }
                  },
                  onSaved: (value) {
                    _authData['invite_code'] = value ?? "";
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: _submit,
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
