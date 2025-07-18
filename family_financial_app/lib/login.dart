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
  late final ValueNotifier<bool> isFormValid = ValueNotifier(
    widget.username.value.isNotEmpty && widget.password.value.isNotEmpty,
  );

  @override
  void initState() {
    super.initState();
    
    widget.username.addListener(_updateFormValid);
    widget.password.addListener(_updateFormValid);
  }

  void _updateFormValid() {
    isFormValid.value =
        widget.username.value.isNotEmpty && widget.password.value.isNotEmpty;
  }

  @override
  void dispose() {
    widget.username.removeListener(_updateFormValid);
    widget.password.removeListener(_updateFormValid);
    isFormValid.dispose();
    super.dispose();
  }

  void login(BuildContext context) {
    // Navigate to the homepage after login
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final store = context.read<Store>();

    store
        .login(widget.username.value, widget.password.value)
        .then((response) {
          if (!response.success) {
            // Show error message
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(response.message ?? 'Login failed')),
            );
            return response;
          }
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        })
        .catchError((error, stackTrace) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              content: Text(error.message)
            ),
          );
          return Response<LoginResponse>(
            success: false,
            message: error.toString(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginBtnStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      minimumSize: const Size(200, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
    return Scaffold(
      body: Form(
        child: Center(
          child: Row(
            children: [
              Expanded(flex: 2, child: Column()),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
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
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 20,
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isFormValid,
                          builder: (context, valid, child) {
                            return ElevatedButton(
                              style: loginBtnStyle,
                              onPressed: valid ? () => login(context) : null,
                              child: const Text('Login'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 2, child: Column()),
            ],
          ),
        ),
      ),
    );
  }
}
