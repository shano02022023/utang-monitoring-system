import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quickalert/quickalert.dart';
import 'package:utang_monitoring_system/views/dashboard.dart';
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

  @override
  void initState() {
    super.initState();
    print(currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Required for 4+ items
      fixedColor: Colors.black,
      backgroundColor: Colors.blue,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.dashboard,
            size: 30,
            color: currentRoute == '/DashboardPage' ? Colors.white : Colors.black,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.money,
            size: 30,
            color: currentRoute == '/MyDebtsPage' ? Colors.white : Colors.black,
          ),
          label: 'Payables',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt_long_rounded,
            size: 30,
            color: currentRoute == '/DebtsPage' ? Colors.white : Colors.black,
          ),
          label: 'Receivables',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.logout_rounded,
            size: 30,
            color: currentRoute == '/Logout' ? Colors.white : Colors.black,
          ),
          label: 'Logout',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Get.offAll(
              () => const DashboardPage(),
              transition: Transition.noTransition,
            );
            break;
          case 1:
            Get.offAll(
              () => const MyDebtsPage(),
              transition: Transition.noTransition,
            );
            break;
          case 2:
            Get.offAll(
              () => const DebtsPage(),
              transition: Transition.noTransition,
            );
            break;
          case 3:
            _logOut(context);
            break;
        }
      },
    );
  }
}
