import 'package:family_financial_app/abstractions/store.dart';
import 'package:family_financial_app/components/profile_picture.dart';
import 'package:family_financial_app/constants/storage_key.dart';
import 'package:family_financial_app/models/responses/dto_user.dart';
import 'package:family_financial_app/plugins/api_user.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  static const currentKey = 'SettingsPage';
  final String title = 'Settings';

  const SettingsPage() : super(key: const Key(currentKey));

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Image? profilePicture;
  ApiUser? apiUser;

  bool _isLoading = true;
  bool? _isDarkTheme = false;
  DtoUser? user;

  @override
  void initState() {
    super.initState();

    apiUser = ApiUser(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadUserData();
    });
  }

  Future<void> loadUserData() async {
    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<Store>();
    final userData = await store.get(StorageKey.user);
    if (userData == null || userData.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Error loading user data')),
      );
      return;
    }
    final isDarkThemeStr = await store.getString(StorageKey.isDarkTheme);

    setState(() {
      _isLoading = false;
      user = DtoUser.fromJson(userData);
      _isDarkTheme = isDarkThemeStr == 'true';
    });
  }

  Future<void> setDarkTheme(bool isDark) async {
    setState(() {
      _isDarkTheme = isDark;
    });

    final store = context.read<Store>();
    await store.setString(StorageKey.isDarkTheme, isDark.toString());
    await store.reloadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: LoaderOverlay(
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              context.loaderOverlay.show();
            } else {
              context.loaderOverlay.hide();
            }

            if (user == null) {
              return const Text(
                'Loading...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: ProfilePicture(username: user?.username),
                ),
                Text(
                  user!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text('Dark Theme'),
                        trailing: Switch(
                          value: _isDarkTheme ?? false,
                          onChanged: (value) async {
                            await setDarkTheme(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    apiUser = null;
    profilePicture = null;
    super.dispose();
  }
}
