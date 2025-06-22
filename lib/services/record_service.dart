// lib/services/record_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_record.dart';
import '../services/slot_calculator.dart';

class RecordService {
  static const String _recordsKey = 'practice_records';

  // データを移行するメソッド
  static Future<void> migrateData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];

    bool needsMigration = false;
    List<String> migratedRecords = [];

    for (var record in records) {
      try {
        final data = jsonDecode(record);
        if (!data.containsKey('bellCount')) {
          needsMigration = true;
          // 古いデータに新しいフィールドを追加
          data['bellCount'] = 0;
          data['bellProbability'] = 'Infinity';
        }
        migratedRecords.add(jsonEncode(data));
      } catch (e) {
        print('Error migrating record: $e');
        needsMigration = true;
      }
    }

    if (needsMigration) {
      await prefs.setStringList(_recordsKey, migratedRecords);
    }
  }

  // 全記録を取得する前にデータ移行を実行
  static Future<List<PracticeRecord>> getAllRecords() async {
    await migrateData(); // データ移行を実行

    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];
    return records
        .map((str) => PracticeRecord.fromJson(jsonDecode(str)))
        .toList();
  }

  // 記録を保存
  static Future<void> saveRecord(PracticeRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];
    records.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_recordsKey, records);
  }

  //差枚を入力して保存
  static Future<void> updateCoinDifference(DateTime date, SlotMachine machine, int coinDifference) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];

    final updatedRecords = records.map((record) {
      final data = jsonDecode(record);
      if (data['date'] == date.toIso8601String() && data['machine'] == machine.toString()) {
        data['coinDifference'] = coinDifference;
      }
      return jsonEncode(data);
    }).toList();

    await prefs.setStringList(_recordsKey, updatedRecords);
  }

  static Future<Map<SlotMachine, Map<String, dynamic>>> getMachineSummaries() async {
    final records = await getAllRecords();
    Map<SlotMachine, Map<String, dynamic>> summaries = {};

    for (var record in records) {
      if (!summaries.containsKey(record.machine)) {
        summaries[record.machine] = {
          'totalGames': 0,
          'totalBigCount': 0,
          'totalRegCount': 0,
          'totalbellCount': 0,
          'totalCoinDifference': 0,  // 追加
        };
      }

      var summary = summaries[record.machine]!;
      summary['totalGames'] += record.gameCount;

      if (!record.bigProbability.isInfinite && !record.bigProbability.isNaN) {
        summary['totalBigCount'] += (record.gameCount / record.bigProbability).round();
      }
      if (!record.regProbability.isInfinite && !record.regProbability.isNaN) {
        summary['totalRegCount'] += (record.gameCount / record.regProbability).round();
      }
      summary['totalbellCount'] += record.bellCount;
      if (record.coinDifference != null) {
        summary['totalCoinDifference'] += record.coinDifference!;
      }
    }

    summaries.forEach((machine, data) {
      if (data['totalGames'] > 0) {
        if (data['totalBigCount'] > 0) {
          data['avgBigProbability'] = data['totalGames'] / data['totalBigCount'];
        } else {
          data['avgBigProbability'] = double.infinity;
        }

        if (data['totalRegCount'] > 0) {
          data['avgRegProbability'] = data['totalGames'] / data['totalRegCount'];
        } else {
          data['avgRegProbability'] = double.infinity;
        }

        // ベルの確率を計算 (追加)
        if (data['totalbellCount'] > 0) {
          data['avgbellProbability'] = data['totalGames'] / data['totalbellCount'];
        } else {
          data['avgbellProbability'] = double.infinity;
        }

        data['totalBonusCount'] = data['totalBigCount'] + data['totalRegCount'];
        if (data['totalBonusCount'] > 0) {
          data['avgTotalProbability'] = data['totalGames'] / data['totalBonusCount'];
        } else {
          data['avgTotalProbability'] = double.infinity;
        }
      }
    });

    return summaries;
  }

  // 特定の記録を削除
  static Future<void> deleteRecord(DateTime date, SlotMachine machine) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];

    records.removeWhere((record) {
      final recordData = PracticeRecord.fromJson(jsonDecode(record));
      return recordData.date.isAtSameMomentAs(date) &&
          recordData.machine == machine;
    });

    await prefs.setStringList(_recordsKey, records);
  }

  // 複数の記録を削除
  static Future<void> deleteRecords(List<PracticeRecord> recordsToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_recordsKey) ?? [];

    records.removeWhere((record) {
      final recordData = PracticeRecord.fromJson(jsonDecode(record));
      return recordsToDelete.any((r) =>
      r.date.isAtSameMomentAs(recordData.date) &&
          r.machine == recordData.machine
      );
    });

    await prefs.setStringList(_recordsKey, records);
  }

  static String getProbabilityFraction(double probability) {
    if (probability.isInfinite || probability.isNaN) return "－";
    double roundedProbability = double.parse(probability.toStringAsFixed(2));
    return "1/$roundedProbability";
  }
}