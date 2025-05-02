import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    try {
      await database.execute('''CREATE TABLE debts(
          id TEXT PRIMARY KEY, 
          firstname TEXT,
          middlename TEXT,
          lastname TEXT,
          amount INTEGER,
          status TEXT,
          remarks TEXT,
          proof_completed_photo TEXT,
          created_at TEXT,
          updated_at TEXT
        )''');
      await database.execute('''CREATE TABLE my_debts(
          id TEXT PRIMARY KEY,
          firstname TEXT,
          middlename TEXT,
          lastname TEXT,
          amount INTEGER,
          status TEXT,
          remarks TEXT,
          proof_completed_photo TEXT,
          created_at TEXT,
          updated_at TEXT
        )''');
    } catch (e) {
      print('Error creating tables: $e');
    }
  }

  static Future<sql.Database> db() async {
    final databasesPath = await sql.getDatabasesPath();
    final path = join(databasesPath, 'utang_monitoring_system.db');
    final database = await sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database db, int version) async {
        print('Creating a new database and tables');
        await createTables(db); // Create tables as per your requirement
      },
    );

    return database;
  }

  static Future<File> getDatabaseFile() async {
    String databasesPath = await getDatabasesPath();

    String path = join(databasesPath, 'utang_monitoring_system.db');

    File databaseFile = File(path);
    if (await databaseFile.exists()) {
      return databaseFile;
    } else {
      throw Exception('Database file not found');
    }
  }

  // static Future<void> printAllDatabases() async {
  //   // Get the path where the databases are stored
  //   String databasesPath = await getDatabasesPath();
  //   print('Databases path: $databasesPath');

  //   // List all files in the databases directory
  //   Directory databasesDirectory = Directory(databasesPath);
  //   List<FileSystemEntity> files = databasesDirectory.listSync();

  //   // Filter and print only the database files
  //   for (var file in files) {
  //     if (file is File && file.path.endsWith('.db')) {
  //       print('Database file: ${basename(file.path)}');
  //     }
  //   }
  // }

  static Future<int> importDatabase(File sourceFile) async {
    try {
      if (!sourceFile.path.contains('utang_monitoring_system')) {
        return -1;
      }

      String databasesPath = await getDatabasesPath();
      String destinationPath = join(
        databasesPath,
        'utang_monitoring_system.db',
      );
      File databaseFile = File(destinationPath);

      var db = await openDatabase('utang_monitoring_system.db');

      await db.close();

      if (await databaseFile.exists()) {
        await databaseFile.delete();
      }

      final sourceBytes = await sourceFile.readAsBytes();

      final newDatabaseFile = await File(
        destinationPath,
      ).writeAsBytes(sourceBytes);
      print(
        'New database file written: ${await newDatabaseFile.length()} bytes',
      );

      if (await newDatabaseFile.exists()) {
        Get.snackbar(
          'Success',
          'Database imported successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return 1;
      } else {
        Get.snackbar(
          'Error',
          'Something went wrong during the import.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return -1;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error importing the database: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error importing the database: $e');
      return -1;
    }
  }
}
