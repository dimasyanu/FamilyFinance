import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePicture extends StatefulWidget {
  final double radius;
  final String? username;

  const ProfilePicture({super.key, this.username, this.radius = 100});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  Image? profilePicture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchProfilePicture();
    });
  }

  void fetchProfilePicture() async {
    final profilePictureUrl = '$baseUrl/assets/${widget.username}';
    final img = Image.network(profilePictureUrl);
    img.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              if (image.sizeBytes <= 0) return;
              setState(() {
                profilePicture = img;
              });
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              setState(() {
                profilePicture = Image.asset('assets/images/cat.png');
              });
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundImage: profilePicture != null
          ? profilePicture!.image
          : const AssetImage('assets/images/cat.png'),
      backgroundColor: Colors.grey[200],
    );
  }
}
