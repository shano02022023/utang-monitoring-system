import 'package:flutter/material.dart';
import 'package:utang_monitoring_system/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const Navbar(), // Drawer for all pages
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('UTANG MONITORING SYSTEM',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: child, // Display the page's content here
    );
  }
}