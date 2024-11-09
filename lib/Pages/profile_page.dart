import 'package:flutter/material.dart';
import '../Components/custom_button.dart';
import '../Components/custom_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Для использования kIsWeb
import 'dart:io'; // Для проверки платформы

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', false);
    await prefs.remove('userId');
  }

  @override
  Widget build(BuildContext context) {
    // Проверка, является ли устройство мобильным (не Web)
    bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    Widget content = Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/editUserPage');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1B588C), Color(0xFF848FAC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(24),
                    child: Image.asset(
                      'assets/images/userPhoto.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                const Text(
                  'Anna Montana',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Spacer(),
                const ImageIcon(
                  AssetImage('assets/images/edit.png'),
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        CustomButton(
          iconPath: 'assets/images/lock-circle.png',
          label: 'Change password',
          onTap: () {},
        ),
        const SizedBox(height: 21),
        CustomButton(
          iconPath: 'assets/images/empty-wallet.png',
          label: 'Billing information',
          onTap: () {},
        ),
        const SizedBox(height: 21),
        CustomButton(
          iconPath: 'assets/images/direct-inbox.png',
          label: 'Notifications',
          onTap: () {},
        ),
        isMobile ? 
        const Spacer() : const SizedBox(height: 130),
        Column(
          children: [
            CustomActionButton(
              label: 'Log Out',
              isPrimary: true,
              onTap: () async {
                await _logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
            CustomActionButton(
              label: 'Delete account',
              isPrimary: false,
              onTap: () async {
                await _logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 70),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Color(0xFF192252), fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: isMobile
            ? content
            : SingleChildScrollView( 
                child: content,
              ),
        ),
      ),
    );
  }
}