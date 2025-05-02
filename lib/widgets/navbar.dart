import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quickalert/quickalert.dart';
import 'package:utang_monitoring_system/views/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:utang_monitoring_system/views/debts/debts.dart';
import 'package:utang_monitoring_system/views/my_debts/my_debts.dart';
import 'package:utang_monitoring_system/views/welcome.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool isDownloadingBackup = false;
  final box = GetStorage();
  String currentRoute = Get.currentRoute;

  void _logOut(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Are you sure you want to log out?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        Get.offAll(() => const WelcomePage());
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final userData = {'name': "user", 'email': "user@email.com"};
    if (userData.isNotEmpty) {
      return userData;
    } else {
      return null; // or handle the case when user data is not available
    }
  }

  @override
  void initState() {
    super.initState();
    print(currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (
          BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors that occur
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      'Unknown User',
                      style: GoogleFonts.poppins(),
                    ),
                    accountEmail: Column(
                      children: [
                        Text('No Email', style: GoogleFonts.poppins()),
                        Text('No Role', style: GoogleFonts.poppins()),
                      ],
                    ),
                    currentAccountPicture: const CircleAvatar(
                      child: Icon(Icons.person, size: 80),
                    ),
                    decoration: const BoxDecoration(color: Colors.blue),
                  ),
                  _buildDrawerItems(),
                ],
              ),
            );
          } else {
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      '',
                      style: GoogleFonts.poppins(),
                    ),
                    accountEmail: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/dark_zuckerburg.jpg',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    decoration: const BoxDecoration(color: Colors.blue),
                  ),
                  _buildDrawerItems(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawerItems() {
    return Column(
      children: [
        ListTile(
          tileColor:
              currentRoute == '/DashboardPage' ? Colors.blue[100] : null,
          leading: const Icon(Icons.dashboard),
          title: Text('Dashboard', style: GoogleFonts.poppins()),
          onTap: () {
            Get.to(() => const DashboardPage());
          },
        ),
        ListTile(
          tileColor:
              currentRoute == '/DebtsPage' ? Colors.blue[100] : null,
          leading: const Icon(Icons.monetization_on_sharp),
          title: Text('Receivable', style: GoogleFonts.poppins()),
          onTap: () {
            Get.to(() => const DebtsPage());
          },
        ),
        ListTile(
          tileColor:
              currentRoute == '/MyDebtsPage' ? Colors.blue[100] : null,
          leading: const Icon(Icons.money_off),
          title: Text('Payable', style: GoogleFonts.poppins()),
          onTap: () {
            Get.to(() => const MyDebtsPage());
          },
        ),
        Builder(
          builder: (context) {
            return ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Log out', style: GoogleFonts.poppins()),
              onTap: () {
                _logOut(context);
              },
            );
          },
        ),
      ],
    );
  }
}
