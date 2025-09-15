import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/login_response.dart';
import 'package:family_financial_app/models/responses/res.dart';
import 'package:family_financial_app/app.dart';
import 'package:family_financial_app/plugins/api_auth.dart';
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
  bool loading = true;
  bool showPassword = false;
  ApiAuth? apiAuth;

  late final ValueNotifier<bool> isFormValid = ValueNotifier(
    username.value.isNotEmpty && password.value.isNotEmpty,
  );

  @override
  void initState() {
    super.initState();

    apiAuth = ApiAuth(context);
    username.addListener(_updateFormValid);
    password.addListener(_updateFormValid);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkUser(context);
    });
  }

  void _updateFormValid() {
    isFormValid.value = username.value.isNotEmpty && password.value.isNotEmpty;
  }

  @override
  void dispose() {
    username.removeListener(_updateFormValid);
    password.removeListener(_updateFormValid);
    isFormValid.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<bool> checkUser(BuildContext context) async {
    final store = context.read<Store>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => loading = true);

    try {
      final userData = await store.get(StorageKey.login);
      if (userData == null || userData.isEmpty) return false;

      final loginResponse = LoginResponse.fromJson(userData);

      final now = DateTime.now();
      if (loginResponse.username.isNotEmpty &&
          loginResponse.accessToken.isNotEmpty &&
          loginResponse.expiration.isAfter(now)) {
        if (!await fetchUserData(store, messenger, loginResponse.accessToken)) {
          return false;
        }

        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => const App()),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error reading user data: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error reading user data'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              await checkUser(context);
            },
          ),
        ),
      );
      return false;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> fetchUserData(
    Store store,
    ScaffoldMessengerState messenger,
    String accessToken,
  ) async {
    final user = await apiAuth?.userInfo(accessToken);

    if (user == null || user.hasError || !user.success || user.data == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(user?.message ?? 'Failed to load user data')),
      );
      return false;
    }
    store.set(StorageKey.user, user.data!);
    return true;
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
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return LoaderOverlay(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/drawing.png'),
                  fit: BoxFit.fitWidth,
                  alignment: AlignmentGeometry.topCenter,
                ),
              ),
              child: Form(
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Sign In text
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 0,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                width: 70,
                                child: Divider(
                                  color: theme.colorScheme.primary,
                                  thickness: 3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        Container(
                          alignment: Alignment.centerLeft,
                          padding: null,
                          child: Text(
                            'Username',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              height: 0,
                            ),
                          ),
                        ),

                        SizedBox(height: 5),

                        // Username fields
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your username',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              weight: 15,
                              size: 15,
                              color: Colors.grey[500],
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            isDense: true,
                            contentPadding: null,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          cursorHeight: 20,
                          onChanged: (value) => username.value = value,
                        ),

                        SizedBox(height: 32),

                        Container(
                          alignment: Alignment.centerLeft,
                          padding: null,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              height: 0,
                            ),
                          ),
                        ),

                        SizedBox(height: 5),

                        // Password field
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              weight: 15,
                              size: 15,
                              color: Colors.grey[500],
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                weight: 15,
                                size: 15,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                            suffixIconConstraints: BoxConstraints(
                              maxWidth: 32,
                              maxHeight: 32,
                            ),
                            isDense: true,
                            contentPadding: null,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1,
                              ),
                            ),
                          ),
                          cursorHeight: 20,
                          obscureText: !showPassword,
                          onChanged: (value) => password.value = value,
                        ),

                        SizedBox(height: 80),

                        // Login button
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
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
