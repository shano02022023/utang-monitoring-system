import 'package:utang_monitoring_system/db/sql_helper.dart';

class DashboardController {
  static Future<Map<String, dynamic>?> getDashboarData() async {
    final db = await SqlHelper.db();

    // Query for total receivables (from debts table)
    final receivableResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM debts WHERE status = ?',
      ['Pending'],
    );

    // Query for total debts (from my_debts table)
    final debtResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM my_debts WHERE status = ?',
      ['Pending'],
    );

    // Extract totals or default to 0
    final receivableAmount = receivableResult.first['total'] ?? 0;
    final debtAmount = debtResult.first['total'] ?? 0;

    return {
      "receivable": {"ammount": receivableAmount.toString()},
      "debt": {"ammount": debtAmount.toString()},
    };
  }
}
