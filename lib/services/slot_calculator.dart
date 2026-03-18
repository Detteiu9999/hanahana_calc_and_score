// lib/services/slot_calculator.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/calculation_result.dart';

enum SlotMachine {
  kingHanahana,
  hanahanaHouou,
  dragonHanahana,
  starHanahana,
  newKingHanahanaV
}

class SlotCalculator {
  static const Map<SlotMachine, Map<String, List<double>>> machineParameters = {
    SlotMachine.kingHanahana: {
      'payout': [97, 99, 101, 104, 107, 110],
      'single_big': [292, 280, 268, 257, 244, 232],
      'single_reg': [489, 452, 420, 390, 360, 332],
      'bell': [7.22, 7.218, 7.216, 7.077, 7.005, 6.967],
      'big_game_num': [21], //BIGゲーム回数
      'big_suika': [42.89, 39.01, 36.21, 32.25, 30.01, 28.01], //BIG中スイカ回数
      'big_retro_sound': [48.0, 48.0, 48.0, 48.0, 48.0, 48.0], //BIG中レトロサウンド
      'big_blue': [999, 999, 999, 999, 999, 999], //BIG後青
      'big_yellow': [999, 999, 999, 999, 999, 999], //BIG後黄
      'big_green': [999, 999, 999, 999, 999, 999], //BIG後緑
      'big_red': [999, 999, 999, 999, 999, 999], //BIG後赤
      'big_rainbow': [999, 999, 999, 999, 999, 999], //BIG後虹
      'big_white': [999, 999, 999, 999, 999, 999], //BIG後白
      'side_blue': [2.69, 4.29, 3.05, 4.72, 3.24, 4.10], //REGサイド青
      'side_yellow': [4.07, 2.91, 4.23, 3.06, 4.96, 4.02], //REGサイド黄
      'side_green': [4.37, 5.60, 3.77, 5.70, 3.49, 4.02], //REGサイド緑
      'side_red': [6.55, 4.10, 5.96, 3.54, 5.04, 4.02], //REGサイド赤
      'side_rainbow': [2048, 1024, 512, 256, 199.8, 99.9], //REGサイド虹
      'reg_blue': [0, 102.40, 85.33, 42.67, 42.67, 42.67], //REG後青
      'reg_yellow': [0, 0, 102.40, 73.14, 42.67, 42.67], //REG後黄
      'reg_green': [0, 0, 0, 102.40, 73.14, 42.67], //REG後緑
      'reg_red': [0, 0, 0, 0, 102.40, 73.14], //REG後赤
      'reg_rainbow': [0, 0, 0, 0, 0, 102.40], //REG後虹
      'reg_white': [1.00, 1.01, 1.02, 1.05, 1.08, 1.10], //REG後白
      'big_sum': [292, 280, 268, 257, 244, 232],
      'reg_sum': [489, 452, 420, 390, 360, 332],
    },
    SlotMachine.hanahanaHouou: {
      'payout': [97, 99, 101, 103, 106, 109],
      'single_big': [297, 284, 273, 262, 249, 236],
      'single_reg': [496, 458, 425, 397, 366, 337],
      'bell': [7.533, 7.498, 7.464, 7.447, 7.347, 7.306],
      'big_game_num': [24], //BIGゲーム回数
      'big_suika': [47.15, 44.28, 40.45, 39.72, 35.05, 32.13], //BIG中スイカ回数
      'big_retro_sound': [48.0, 48.0, 48.0, 48.0, 48.0, 48.0], //BIG中レトロサウンド
      'big_blue': [24.09, 22.60, 24.09, 18.20, 17.86, 16.98], //BIG後青
      'big_yellow': [27.89, 26.75, 24.27, 21.14, 23.41, 19.28], //BIG後黄
      'big_green': [52.01, 38.55, 36.41, 34.49, 31.21, 30.62], //BIG後緑
      'big_red': [51.20, 59.58, 44.89, 54.16, 46.15, 46.15], //BIG後赤
      'big_rainbow': [4096, 4096, 2048, 1024, 682.67, 256], //BIG後虹
      'big_white': [1.13, 1.14, 1.15, 1.18, 1.18, 1.20], //BIG後白
      'side_blue': [2.69, 4.29, 3.05, 4.72, 3.24, 4.10], //REGサイド青
      'side_yellow': [4.07, 2.91, 4.23, 3.06, 4.96, 4.02], //REGサイド黄
      'side_green': [4.37, 5.60, 3.77, 5.70, 3.49, 4.02], //REGサイド緑
      'side_red': [6.55, 4.10, 5.96, 3.54, 5.04, 4.02], //REGサイド赤
      'side_rainbow': [2048, 1024, 512, 256, 199.8, 99.9], //REGサイド虹
      'reg_blue': [0, 102.40, 85.33, 42.67, 42.67, 42.67], //REG後青
      'reg_yellow': [0, 0, 102.40, 73.14, 42.67, 42.67], //REG後黄
      'reg_green': [0, 0, 0, 102.40, 73.14, 42.67], //REG後緑
      'reg_red': [0, 0, 0, 0, 102.40, 73.14], //REG後赤
      'reg_rainbow': [0, 0, 0, 0, 0, 102.40], //REG後虹
      'reg_white': [1.00, 1.01, 1.02, 1.05, 1.08, 1.10], //REG後白
      'big_sum': [297, 284, 273, 262, 249, 236],
      'reg_sum': [496, 458, 425, 397, 366, 337],
    },
    SlotMachine.dragonHanahana: {
      'payout': [97, 99, 101.17, 104, 107, 110.36],
      'single_big': [256, 246.38, 234.90, 223.67, 212.09, 199.2],
      'single_reg': [642.51, 585.14, 537.18, 489.07, 442.81, 399.61],
      'bell': [7.219, 7.195, 7.152, 7.097, 7.052, 7.033],
      'big_game_num': [20], //BIGゲーム回数
      'big_suika': [48.09, 39.01, 36.21, 32.25, 30.01, 28.01], //BIG中スイカ回数
      'big_retro_sound': [48.0, 48.0, 48.0, 48.0, 48.0, 48.0], //BIG中レトロサウンド
      'big_blue': [24.09, 22.60, 24.09, 18.20, 17.86, 16.98], //BIG後青
      'big_yellow': [27.89, 26.75, 24.27, 21.14, 23.41, 19.28], //BIG後黄
      'big_green': [52.01, 38.55, 36.41, 34.49, 31.21, 30.62], //BIG後緑
      'big_red': [51.20, 59.58, 44.89, 54.16, 46.15, 46.15], //BIG後赤
      'big_rainbow': [4096, 4096, 2048, 1024, 682.67, 256], //BIG後虹
      'big_white': [1.13, 1.14, 1.15, 1.18, 1.18, 1.20], //BIG後白
      'side_blue': [2.69, 4.29, 3.05, 4.72, 3.24, 4.10], //REGサイド青
      'side_yellow': [4.07, 2.91, 4.23, 3.06, 4.96, 4.02], //REGサイド黄
      'side_green': [4.37, 5.60, 3.77, 5.70, 3.49, 4.02], //REGサイド緑
      'side_red': [6.55, 4.10, 5.96, 3.54, 5.04, 4.02], //REGサイド赤
      'side_rainbow': [2048, 1024, 512, 256, 199.8, 99.9], //REGサイド虹
      'reg_blue': [0, 102.40, 85.33, 42.67, 42.67, 42.67], //REG後青
      'reg_yellow': [0, 0, 102.40, 73.14, 42.67, 42.67], //REG後黄
      'reg_green': [0, 0, 0, 102.40, 73.14, 42.67], //REG後緑
      'reg_red': [0, 0, 0, 0, 102.40, 73.14], //REG後赤
      'reg_rainbow': [0, 0, 0, 0, 0, 102.40], //REG後虹
      'reg_white': [1.00, 1.01, 1.02, 1.05, 1.08, 1.10], //REG後白
      'big_sum': [256, 246.38, 234.90, 223.67, 212.09, 199.2],
      'reg_sum': [642.51, 585.14, 537.18, 489.07, 442.81, 399.61],
    },
    SlotMachine.starHanahana: {
      'payout': [97, 99, 101, 104, 107, 110],
      'single_big': [270, 262, 252, 240, 229, 218],
      'single_reg': [387, 354, 322, 293, 267, 242],
      'bell': [6.222, 6.17, 6.17, 6.129, 6.075, 6.075],
      'big_game_num': [20], //BIGゲーム回数
      'big_suika': [48.09, 39.01, 36.21, 32.25, 30.01, 28.01], //BIG中スイカ回数
      'big_retro_sound': [48.0, 48.0, 48.0, 48.0, 48.0, 48.0], //BIG中レトロサウンド
      'big_blue': [24.09, 22.60, 24.09, 18.20, 17.86, 16.98], //BIG後青
      'big_yellow': [27.89, 26.75, 24.27, 21.14, 23.41, 19.28], //BIG後黄
      'big_green': [52.01, 38.55, 36.41, 34.49, 31.21, 30.62], //BIG後緑
      'big_red': [51.20, 59.58, 44.89, 54.16, 46.15, 46.15], //BIG後赤
      'big_rainbow': [4096, 4096, 2048, 1024, 682.67, 256], //BIG後虹
      'big_white': [1.13, 1.14, 1.15, 1.18, 1.18, 1.20], //BIG後白
      'side_blue': [2.69, 4.29, 3.05, 4.72, 3.24, 4.10], //REGサイド青
      'side_yellow': [4.07, 2.91, 4.23, 3.06, 4.96, 4.02], //REGサイド黄
      'side_green': [4.37, 5.60, 3.77, 5.70, 3.49, 4.02], //REGサイド緑
      'side_red': [6.55, 4.10, 5.96, 3.54, 5.04, 4.02], //REGサイド赤
      'side_rainbow': [2048, 1024, 512, 256, 199.8, 99.9], //REGサイド虹
      'reg_blue': [0, 102.40, 85.33, 42.67, 42.67, 42.67], //REG後青
      'reg_yellow': [0, 0, 102.40, 73.14, 42.67, 42.67], //REG後黄
      'reg_green': [0, 0, 0, 102.40, 73.14, 42.67], //REG後緑
      'reg_red': [0, 0, 0, 0, 102.40, 73.14], //REG後赤
      'reg_rainbow': [0, 0, 0, 0, 0, 102.40], //REG後虹
      'reg_white': [1.00, 1.01, 1.02, 1.05, 1.08, 1.10], //REG後白
      'big_sum': [270, 262, 252, 240, 229, 218],
      'reg_sum': [387, 354, 322, 293, 267, 242],
    },
    SlotMachine.newKingHanahanaV: {
      'payout':[97.0, 99.0, 101.0, 104.0, 108.0, 108.0],
      'single_big':[299.0, 291.0, 281.0, 268.0, 253.0, 253.0],
      'single_reg':[496.0, 471.0, 442.0, 409.0, 372.0, 372.0],
      'bell':[7.628, 7.502, 7.474, 7.379, 7.266, 7.266],
      'big_game_num': [14.0], // BIGゲーム回数
      'big_suika':[47.127, 42.864, 39.667, 36.991, 34.707, 34.707], // BIG中スイカ回数
      'big_retro_sound':[48.0, 48.0, 48.0, 48.0, 48.0, 48.0], // BIG中レトロサウンド
      'big_blue':[27.22, 24.63, 23.26, 20.48, 18.67, 18.67], // BIG後青
      'big_yellow':[34.86, 33.22, 28.35, 26.01, 24.36, 24.36], // BIG後黄
      'big_green':[52.01, 48.33, 42.92, 39.67, 37.45, 37.45], // BIG後緑
      'big_red':[78.02, 72.98, 66.67, 63.69, 57.49, 57.49], // BIG後赤 (設定6の値を補完)
      'big_rainbow':[8192.0, 2520.0, 2638.0, 1424.0, 504.0, 504.0], // BIG後虹
      'big_white':[1.0, 1.0, 1.0, 1.0, 1.0, 1.0], // BIG後白
      'side_blue':[2.778, 4.312, 2.979, 4.639, 3.218, 3.218], // REGサイド青
      'side_yellow':[4.168, 2.875, 4.468, 3.092, 4.827, 4.827], // REGサイド黄
      'side_green':[4.168, 5.956, 3.792, 5.445, 3.485, 3.485], // REGサイド緑
      'side_red':[6.249, 3.970, 5.688, 3.630, 5.229, 5.229], // REGサイド赤
      'side_rainbow':[4681.0, 2048.0, 992.0, 508.0, 256.0, 256.0], // REGサイド虹
      'reg_blue':[0.0, 102.40, 85.33, 42.67, 42.67, 42.67], // REG後青
      'reg_yellow':[0.0, 0.0, 102.40, 73.14, 42.67, 42.67], // REG後黄
      'reg_green':[0.0, 0.0, 0.0, 102.40, 73.14, 42.67], // REG後緑
      'reg_red':[0.0, 0.0, 0.0, 0.0, 102.40, 73.14], // REG後赤
      'reg_rainbow':[0.0, 0.0, 0.0, 0.0, 0.0, 102.40], // REG後虹
      'reg_white':[1.00, 1.01, 1.02, 1.05, 1.08, 1.10], // REG後白
      'big_sum':[299.0, 291.0, 281.0, 268.0, 253.0, 253.0],
      'reg_sum':[496.0, 471.0, 442.0, 409.0, 372.0, 372.0],
    },
  };

  static CalculationResult calculate({
    required String currentGame,
    required String countSingleBig,
    required String countSingleReg,
    String bigGames = '0',
    String extraBigGames = '0',
    String bigSuika = '0',
    required String countBell,
    required String startGame,
    required String regSum,
    required String bigSum,
    required String bigRetroSound,
    String countBigBlue = '0',
    String countBigYellow = '0',
    String countBigGreen = '0',
    String countBigRed = '0',
    String countBigRainbow = '0',
    String countBigWhite = '0',
    String countSideBlue = '0',
    String countSideYellow = '0',
    String countSideGreen = '0',
    String countSideRed = '0',
    String countSideRainbow = '0',
    String countRegBlue = '0',
    String countRegYellow = '0',
    String countRegGreen = '0',
    String countRegRed = '0',
    String countRegRainbow = '0',
    String countRegWhite = '0',
    required List<String> haibun,
    required SlotMachine machine,
  }) {
    // 入力値の変換とバリデーション
    int countSingleBigValue = int.tryParse(countSingleBig) ?? 0;
    int countSingleRegValue = int.tryParse(countSingleReg) ?? 0;
    int bigGamesValue = int.tryParse(bigGames) ?? 0;
    int extraGames = int.tryParse(extraBigGames) ?? 0;
    int bigSuikaValue = int.tryParse(bigSuika) ?? 0;
    int countBellValue = int.tryParse(countBell) ?? 0;
    int startGameValue = int.tryParse(startGame) ?? 0;
    int regSumValue = int.tryParse(regSum) ?? 0;
    int bigSumValue = int.tryParse(bigSum) ?? 0;
    int bigRetroSoundValue = int.tryParse(bigRetroSound) ?? 0;

    final bigParams = {
      'blue': int.tryParse(countBigBlue) ?? 0,
      'yellow': int.tryParse(countBigYellow) ?? 0,
      'green': int.tryParse(countBigGreen) ?? 0,
      'red': int.tryParse(countBigRed) ?? 0,
      'rainbow': int.tryParse(countBigRainbow) ?? 0,
      'white': int.tryParse(countBigWhite) ?? 0,
    };

    final sideParams = {
      'blue': int.tryParse(countSideBlue) ?? 0,
      'yellow': int.tryParse(countSideYellow) ?? 0,
      'green': int.tryParse(countSideGreen) ?? 0,
      'red': int.tryParse(countSideRed) ?? 0,
      'rainbow': int.tryParse(countSideRainbow) ?? 0,
    };

    final regParams = {
      'blue': int.tryParse(countRegBlue) ?? 0,
      'yellow': int.tryParse(countRegYellow) ?? 0,
      'green': int.tryParse(countRegGreen) ?? 0,
      'red': int.tryParse(countRegRed) ?? 0,
      'rainbow': int.tryParse(countRegRainbow) ?? 0,
      'white': int.tryParse(countRegWhite) ?? 0,
    };

    int currentGameValue = (int.tryParse(currentGame) ?? 0) - startGameValue;

    // 入力値の検証
    bool hasValidData = false;
    if (currentGameValue > 0) {
      if (countSingleBigValue > 0 || countSingleRegValue > 0 || countBellValue > 0) {
        hasValidData = true;
      }
    }
    if (startGameValue > 0) {
      if (regSumValue > 0 || bigSumValue > 0) {
        hasValidData = true;
      }
    }

    if (!hasValidData) {
      // デフォルト値を返す
      return CalculationResult(
        probabilities: List.filled(6, 16.67),
        averageSettings: 3.5,
        averagePayout: machineParameters[machine]!['payout']!
            .reduce((a, b) => a + b) / 6,
        averageWage: 0,
        probStrings: List.filled(7, "－"),
      );
    }

    List<int> haibunValues = haibun
        .map((e) => int.tryParse(e) ?? 1)
        .toList();

    // 機種のパラメータを取得
    final params = machineParameters[machine]!;

    // 確率計算用の配列
    List<List<double>> probs = List.generate(24, (_) => List.filled(6, 1.0));

    // 単独BIG確率計算
    if (currentGameValue > 0 && countSingleBigValue > 0) {
      _calculateProbability(
          currentGameValue,
          countSingleBigValue,
          params['single_big']!,
          probs[0]
      );
    }

    // 単独REG確率計算
    if (currentGameValue > 0 && countSingleRegValue > 0) {
      _calculateProbability(
          currentGameValue - countSingleBigValue,
          countSingleRegValue,
          params['single_reg']!,
          probs[1]
      );
    }

    // ベル確率計算
    if (currentGameValue > 0 && countBellValue > 0) {
      _calculateProbability(
          currentGameValue - countSingleBigValue - countSingleRegValue,
          countBellValue,
          params['bell']!,
          probs[2]
      );
    }

    // データカウンターREG確率計算
    if (startGameValue > 0 && regSumValue > 0) {
      _calculateProbability(
          startGameValue,
          regSumValue,
          params['reg_sum']!,
          probs[3]
      );
    }

    // データカウンターBIG確率計算
    if (startGameValue > 0 && bigSumValue > 0) {
      _calculateProbability(
          startGameValue - regSumValue,
          bigSumValue,
          params['big_sum']!,
          probs[4]
      );
    }

    // レトロ確率計算
    if (currentGameValue > 0 && bigRetroSoundValue > 0) {
      _calculateProbability(
          countSingleBigValue,
          bigRetroSoundValue,
          params['big_retro_sound']!,
          probs[5]
      );
    }

    // BIG後の色別処理
    int usedBigColorCount = 0;
    bigParams.forEach((color, count) {
      if (count > 0) {
        _calculateProbability(
            countSingleBigValue -usedBigColorCount,
            count,
            params['big_$color']!,
            probs[6 + bigParams.keys.toList().indexOf(color)]
        );
      }

      usedBigColorCount += count;
    });

    // REGサイドの色別処理
    int usedSideColorCount = 0;
    sideParams.forEach((color, count) {
      if (count > 0) {
        _calculateProbability(
            countSingleRegValue -usedSideColorCount,
            count,
            params['side_$color']!,
            probs[12 + sideParams.keys.toList().indexOf(color)]
        );
      }

      usedSideColorCount += count;
    });

    // REG後の色別処理
    //int usedRegColorCount = 0;
    regParams.forEach((color, count) {
      if (count > 0) {
        _calculateProbability(
            countSingleRegValue,
            count,
            params['reg_$color']!,
            probs[17 + regParams.keys.toList().indexOf(color)]
        );
      }

      //usedRegColorCount += count;
    });

    // BIG中スイカ
    if (bigGamesValue > 0 && bigSuikaValue > 0) {
      _calculateProbability(
          bigGamesValue + extraGames,  // 余剰ゲーム数を加算
          bigSuikaValue,
          params['big_suika']!,
          probs[23]
      );
    }

    // 設定配分の計算
    double haibunSum = haibunValues.reduce((a, b) => a + b).toDouble();
    List<double> haibunRatios = haibunValues.map((v) => v / haibunSum).toList();

    // 総合確率の計算
    List<double> finalProbs = List.filled(6, 0.0);
    for (int i = 0; i < 6; i++) {
      double settingProb = haibunRatios[i];
      for (int j = 0; j < probs.length; j++) {
        settingProb *= probs[j][i];
      }
      finalProbs[i] = settingProb;
    }

    // 確率の正規化
    double totalProb = finalProbs.reduce((a, b) => a + b);
    List<double> probabilities = finalProbs
        .map((p) => double.parse((p / totalProb * 100).toStringAsFixed(2)))
        .toList();

    // 出現確率の文字列計算
    List<String> probStrings = [
      _calculateProbString(currentGameValue, countSingleBigValue),
      _calculateProbString(currentGameValue, countSingleRegValue),
      _calculateProbString(currentGameValue, countBellValue),
      _calculateProbString(startGameValue, regSumValue),
      _calculateProbString(startGameValue, bigSumValue),
      _calculateProbString(currentGameValue, bigRetroSoundValue),
    ];

    // 平均値の計算
    double averageSettings = _calculateAverageSettings(probabilities);
    double averagePayout = _calculateAveragePayout(probabilities, params['payout']!);
    double averageWage = _calculateAverageWage(probabilities, params['payout']!);

    return CalculationResult(
      probabilities: probabilities,
      averageSettings: averageSettings,
      averagePayout: averagePayout,
      averageWage: averageWage,
      probStrings: probStrings,
    );
  }

  static void _calculateProbability(
      int total,
      int count,
      List<double> settings,
      List<double> results
      ) {
    try {
      if (total <= 0 || count <= 0) return;

      // 対数を使用して確率を計算
      for (int i = 0; i < 6; i++) {
        double p;
        if(settings[i] == 0){
          p = 1.0 / 999999.0;  // 非常に小さい確率を設定
        }else{
          p = 1.0 / settings[i];
        }
        double q = 1.0 - p;

        // 二項分布の確率を対数で計算
        double logProb = 0.0;

        // log(nCr)の計算
        for (int j = 0; j < count; j++) {
          logProb += log(total - j) - log(j + 1);
        }

        // p^r * q^(n-r)の対数計算
        logProb += count * log(p) + (total - count) * log(q);

        // 対数から通常の値に変換
        results[i] = exp(logProb);

        // 数値が非常に小さい場合は最小値を設定
        if (results[i].isInfinite || results[i].isNaN || results[i] < 1e-308) {
          results[i] = 1e-308;
        }
      }

      // 結果の正規化
      double sum = results.reduce((a, b) => a + b);
      if (sum > 0 && sum.isFinite) {
        for (int i = 0; i < 6; i++) {
          results[i] /= sum;
        }
      } else {
        // 計算が破綻した場合は均等な確率を設定
        for (int i = 0; i < 6; i++) {
          results[i] = 1.0 / 6.0;
        }
      }
    } catch (e) {
      // エラー発生時にToastを表示
      Fluttertoast.showToast(
          msg: "計算中にエラーが発生しました: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );

      // エラー時は均等な確率を設定
      for (int i = 0; i < 6; i++) {
        results[i] = 1.0 / 6.0;
      }
    }
  }

  static String _calculateProbString(int total, int count) {
    if (total == 0 || count == 0) {
      return "－";
    }
    return "1/${(total/count).round()}";
  }

  static double _calculateAverageSettings(List<double> probabilities) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += (i + 1) * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  static double _calculateAveragePayout(List<double> probabilities, List<double> payouts) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += payouts[i] * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  static double _calculateAverageWage(List<double> probabilities, List<double> payouts) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += 2400 * (payouts[i] - 100) / 100 * 20 * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(0));
  }
}