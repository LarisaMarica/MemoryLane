import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  BiometricScreenState createState() => BiometricScreenState();
}

class BiometricScreenState extends State<BiometricScreen> {
  final AuthService _authService = AuthService();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticate() async {
    Logger logger = Logger();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to login',
      );
    } on PlatformException catch (e) {
      logger.e(e.message ?? 'Error authenticating');
    }

    if (authenticated) {
      String? authenticatedUserId = await _authService.getAuthenticatedUserId();
      if (authenticatedUserId != null) {
        bool userAuthenticated =
            await _authService.authenticateUser(authenticatedUserId);
        if (userAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home-patient');
        }
      }
    }
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
                  Text(
                    'Welcome back to Memory Lane!',
                    style: GoogleFonts.workSans(
                        fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  const Icon(Icons.fingerprint_rounded, size: 100),
                  const SizedBox(height: 40),
                  Text(
                    'Press the Login button and place your finger on the sensor to authenticate.',
                    style: GoogleFonts.workSans(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                                color: Colors.black, width: 2.0)),
                      ),
                      child: Text('Login',
                          style: GoogleFonts.workSans(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Are you a caregiver?',
                          style: GoogleFonts.workSans(fontSize: 20)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: Text('Login here',
                            style: GoogleFonts.workSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    ],
                  ),
                ]),
          )
        ],
      ),
    );
  }
}
