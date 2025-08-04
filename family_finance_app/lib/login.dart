import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/app.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final username = ValueNotifier('');
  final password = ValueNotifier('');
  final isLoadingUser = ValueNotifier(false);

  late final ValueNotifier<bool> isFormValid = ValueNotifier(
    username.value.isNotEmpty && password.value.isNotEmpty,
  );

  @override
  void initState() {
    super.initState();

    isLoadingUser.value = true;
    username.addListener(_updateFormValid);
    password.addListener(_updateFormValid);
  }

  void _updateFormValid() {
    isFormValid.value = username.value.isNotEmpty && password.value.isNotEmpty;
  }

  @override
  void dispose() {
    username.removeListener(_updateFormValid);
    password.removeListener(_updateFormValid);
    isFormValid.dispose();
    isLoadingUser.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> checkUser(BuildContext context) async {
    final store = context.read<Store>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final loginResponse = LoginResponse.fromJson(
        await store.get(StorageKey.user),
      );
      final now = DateTime.now();
      if (loginResponse.username.isNotEmpty &&
          loginResponse.accessToken.isNotEmpty &&
          loginResponse.expiration.isAfter(now)) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const App()),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error reading user data')),
      );
    }
  }

  void login(BuildContext context) {
    // Navigate to the homepage after login
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final store = context.read<Store>();
    final loader = context.loaderOverlay;
    loader.show();

    store
        .login(username.value, password.value)
        .then((response) {
          if (!response.success) {
            // Show error message
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(response.message ?? 'Login failed')),
            );
            return response;
          }
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const App()),
          );
        })
        .catchError((error, stackTrace) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              content: Text(error.message ?? 'An error occurred during login'),
            ),
          );
          return Res<LoginResponse>(success: false, message: error.toString());
        })
        .whenComplete(() => loader.hide());
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
    return FutureBuilder(
      future: checkUser(context),
      builder: (context, snapshot) => Scaffold(
        body: LoaderOverlay(
          child: Form(
            child: Center(
              child: Row(
                children: [
                  Expanded(flex: 1, child: Column()),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 20,
                      children: [
                        // Text(
                        // context.read<Store>().loginTitle,
                        // style: theme.textTheme.headlineLarge,
                        // ),
                        Text(
                          'Login to your account',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          onChanged: (value) => username.value = value,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          onChanged: (value) => password.value = value,
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
                                  onPressed: valid
                                      ? () => login(context)
                                      : null,
                                  child: const Text('Login'),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Column()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
