import 'package:flutter/material.dart';
import 'package:utang_monitoring_system/controller/dashboard_controller.dart';
import 'package:utang_monitoring_system/layouts/main_layout.dart';
import 'package:utang_monitoring_system/widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> _dashboardData = {};
  bool isLoading = false;

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });
    final _data = await DashboardController.getDashboarData();

    setState(() {
      _dashboardData =
          _data ??
          {
            'receivable': {'ammount': 0},
            'debt': {'ammount': 0},
          };

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return StatsCard(
                      title: 'Receivable',
                      value:
                          _dashboardData['receivable']['ammount']!.toString(),
                      icon: Icons.monetization_on,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
                Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return StatsCard(
                      title: 'Debt',
                      value:
                          _dashboardData['debt']['ammount']!.toString(),
                      icon: Icons.monetization_on,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
