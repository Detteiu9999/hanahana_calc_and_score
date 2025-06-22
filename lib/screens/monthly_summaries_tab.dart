// lib/screens/monthly_summaries_tab.dart

import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../services/record_service.dart';

class MonthlySummariesTab extends StatelessWidget {
  final List<PracticeRecord> records;

  const MonthlySummariesTab({Key? key, required this.records}) : super(key: key);

  Map<String, Map<String, dynamic>> _calculateMonthlySummaries() {
    Map<String, Map<String, dynamic>> summaries = {};

    for (var record in records) {
      String monthKey = '${record.date.year}/${record.date.month.toString().padLeft(2, '0')}';

      if (!summaries.containsKey(monthKey)) {
        summaries[monthKey] = {
          'totalGames': 0,
          'totalBigCount': 0,
          'totalRegCount': 0,
          'totalBudouCount': 0,
          'totalCoinDifference': 0,
        };
      }

      var summary = summaries[monthKey]!;
      summary['totalGames'] += record.gameCount;

      if (!record.bigProbability.isInfinite && !record.bigProbability.isNaN) {
        summary['totalBigCount'] += (record.gameCount / record.bigProbability).round();
      }

      if (!record.regProbability.isInfinite && !record.regProbability.isNaN) {
        summary['totalRegCount'] += (record.gameCount / record.regProbability).round();
      }

      summary['totalBudouCount'] += record.bellCount;

      if (record.coinDifference != null) {
        summary['totalCoinDifference'] += record.coinDifference!;
      }
    }

    // 確率と機械割の計算
    summaries.forEach((month, data) {
      if (data['totalGames'] > 0) {
        // BIG確率
        if (data['totalBigCount'] > 0) {
          data['avgBigProbability'] = data['totalGames'] / data['totalBigCount'];
        } else {
          data['avgBigProbability'] = double.infinity;
        }

        // REG確率
        if (data['totalRegCount'] > 0) {
          data['avgRegProbability'] = data['totalGames'] / data['totalRegCount'];
        } else {
          data['avgRegProbability'] = double.infinity;
        }

        // ぶどう確率
        if (data['totalBudouCount'] > 0) {
          data['avgBudouProbability'] = data['totalGames'] / data['totalBudouCount'];
        } else {
          data['avgBudouProbability'] = double.infinity;
        }

        // 機械割の計算
        double machineEfficiency = 100.0;
        if (data['totalGames'] > 0) {
          machineEfficiency = ((data['totalGames'] * 3 + data['totalCoinDifference']) / (data['totalGames'] * 3)) * 100;
        }
        data['machineEfficiency'] = machineEfficiency;
      }
    });

    return Map.fromEntries(
        summaries.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key))
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlySummaries = _calculateMonthlySummaries();

    if (monthlySummaries.isEmpty) {
      return Center(
        child: Text('記録がありません'),
      );
    }

    return ListView.builder(
      itemCount: monthlySummaries.length,
      itemBuilder: (context, index) {
        final month = monthlySummaries.keys.elementAt(index);
        final summary = monthlySummaries[month]!;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('総実践G数: ${summary['totalGames']}G'),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('総BIG回数: ${summary['totalBigCount']}回'),
                          Text(
                            'BIG確率: ${RecordService.getProbabilityFraction(summary['avgBigProbability'] ?? double.infinity)}',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('総REG回数: ${summary['totalRegCount']}回'),
                          Text(
                            'REG確率: ${RecordService.getProbabilityFraction(summary['avgRegProbability'] ?? double.infinity)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                Text('ベル'),
                Text(
                  '総回数: ${summary['totalBudouCount']}回\n'
                      '確率: ${RecordService.getProbabilityFraction(summary['avgBudouProbability'] ?? double.infinity)}',
                ),
                if (summary['totalCoinDifference'] != 0) ...[
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '総差枚数: ${summary['totalCoinDifference']}枚',
                        style: TextStyle(
                          color: summary['totalCoinDifference'] >= 0 ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '機械割: ${summary['machineEfficiency'].toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: summary['machineEfficiency'] >= 100 ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}