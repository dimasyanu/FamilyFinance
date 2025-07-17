import 'package:family_financial_app/pages/homepage.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

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
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the homepage after login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Homepage(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
