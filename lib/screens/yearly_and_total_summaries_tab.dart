// lib/screens/yearly_and_total_summaries_tab.dart

import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../services/record_service.dart';

class YearlyAndTotalSummariesTab extends StatelessWidget {
  final List<PracticeRecord> records;

  const YearlyAndTotalSummariesTab({Key? key, required this.records}) : super(key: key);

  Map<String, Map<String, dynamic>> _calculateYearlyAndTotalSummaries() {
    Map<String, Map<String, dynamic>> summaries = {};

    if (records.isEmpty) {
      return summaries;
    }

    // 通算集計用のマップを初期化
    summaries['通算'] = {
      'totalGames': 0,
      'totalBigCount': 0,
      'totalRegCount': 0,
      'totalBudouCount': 0,
      'totalCoinDifference': 0,
    };

    for (var record in records) {
      String yearKey = '${record.date.year}年';

      // 年ごとの集計用マップを初期化
      if (!summaries.containsKey(yearKey)) {
        summaries[yearKey] = {
          'totalGames': 0,
          'totalBigCount': 0,
          'totalRegCount': 0,
          'totalBudouCount': 0,
          'totalCoinDifference': 0,
        };
      }

      // 通算と年ごとの両方のデータを加算
      for (String key in ['通算', yearKey]) {
        var summary = summaries[key]!;
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
    }

    // 確率と機械割を計算
    summaries.forEach((key, data) {
      if (data['totalGames'] > 0) {
        data['avgBigProbability'] = (data['totalBigCount'] > 0) ? data['totalGames'] / data['totalBigCount'] : double.infinity;
        data['avgRegProbability'] = (data['totalRegCount'] > 0) ? data['totalGames'] / data['totalRegCount'] : double.infinity;
        data['avgBudouProbability'] = (data['totalBudouCount'] > 0) ? data['totalGames'] / data['totalBudouCount'] : double.infinity;

        // ### 修正点 ###
        // 計算をより安全な形に修正
        double machineEfficiency = 100.0;
        final totalGames = data['totalGames'];
        final totalCoinDifference = data['totalCoinDifference'];

        if (totalGames > 0) {
          final totalIn = totalGames * 3;
          if (totalIn > 0) {
            // Dartの `/` 演算子は自動的にdouble型の結果を返すため、安全に計算できる
            machineEfficiency = ((totalIn + totalCoinDifference) / totalIn) * 100;
          }
        }
        data['machineEfficiency'] = machineEfficiency;
      }
    });

    // 表示順（通算 -> 年の降順）にソート
    final sortedKeys = summaries.keys.toList();
    sortedKeys.remove('通算');
    sortedKeys.sort((a, b) => b.compareTo(a)); // 年で降順ソート
    sortedKeys.insert(0, '通算');

    final sortedSummaries = { for (var k in sortedKeys) k : summaries[k]! };
    return sortedSummaries;
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _calculateYearlyAndTotalSummaries();

    if (summaries.isEmpty) {
      return Center(
        child: Text('記録がありません'),
      );
    }

    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final key = summaries.keys.elementAt(index);
        final summary = summaries[key]!;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key, // "通算" or "XXXX年"
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
                        '機械割: ${summary['machineEfficiency']?.toStringAsFixed(2) ?? 'N/A'}%',
                        style: TextStyle(
                          color: (summary['machineEfficiency'] ?? 0) >= 100 ? Colors.blue : Colors.red,
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