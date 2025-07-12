// lib/screens/records_screen.dart

import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../services/record_service.dart';
import '../services/slot_calculator.dart';
import 'monthly_summaries_tab.dart';
import 'yearly_and_total_summaries_tab.dart'; // 新しく追加したファイル

class RecordsScreen extends StatefulWidget {
  @override
  _RecordsScreenState createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<PracticeRecord> _records = [];
  Map<SlotMachine, Map<String, dynamic>> _summaries = {};
  Set<PracticeRecord> _selectedRecords = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final records = await RecordService.getAllRecords();
      final summaries = await RecordService.getMachineSummaries();
      if (mounted) {
        setState(() {
          _records = records..sort((a, b) => b.date.compareTo(a.date));
          _summaries = summaries;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データの読み込み中にエラーが発生しました'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showCoinDifferenceDialog(PracticeRecord record) async {
    final controller = TextEditingController(
      text: record.coinDifference?.toString() ?? '',
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('差枚数の入力'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(record.date)}\n'
                  '${_getMachineName(record.machine)}\n'
                  '実践G数: ${record.gameCount}G',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                labelText: '差枚数',
                suffix: Text('枚'),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null) {
                await RecordService.updateCoinDifference(
                  record.date,
                  record.machine,
                  value,
                );
                Navigator.pop(context);
                _loadData();  // データを再読み込み
              }
            },
            child: Text('保存'),
          ),
        ],
      ),
    );
  }

  String _getMachineName(SlotMachine machine) {
    switch (machine) {
      case SlotMachine.kingHanahana:
        return 'キングハナハナ';
      case SlotMachine.hanahanaHouou:
        return 'ハナハナホウオウ天翔';
      case SlotMachine.dragonHanahana:
        return 'ドラゴンハナハナ閃光';
      case SlotMachine.starHanahana:
        return 'スターハナハナ';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteSelectedRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('削除の確認'),
        content: Text('選択した${_selectedRecords.length}件の記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await RecordService.deleteRecords(_selectedRecords.toList());
      await _loadData();
      setState(() {
        _selectedRecords.clear();
        _isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選択した記録を削除しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('実践記録'),
          actions: [
            if (_records.isNotEmpty) ...[
              if (_isSelectionMode) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedRecords.length == _records.length) {
                        _selectedRecords.clear();
                      } else {
                        _selectedRecords = Set.from(_records);
                      }
                    });
                  },
                  child: Text(
                    _selectedRecords.length == _records.length ? '全解除' : '全選択',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _selectedRecords.isEmpty ? null : _deleteSelectedRecords,
                ),
              ],
              IconButton(
                icon: Icon(_isSelectionMode ? Icons.close : Icons.select_all),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    if (!_isSelectionMode) {
                      _selectedRecords.clear();
                    }
                  });
                },
              ),
            ],
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: '記録一覧'),
              Tab(text: '機種別集計'),
              Tab(text: '月別集計'),
              Tab(text: '年別・通算'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecordsList(),
            _buildMachineSummaries(),
            MonthlySummariesTab(records: _records),
            YearlyAndTotalSummariesTab(records: _records),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return Center(
        child: Text('記録がありません'),
      );
    }

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final isSelected = _selectedRecords.contains(record);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: _isSelectionMode
                ? () {
              setState(() {
                if (isSelected) {
                  _selectedRecords.remove(record);
                } else {
                  _selectedRecords.add(record);
                }
              });
            }
                : () => _showCoinDifferenceDialog(record),
            onLongPress: !_isSelectionMode
                ? () {
              setState(() {
                _isSelectionMode = true;
                _selectedRecords.add(record);
              });
            }
                : null,
            child: Container(
              color: isSelected ? Colors.blue.withOpacity(0.1) : null,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getMachineName(record.machine),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(record.date),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('実践G数: ${record.gameCount}G'),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'BIG確率: ${RecordService.getProbabilityFraction(record.bigProbability)}',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'REG確率: ${RecordService.getProbabilityFraction(record.regProbability)}',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ベル確率: ${RecordService.getProbabilityFraction(record.bellProbability)} (${record.bellCount}回)',
                    ),
                    if (record.coinDifference != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '差枚数: ${record.coinDifference}枚',
                        style: TextStyle(
                          color: record.coinDifference! >= 0
                              ? Colors.blue
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMachineSummaries() {
    if (_summaries.isEmpty) {
      return Center(
        child: Text('記録がありません'),
      );
    }

    return ListView.builder(
      itemCount: _summaries.length,
      itemBuilder: (context, index) {
        final machine = _summaries.keys.elementAt(index);
        final summary = _summaries[machine]!;
        final totalCoinDifference = summary['totalCoinDifference'] ?? 0;
        final totalGames = summary['totalGames'] ?? 0;

        // 機械割の計算
        double machinePercentage = 100.0;  // デフォルト値
        if (totalGames > 0) {
          // (総実践ゲーム数×3 + 総差枚数) / (総実践ゲーム数×3) × 100
          machinePercentage = ((totalGames * 3 + totalCoinDifference) / (totalGames * 3)) * 100;
        }

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMachineName(machine),
                  style: TextStyle(
                    fontSize: 16,
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
                  '総回数: ${summary['totalbellCount']}回\n'
                      '確率: ${RecordService.getProbabilityFraction(summary['avgbellProbability'] ?? double.infinity)}',
                ),
                if (totalCoinDifference != 0) ...[
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '総差枚数: ${totalCoinDifference}枚',
                        style: TextStyle(
                          color: totalCoinDifference >= 0 ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '機械割: ${machinePercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: machinePercentage >= 100 ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}