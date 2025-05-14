import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utang_monitoring_system/db/sql_helper.dart';

class DebtsController {
  static Future<int> addDebt(
    String firstName,
    String middleName,
    String lastName,
    int amount,
    String remarks,
  ) async {
    try {
      if (firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          amount != 0 &&
          remarks.isNotEmpty &&
          (middleName.length < 2 || middleName.isNotEmpty)) {
        return await SqlHelper.db().then((db) async {
          final id = DateTime.now().toIso8601String();
          final createdAt = DateTime.now().toString();
          final updatedAt = DateTime.now().toString();

          Get.snackbar(
            'Success',
            'Debt added successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          return await db.insert('debts', {
            'id': id,
            'firstname': firstName,
            'middlename': middleName,
            'lastname': lastName,
            'amount': amount,
            'status': 'Pending',
            'remarks': remarks,
            'created_at': createdAt,
            'updated_at': updatedAt,
          });
        });
      } else {
        Get.snackbar(
          'Error',
          'Please fill in all fields correctly',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return -1;
      }
    } catch (e) {
      print('Error adding debt: ${e.toString()}');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getDebts(
    String filterStatus,
  ) async {
    final db = await SqlHelper.db();

    return await db.query('debts', orderBy: 'updated_at DESC').then((debts) {
      if (filterStatus == '') {
        return debts;
      } else {
        return debts
            .where(
              (debt) => debt['status'].toString() == filterStatus.toString(),
            )
            .toList();
      }
    });
  }

  static Future<int> updateDebt(String id, String status) async {
    try {
      final db = await SqlHelper.db();
      final updatedAt = DateTime.now().toString();

      return await db.update(
        'debts',
        {'status': status, 'updated_at': updatedAt},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating debt: ${e.toString()}');
      return -1;
    }
  }

  static Future<int> deleteDebt(String id) async {
    final db = await SqlHelper.db();

    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateStatus(String remarks, int id) async {
    try {
      final db = await SqlHelper.db();
      final updatedAt = DateTime.now().toString();

      return db.update(
        'debts',
        {'status': 'paid', 'remarks': remarks, 'updated_at': updatedAt},
        where: 'id = ? AND status = ?',
        whereArgs: [id, 'pending'],
      );
    } catch (e) {
      print('Error updating status: ${e.toString()}');
      return -1;
    }
  }

  static Future<int> uploadProofAndUpdateStatus(
    String proofCompletedPhoto,
    String id,
    String? status,
    String remarks,
  ) async {
    try {
      final db = await SqlHelper.db();
      final updatedAt = DateTime.now().toString();

      return db.update(
        'debts',
        {
          'proof_completed_photo': proofCompletedPhoto,
          'updated_at': updatedAt,
          'status': status,
          'remarks': remarks,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error uploading proof: ${e.toString()}');
      return -1;
    }
  }
}
