import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utang_monitoring_system/services/local_auth.dart';
import 'package:utang_monitoring_system/views/dashboard.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLoading = false;
  bool isDataBaseNotCreated = false;
  Map<String, dynamic> userDetails = {};
  final box = GetStorage();
  bool isLoggingIn = false;

  void logIn() async {
    setState(() {
      isLoggingIn = true;
    });
    final authenticated = await LocalAuth.authenticate();
    if (authenticated) {
      box.write('classOfficerActiveTile', 'dashboard');
      Get.to(() => const DashboardPage());
      setState(() {
        isLoggingIn = false;
      });
    } else {
      setState(() {
        isLoggingIn = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/dark_zuckerburg.jpg', width: 200),
            Text(
              'Welcome',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('UTANG MONITORING SYSTEM'),
            const Text('Version: v0.0.0'),
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          logIn();
                        },
                        child:
                            isLoggingIn
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Log in',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
