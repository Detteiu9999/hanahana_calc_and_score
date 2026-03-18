// lib/screens/machine_parameters_screen.dart

import 'package:flutter/material.dart';
import '../services/slot_calculator.dart';

class MachineParametersScreen extends StatelessWidget {
  final SlotMachine machine;
  final Map<String, double> currentValues;

  const MachineParametersScreen({
    Key? key,
    required this.machine,
    required this.currentValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = SlotCalculator.machineParameters[machine]!;
    final machineName = _getMachineName(machine);

    return Scaffold(
      appBar: AppBar(
        title: Text('$machineNameのパラメータ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParameterSection('基本パラメータ', {
                'PAYOUT': params['payout']!,
                'BIG': params['single_big']!,
                'REG': params['single_reg']!,
                'ベル': params['bell']!,
              }, {
                'BIG': currentValues['single_big'],
                'REG': currentValues['single_reg'],
                'ベル': currentValues['bell'],
              }),
              _buildParameterSection('BIG関連', {
                'BIG中スイカ': params['big_suika']!,
                'BIGレトロサウンド': params['big_retro_sound']!,
                'BIG後青': params['big_blue']!,
                'BIG後黄': params['big_yellow']!,
                'BIG後緑': params['big_green']!,
                'BIG後赤': params['big_red']!,
                'BIG後虹': params['big_rainbow']!,
                'BIG後白': params['big_white']!,
              }, {
                'BIG中スイカ': currentValues['big_suika'],
                'BIGレトロサウンド': currentValues['big_retro_sound'],
                'BIG後青': currentValues['big_blue'],
                'BIG後黄': currentValues['big_yellow'],
                'BIG後緑': currentValues['big_green'],
                'BIG後赤': currentValues['big_red'],
                'BIG後虹': currentValues['big_rainbow'],
                'BIG後白': currentValues['big_white'],
              }),
              _buildParameterSection('REG関連', {
                'REGサイド青': params['side_blue']!,
                'REGサイド黄': params['side_yellow']!,
                'REGサイド緑': params['side_green']!,
                'REGサイド赤': params['side_red']!,
                'REGサイド虹': params['side_rainbow']!,
                'REG後青': params['reg_blue']!,
                'REG後黄': params['reg_yellow']!,
                'REG後緑': params['reg_green']!,
                'REG後赤': params['reg_red']!,
                'REG後虹': params['reg_rainbow']!,
                'REG後白': params['reg_white']!,
              }, {
                'REGサイド青': currentValues['side_blue'],
                'REGサイド黄': currentValues['side_yellow'],
                'REGサイド緑': currentValues['side_green'],
                'REGサイド赤': currentValues['side_red'],
                'REGサイド虹': currentValues['side_rainbow'],
                'REG後青': currentValues['reg_blue'],
                'REG後黄': currentValues['reg_yellow'],
                'REG後緑': currentValues['reg_green'],
                'REG後赤': currentValues['reg_red'],
                'REG後虹': currentValues['reg_rainbow'],
                'REG後白': currentValues['reg_white'],
              }),
              _buildParameterSection('着席時データカウンター', {
                'BIG合算': params['big_sum']!,
                'REG合算': params['reg_sum']!,
              }, {
                'BIG合算': currentValues['big_sum'],
                'REG合算': currentValues['reg_sum'],
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterSection(
      String title,
      Map<String, List<double>> parameters,
      Map<String, double?> currentValues,
      ) {
    final entries = parameters.entries.toList();
    final rows = (entries.length / 2).ceil();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...List.generate(rows, (rowIndex) {
              final startIndex = rowIndex * 2;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildParameterItem(entries[startIndex], currentValues),
                  ),
                  SizedBox(width: 8),
                  if (startIndex + 1 < entries.length)
                    Expanded(
                      child: _buildParameterItem(
                          entries[startIndex + 1], currentValues),
                    )
                  else
                    Expanded(child: Container()),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterItem(
      MapEntry<String, List<double>> entry,
      Map<String, double?> currentValues,
      ) {
    final currentValue = currentValues[entry.key];
    List<int>? closestSettingIndices;
    double? minDifference;

    if (currentValue != null) {
      closestSettingIndices = [];
      for (int i = 0; i < entry.value.length; i++) {
        double difference = (entry.value[i] - currentValue).abs();
        if (minDifference == null || difference < minDifference) {
          minDifference = difference;
          closestSettingIndices = [i];
        } else if (difference == minDifference) {
          closestSettingIndices?.add(i);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.key),
              ),
              if (currentValue != null) ...[
                SizedBox(width: 8),
                Text(
                  '(現在: ${currentValue.toStringAsFixed(3)})',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          Column(
            children: List.generate(6, (index) {
              bool isClosest = closestSettingIndices?.contains(index) ?? false;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isClosest ? Colors.blue : Colors.grey,
                    width: isClosest ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: isClosest ? Colors.blue.withOpacity(0.1) : null,
                ),
                child: Text(
                  '設定${index + 1}: ${entry.value[index].toStringAsFixed(3)}',
                  style: TextStyle(
                    fontWeight: isClosest ? FontWeight.bold : FontWeight.normal,
                    color: isClosest ? Colors.blue : null,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8),
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
      case SlotMachine.newKingHanahanaV:
        return 'ニューキングハナハナV';
    }
  }
}