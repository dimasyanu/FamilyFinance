import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/response.dart';
import 'package:family_financial_app/pages/homepage.dart';
import 'package:family_financial_app/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  Login({super.key});

  final ValueNotifier<String> username = ValueNotifier('');
  final ValueNotifier<String> password = ValueNotifier('');

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        child: Center(
          child: Row(
            children: [
              Expanded(flex:1, child: Column()),
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login to your account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Username'),
                      onChanged: (value) => widget.username.value = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onChanged: (value) => widget.password.value = value,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to the homepage after login
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final store = context.read<Store>();

                        store.login(
                          widget.username.value,
                          widget.password.value,
                        ).then((response) {
                          if (!response.success) {
                            // Show error message
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text(response.message ?? 'Login failed')),
                            );
                            return response;
                          }
                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const Homepage(),
                            ),
                          );
                        }).catchError((error) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
                          return Response<LoginResponse>(
                            success: false,
                            message: error.toString(),
                          );
                        });
                      },
                      child: const Text('Login'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final store = context.read<Store>();
                        store.test();
                      },
                      child: const Text('Test Store'),
                    )
                  ],
                ),
              ),
              Expanded(flex:1, child: Column()),
            ],
          ),
        ),
      ),
    );
  }
}
