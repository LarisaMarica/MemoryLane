import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/firebase/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return WelcomeScreenState();
  }
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService authService = AuthService();
  String? authenticatedUserId;

  @override
  void initState() {
    super.initState();
    authService.getAuthenticatedUserId().then((String? value) {
      authenticatedUserId = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  kPrimaryLightColor,
                  kSecondaryLightColor,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo-background.png',
                  height: 600,
                  width: 600,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200, 
                  child: ElevatedButton(
                    onPressed: () {
                      if (authenticatedUserId != null) {
                        Navigator.pushNamed(context, '/biometric');
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                              color: Colors.black, width: 2.0)),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.workSans(fontSize: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200, 
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: GoogleFonts.workSans(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
