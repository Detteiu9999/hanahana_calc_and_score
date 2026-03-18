// lib/screens/slot_analyzer_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slot_calc/screens/records_screen.dart';
import '../../models/calculation_result.dart';
import '../../services/slot_calculator.dart';
import '../models/practice_record.dart';
import '../services/record_service.dart';
import 'machine_parameters_screen.dart';

class SlotAnalyzerScreen extends StatefulWidget {
  @override
  _SlotAnalyzerScreenState createState() => _SlotAnalyzerScreenState();
}

class _SlotAnalyzerScreenState extends State<SlotAnalyzerScreen> with WidgetsBindingObserver{
  // 機種選択の状態を保存するキー
  static const String _selectedMachineKey = 'selectedMachine';

  SlotMachine selectedMachine = SlotMachine.kingHanahana;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController(); // ScrollController追加
  bool _showHaibun = false;

  // TextEditingController群
  final currentGameController = TextEditingController();
  final countSingleBigController = TextEditingController();
  final countSingleRegController = TextEditingController();
  final countBellController = TextEditingController();
  final bigRetroSoundController = TextEditingController();
  final startGameController = TextEditingController();
  final regSumController = TextEditingController();
  final bigSumController = TextEditingController();

  // BIG後の色別コントローラー
  final countBigBlueController = TextEditingController();
  final countBigYellowController = TextEditingController();
  final countBigGreenController = TextEditingController();
  final countBigRedController = TextEditingController();
  final countBigRainbowController = TextEditingController();
  final countBigWhiteController = TextEditingController();

  // REGサイドの色別コントローラー
  final countSideBlueController = TextEditingController();
  final countSideYellowController = TextEditingController();
  final countSideGreenController = TextEditingController();
  final countSideRedController = TextEditingController();
  final countSideRainbowController = TextEditingController();

  // REG後の色別コントローラー
  final countRegBlueController = TextEditingController();
  final countRegYellowController = TextEditingController();
  final countRegGreenController = TextEditingController();
  final countRegRedController = TextEditingController();
  final countRegRainbowController = TextEditingController();
  final countRegWhiteController = TextEditingController();

  //BIG中スイカのコントローラー
  final bigGamesController = TextEditingController();
  final extraBigGamesController = TextEditingController();
  final bigSuikaController = TextEditingController();

  bool _showColorInputs = false; // 色別入力の表示制御用

  final List<TextEditingController> haibunControllers =
  List.generate(6, (index) => TextEditingController());

  // 計算結果
  CalculationResult? result;

  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedData();

    // リスナーの追加を最適化
    void addFractionListener(TextEditingController controller) {
      controller.addListener(() {
        if (mounted && _shouldUpdateFraction(controller.text)) {
          setState(() {});
        }
      });
    }

    // 必要なコントローラーのみにリスナーを追加
    final controllersNeedingFraction = [
      currentGameController,
      startGameController,
      countBellController,
      bigRetroSoundController,
      regSumController,
      bigSumController,
    ];

    for (var controller in controllersNeedingFraction) {
      addFractionListener(controller);
    }

    countSingleBigController.addListener(_updateBigGamesTotal);
  }

  // 分数の更新が必要かどうかを判定
  bool _shouldUpdateFraction(String value) {
    return value.isNotEmpty && int.tryParse(value) != null;
  }

  // BIG中ゲーム数の合計を自動計算するメソッド
  void _updateBigGamesTotal() {
    if (mounted && countSingleBigController.text.isNotEmpty) {
      int? count = int.tryParse(countSingleBigController.text);
      if (count != null) {
        int bigGameNum = SlotCalculator.machineParameters[selectedMachine]!['big_game_num']![0].toInt();
        setState(() {
          bigGamesController.text = (count * bigGameNum).toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _saveData();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    bigGamesController.removeListener(_updateBigGamesTotal);

    // コントローラーの破棄
    currentGameController.dispose();
    countSingleBigController.dispose();
    countSingleRegController.dispose();
    countBellController.dispose();
    bigRetroSoundController.dispose();
    startGameController.dispose();
    regSumController.dispose();
    bigSumController.dispose();

    // 新しいコントローラーの破棄
    countBigBlueController.dispose();
    countBigYellowController.dispose();
    countBigGreenController.dispose();
    countBigRedController.dispose();
    countBigRainbowController.dispose();
    countBigWhiteController.dispose();

    countSideBlueController.dispose();
    countSideYellowController.dispose();
    countSideGreenController.dispose();
    countSideRedController.dispose();
    countSideRainbowController.dispose();

    countRegBlueController.dispose();
    countRegYellowController.dispose();
    countRegGreenController.dispose();
    countRegRedController.dispose();
    countRegRainbowController.dispose();
    countRegWhiteController.dispose();

    bigGamesController.dispose();
    extraBigGamesController.dispose();
    bigSuikaController.dispose();

    for (var controller in haibunControllers) {
      controller.dispose();
    }
    // フォーカスノードの破棄を追加
    _focusNodes.values.forEach((node) => node.dispose());
    _focusNodes.clear();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveData();
    }
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      // すべてのフォーカスを解放
      _focusNodes.values.forEach((node) => node.unfocus());
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      });
    }
  }


  // データの保存
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // 機種選択の保存
    await prefs.setInt(_selectedMachineKey, selectedMachine.index);

    await prefs.setString('currentGame', currentGameController.text);
    await prefs.setString('countSingleBig', countSingleBigController.text);
    await prefs.setString('countSingleReg', countSingleRegController.text);
    await prefs.setString('countBell', countBellController.text);
    await prefs.setString('bigRetroSound', bigRetroSoundController.text);
    await prefs.setString('startGame', startGameController.text);
    await prefs.setString('regSum', regSumController.text);
    await prefs.setString('bigSum', bigSumController.text);

    // BIG後の色別データ
    await prefs.setString('countBigBlue', countBigBlueController.text);
    await prefs.setString('countBigYellow', countBigYellowController.text);
    await prefs.setString('countBigGreen', countBigGreenController.text);
    await prefs.setString('countBigRed', countBigRedController.text);
    await prefs.setString('countBigRainbow', countBigRainbowController.text);
    await prefs.setString('countBigWhite', countBigWhiteController.text);

    // REGサイドの色別データ
    await prefs.setString('countSideBlue', countSideBlueController.text);
    await prefs.setString('countSideYellow', countSideYellowController.text);
    await prefs.setString('countSideGreen', countSideGreenController.text);
    await prefs.setString('countSideRed', countSideRedController.text);
    await prefs.setString('countSideRainbow', countSideRainbowController.text);

    // REG後の色別データ
    await prefs.setString('countRegBlue', countRegBlueController.text);
    await prefs.setString('countRegYellow', countRegYellowController.text);
    await prefs.setString('countRegGreen', countRegGreenController.text);
    await prefs.setString('countRegRed', countRegRedController.text);
    await prefs.setString('countRegRainbow', countRegRainbowController.text);
    await prefs.setString('countRegWhite', countRegWhiteController.text);

    //BIG中スイカ
    await prefs.setString('bigGames', bigGamesController.text);
    await prefs.setString('extraBigGames', extraBigGamesController.text);
    await prefs.setString('bigSuika', bigSuikaController.text);

    for (int i = 0; i < haibunControllers.length; i++) {
      await prefs.setString('haibun$i', haibunControllers[i].text);
    }
  }

  // 保存したデータの読み込み
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 機種選択の読み込み
      final savedMachineIndex = prefs.getInt(_selectedMachineKey);
      if (savedMachineIndex != null) {
        selectedMachine = SlotMachine.values[savedMachineIndex];
      }

      currentGameController.text = prefs.getString('currentGame') ?? '';
      countSingleBigController.text = prefs.getString('countSingleBig') ?? '';
      countSingleRegController.text = prefs.getString('countSingleReg') ?? '';
      countBellController.text = prefs.getString('countBell') ?? '';
      bigRetroSoundController.text = prefs.getString('bigRetroSound') ?? '';
      startGameController.text = prefs.getString('startGame') ?? '';
      regSumController.text = prefs.getString('regSum') ?? '';
      bigSumController.text = prefs.getString('bigSum') ?? '';

      // BIG後の色別データ
      countBigBlueController.text = prefs.getString('countBigBlue') ?? '';
      countBigYellowController.text = prefs.getString('countBigYellow') ?? '';
      countBigGreenController.text = prefs.getString('countBigGreen') ?? '';
      countBigRedController.text = prefs.getString('countBigRed') ?? '';
      countBigRainbowController.text = prefs.getString('countBigRainbow') ?? '';
      countBigWhiteController.text = prefs.getString('countBigWhite') ?? '';

      // REGサイドの色別データ
      countSideBlueController.text = prefs.getString('countSideBlue') ?? '';
      countSideYellowController.text = prefs.getString('countSideYellow') ?? '';
      countSideGreenController.text = prefs.getString('countSideGreen') ?? '';
      countSideRedController.text = prefs.getString('countSideRed') ?? '';
      countSideRainbowController.text = prefs.getString('countSideRainbow') ?? '';

      // REG後の色別データ
      countRegBlueController.text = prefs.getString('countRegBlue') ?? '';
      countRegYellowController.text = prefs.getString('countRegYellow') ?? '';
      countRegGreenController.text = prefs.getString('countRegGreen') ?? '';
      countRegRedController.text = prefs.getString('countRegRed') ?? '';
      countRegRainbowController.text = prefs.getString('countRegRainbow') ?? '';
      countRegWhiteController.text = prefs.getString('countRegWhite') ?? '';

      //BIG中スイカ
      bigGamesController.text = prefs.getString('bigGames') ?? '';
      extraBigGamesController.text = prefs.getString('extraBigGames') ?? '';
      bigSuikaController.text = prefs.getString('bigSuika') ?? '';

      for (int i = 0; i < haibunControllers.length; i++) {
        haibunControllers[i].text = prefs.getString('haibun$i') ?? '';
      }
    });
  }

  // ボーナス・小役確率フォームのクリア
  void _clearBonusForm() {
    setState(() {
      currentGameController.clear();
      countSingleBigController.clear();
      countSingleRegController.clear();
      bigGamesController.clear();
      extraBigGamesController.clear();
      bigSuikaController.clear();
      countBellController.clear();
      bigRetroSoundController.clear();
    });
    _saveData();
  }

  // データカウンターフォームのクリア
  void _clearCounterForm() {
    setState(() {
      startGameController.clear();
      regSumController.clear();
      bigSumController.clear();
    });
    _saveData();
  }

  void _clearColorInputs() {
    setState(() {
      // BIG後の色別カウントをクリア
      countBigBlueController.clear();
      countBigYellowController.clear();
      countBigGreenController.clear();
      countBigRedController.clear();
      countBigRainbowController.clear();
      countBigWhiteController.clear();

      // REGサイドの色別カウントをクリア
      countSideBlueController.clear();
      countSideYellowController.clear();
      countSideGreenController.clear();
      countSideRedController.clear();
      countSideRainbowController.clear();

      // REG後の色別カウントをクリア
      countRegBlueController.clear();
      countRegYellowController.clear();
      countRegGreenController.clear();
      countRegRedController.clear();
      countRegRainbowController.clear();
      countRegWhiteController.clear();
    });
    _saveData(); // 保存済みデータも更新
  }

  // TextFormFieldを作成するメソッドを修正
  Widget _buildInputField(
      String label,
      TextEditingController controller, {
        String? suffix,
        Color? backgroundColor
      }) {
    // キーを一度だけ生成
    final key = ValueKey(label);

    // フォーカスノードが存在しない場合は作成
    if (!_focusNodes.containsKey(label)) {
      _focusNodes[label] = FocusNode();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        key: key,  // DateTime.now() を使用しない
        decoration: InputDecoration(
          labelText: label,
          suffix: suffix != null ? Text(suffix) : null,
          border: OutlineInputBorder(),
          filled: backgroundColor != null,
          fillColor: backgroundColor,
        ),
        keyboardType: TextInputType.number,
        focusNode: _focusNodes[label],
        // 入力値の変更を最適化
        onChanged: (value) {
          // 必要な場合のみ setState を呼び出す
          if (_shouldUpdateFraction(value)) {
            setState(() {});
          }
        },
        validator: (value) {
          if (value?.isEmpty ?? true) return null;
          return int.tryParse(value!) == null ? '数値を入力してください' : null;
        },
      ),
    );
  }


  // 分数を計算して文字列で返す関数
  String _calculateFraction(String count, String total) {
    if (count.isEmpty || total.isEmpty) return '';
    int? countNum = int.tryParse(count);
    int? totalNum = int.tryParse(total);
    if (countNum == null || totalNum == null || totalNum == 0 || countNum == 0) return '';

    double ratio = totalNum / countNum;
    return '1/${ratio.toStringAsFixed(2)}';
  }

  void _saveRecord() async {
    final gameCount = (int.tryParse(currentGameController.text) ?? 0) -
        (int.tryParse(startGameController.text) ?? 0);

    if (gameCount <= 0) {
      Fluttertoast.showToast(msg: "有効なゲーム数を入力してください");
      return;
    }

    final countSingleBig = int.tryParse(countSingleBigController.text) ?? 0;
    final countSingleReg = int.tryParse(countSingleRegController.text) ?? 0;
    final countBell = int.tryParse(countBellController.text) ?? 0;

    final totalBIG = countSingleBig;
    final totalREG = countSingleReg;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('記録の保存確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('以下の内容で保存しますか？'),
            SizedBox(height: 8),
            Text('実践G数: ${gameCount}G'),
            Text('BIG: ${totalBIG}回'),
            Text('REG: ${totalREG}回'),
            Text('ベル: ${countBell}回'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('保存'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final record = PracticeRecord(
      date: DateTime.now(),
      machine: selectedMachine,
      gameCount: gameCount,
      bigProbability: totalBIG > 0 ? gameCount / totalBIG : double.infinity,
      regProbability: totalREG > 0 ? gameCount / totalREG : double.infinity,
      bellProbability: countBell > 0 ? gameCount / countBell : double.infinity,
      bellCount: countBell,
    );

    await RecordService.saveRecord(record);
    Fluttertoast.showToast(msg: "記録を保存しました");
  }

  // 入力フィールドと分数表示を含むウィジェット
  Widget _buildInputFieldWithFraction(
      String label,
      TextEditingController controller, {
        String? suffix,
        String? totalValue,
        bool showFraction = false,
        bool enabled = true
      }) {
    final key = ValueKey(label);

    if (!_focusNodes.containsKey(label)) {
      _focusNodes[label] = FocusNode();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: key,
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            suffix: suffix != null ? Text(suffix) : null,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          focusNode: _focusNodes[label],
          onChanged: (value) {
            if (_shouldUpdateFraction(value)) {
              setState(() {});
            }
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return null;
            return int.tryParse(value!) == null ? '数値を入力してください' : null;
          },
        ),
        if (showFraction && totalValue != null)
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              _calculateFraction(controller.text, totalValue),
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 画面タップ時にフォーカスを解除
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      body: SafeArea( // ← ここに SafeArea を追加します
      child: Column(
          children: [
            // 機種選択カード - 固定表示部分
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SlotMachine>(
                        isExpanded: true,
                        value: selectedMachine,
                        onChanged: (SlotMachine? newValue) {
                          setState(() {
                            selectedMachine = newValue!;
                            _saveData();
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: SlotMachine.kingHanahana,
                            child: Text('キングハナハナ'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.hanahanaHouou,
                            child: Text('ハナハナホウオウ天翔'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.dragonHanahana,
                            child: Text('ドラゴンハナハナ～閃光～'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.starHanahana,
                            child: Text('スターハナハナ'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.newKingHanahanaV,
                            child: Text('ニューキングハナハナV'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        // 現在の確率を計算
                        Map<String, double> currentValues = {};

                        // BIG確率
                        if (currentGameController.text.isNotEmpty && countSingleBigController.text.isNotEmpty) {
                          int games = int.tryParse(currentGameController.text) ?? 0;
                          int count = (int.tryParse(countSingleBigController.text) ?? 0) + (int.tryParse(bigSumController.text) ?? 0);
                          if (games > 0 && count > 0) {
                            currentValues['single_big'] = games / count;
                          }
                        }

                        // REG確率
                        if (currentGameController.text.isNotEmpty && countSingleRegController.text.isNotEmpty) {
                          int games = int.tryParse(currentGameController.text) ?? 0;
                          int count = (int.tryParse(countSingleRegController.text) ?? 0) + (int.tryParse(regSumController.text) ?? 0);
                          if (games > 0 && count > 0) {
                            currentValues['single_reg'] = games / count;
                          }
                        }

                        // ベル確率
                        if (currentGameController.text.isNotEmpty && countBellController.text.isNotEmpty) {
                          int games = (int.tryParse(currentGameController.text) ?? 0) - (int.tryParse(startGameController.text) ?? 0);
                          int count = int.tryParse(countBellController.text) ?? 0;
                          if (games > 0 && count > 0) {
                            currentValues['bell'] = games / count;
                          }
                        }

                        // BIG中スイカ確率
                        if (bigGamesController.text.isNotEmpty && bigSuikaController.text.isNotEmpty) {
                          int games = int.tryParse(bigGamesController.text) ?? 0;
                          int extraGames = int.tryParse(extraBigGamesController.text) ?? 0;
                          int count = int.tryParse(bigSuikaController.text) ?? 0;
                          if ((games + extraGames) > 0 && count > 0) {
                            currentValues['big_suika'] = (games + extraGames) / count;
                          }
                        }

                        // レトロサウンド確率
                        if (countSingleBigController.text.isNotEmpty && bigRetroSoundController.text.isNotEmpty) {
                          int total = int.tryParse(countSingleBigController.text) ?? 0;
                          int count = int.tryParse(bigRetroSoundController.text) ?? 0;
                          if (total > 0 && count > 0) {
                            currentValues['big_retro_sound'] = total / count;
                          }
                        }

                        // BIG合算確率
                        if (startGameController.text.isNotEmpty && bigSumController.text.isNotEmpty) {
                          int games = int.tryParse(startGameController.text) ?? 0;
                          int count = int.tryParse(bigSumController.text) ?? 0;
                          if (games > 0 && count > 0) {
                            currentValues['big_sum'] = games / count;
                          }
                        }

                        // REG合算確率
                        if (startGameController.text.isNotEmpty && regSumController.text.isNotEmpty) {
                          int games = int.tryParse(startGameController.text) ?? 0;
                          int count = int.tryParse(regSumController.text) ?? 0;
                          if (games > 0 && count > 0) {
                            currentValues['reg_sum'] = games / count;
                          }
                        }

                        // 色別確率の計算（BIG後）
                        void addColorValue(String key, String count) {
                          if (countSingleBigController.text.isNotEmpty && count.isNotEmpty) {
                            int total = int.tryParse(countSingleBigController.text) ?? 0;
                            int colorCount = int.tryParse(count) ?? 0;
                            if (total > 0 && colorCount > 0) {
                              currentValues[key] = total / colorCount;
                            }
                          }
                        }

                        addColorValue('big_blue', countBigBlueController.text);
                        addColorValue('big_yellow', countBigYellowController.text);
                        addColorValue('big_green', countBigGreenController.text);
                        addColorValue('big_red', countBigRedController.text);
                        addColorValue('big_rainbow', countBigRainbowController.text);
                        addColorValue('big_white', countBigWhiteController.text);

                        // REGサイドの色別確率
                        void addSideValue(String key, String count) {
                          if (countSingleRegController.text.isNotEmpty && count.isNotEmpty) {
                            int total = int.tryParse(countSingleRegController.text) ?? 0;
                            int colorCount = int.tryParse(count) ?? 0;
                            if (total > 0 && colorCount > 0) {
                              currentValues[key] = total / colorCount;
                            }
                          }
                        }

                        addSideValue('side_blue', countSideBlueController.text);
                        addSideValue('side_yellow', countSideYellowController.text);
                        addSideValue('side_green', countSideGreenController.text);
                        addSideValue('side_red', countSideRedController.text);
                        addSideValue('side_rainbow', countSideRainbowController.text);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MachineParametersScreen(
                              machine: selectedMachine,
                              currentValues: currentValues,
                            ),
                          ),
                        );
                      },
                      tooltip: '機種パラメータ表示',
                    ),
                  ],
                ),
              ),
            ),
            // スクロール可能な残りのコンテンツ
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('着席時データカウンター',
                                      style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: _clearCounterForm,
                                    child: Text('クリア'),
                                  ),
                                ],
                              ),
                              _buildInputField('ゲーム数', startGameController, suffix: 'G中'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'BIG',
                                      bigSumController,
                                      suffix: '回',
                                      totalValue: startGameController.text,
                                      showFraction: true,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'REG',
                                      regSumController,
                                      suffix: '回',
                                      totalValue: startGameController.text,
                                      showFraction: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ボーナス・小役確率',
                                      style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: _clearBonusForm,
                                    child: Text('クリア'),
                                  ),
                                ],
                              ),
                              _buildInputField('現在の総ゲーム数', currentGameController, suffix: 'G中'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      '実践BIG',
                                      countSingleBigController,
                                      suffix: '回',
                                      totalValue: ((int.tryParse(currentGameController.text) ?? 0) - (int.tryParse(startGameController.text) ?? 0)).toString(),
                                      showFraction: true,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      '実践REG',
                                      countSingleRegController,
                                      suffix: '回',
                                      totalValue: ((int.tryParse(currentGameController.text) ?? 0) - (int.tryParse(startGameController.text) ?? 0)).toString(),
                                      showFraction: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField('BIGゲーム数', bigGamesController, suffix: 'G'),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInputField('余剰BIGゲーム数', extraBigGamesController, suffix: 'G'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField('BIG中スイカ回数', bigSuikaController, suffix: '回'),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'BIGレトロサウンド',
                                      bigRetroSoundController,
                                      suffix: '回',
                                      totalValue: (int.tryParse(countSingleBigController.text) ?? 0).toString(),
                                      showFraction: false,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'ベル',
                                      countBellController,
                                      suffix: '回',
                                      totalValue: ((int.tryParse(currentGameController.text) ?? 0) - (int.tryParse(startGameController.text) ?? 0)).toString(),
                                      showFraction: true,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text('色別カウント入力'),
                                onTap: () {
                                  setState(() {
                                    _showColorInputs = !_showColorInputs;
                                  });
                                },
                              );
                            },
                            body: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _clearColorInputs,
                                        child: Text('色別カウントをクリア'),
                                      ),
                                    ],
                                  ),
                                  Text('BIG後の色', style: Theme.of(context).textTheme.titleMedium),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('BIG後青', countBigBlueController, suffix: '回', backgroundColor: Colors.blue[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('BIG後黄', countBigYellowController, suffix: '回', backgroundColor: Colors.yellow[100]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('BIG後緑', countBigGreenController, suffix: '回', backgroundColor: Colors.green[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('BIG後赤', countBigRedController, suffix: '回', backgroundColor: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('BIG後虹', countBigRainbowController, suffix: '回', backgroundColor: Colors.pink[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('BIG後白', countBigWhiteController, suffix: '回', backgroundColor: Colors.grey[100]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text('REGサイドの色', style: Theme.of(context).textTheme.titleMedium),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REGサイド青', countSideBlueController, backgroundColor: Colors.blue[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('REGサイド黄', countSideYellowController, backgroundColor: Colors.yellow[100]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REGサイド緑', countSideGreenController, backgroundColor: Colors.green[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('REGサイド赤', countSideRedController, backgroundColor: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REGサイド虹', countSideRainbowController, backgroundColor: Colors.pink[100]),
                                      ),
                                      Expanded(child: SizedBox()),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text('REG後の色', style: Theme.of(context).textTheme.titleMedium),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REG後青', countRegBlueController, backgroundColor: Colors.blue[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('REG後黄', countRegYellowController, backgroundColor: Colors.yellow[100]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REG後緑', countRegGreenController, backgroundColor: Colors.green[100]),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: _buildInputField('REG後赤', countRegRedController, backgroundColor: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputField('REG後虹', countRegRainbowController, backgroundColor: Colors.pink[100]),
                                      ),
                                      Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            isExpanded: _showColorInputs,
                          ),
                        ],
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            _showColorInputs = !_showColorInputs;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveRecord,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('記録を保存'),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RecordsScreen()),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('記録を表示'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text('設定配分を入力'),
                                onTap: () {
                                  setState(() {
                                    _showHaibun = !_showHaibun;
                                  });
                                },
                              );
                            },
                            body: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  for (int i = 0; i < 6; i += 2)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInputField(
                                              '設定${i + 1}',
                                              haibunControllers[i],
                                              suffix: '台'
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: _buildInputField(
                                              '設定${i + 2}',
                                              haibunControllers[i + 1],
                                              suffix: '台'
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            for (var controller in haibunControllers) {
                                              controller.text = '1';
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('均等'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final values = [10, 40, 35, 11, 5, 1];
                                            for (int i = 0; i < haibunControllers.length; i++) {
                                              haibunControllers[i].text = values[i].toString();
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('通常'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final values = [10, 40, 25, 15, 11, 2];
                                            for (int i = 0; i < haibunControllers.length; i++) {
                                              haibunControllers[i].text = values[i].toString();
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('特日'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            isExpanded: _showHaibun,
                          ),
                        ],
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            _showHaibun = !_showHaibun;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _calculate,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('設定判別する'),
                        ),
                      ),
                      if (result != null) ...[
                        SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('設定期待度',
                                    style: Theme.of(context).textTheme.titleLarge),
                                ...List.generate(6, (index) {
                                  return Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('設定${index + 1}: ${result!.probabilities[index]}%'),
                                      LinearProgressIndicator(
                                        value: (result!.probabilities[index] / 100).isNaN ?
                                        0.0 :
                                        (result!.probabilities[index] / 100).clamp(0.0, 1.0),
                                      ),
                                    ],
                                  );
                                }),
                                SizedBox(height: 16),
                                Text('各平均期待値',
                                    style: Theme.of(context).textTheme.titleMedium),
                                ListTile(
                                  title: Text('平均設定'),
                                  trailing: Text('${result!.averageSettings}'),
                                ),
                                ListTile(
                                  title: Text('平均PAYOUT'),
                                  trailing: Text('${result!.averagePayout}%'),
                                ),
                                ListTile(
                                  title: Text('平均時給(800G/時)'),
                                  trailing: Text('${result!.averageWage}円(${result!.averageWage/20}枚)'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState?.validate() ?? false) {
      final newResult = SlotCalculator.calculate(
        currentGame: currentGameController.text,
        countSingleBig: countSingleBigController.text,
        countSingleReg: countSingleRegController.text,
        bigGames: bigGamesController.text,
        extraBigGames: extraBigGamesController.text,
        bigSuika: bigSuikaController.text,
        countBell: countBellController.text,
        startGame: startGameController.text,
        regSum: regSumController.text,
        bigSum: bigSumController.text,
        bigRetroSound: bigRetroSoundController.text,
        countBigBlue: countBigBlueController.text,
        countBigYellow: countBigYellowController.text,
        countBigGreen: countBigGreenController.text,
        countBigRed: countBigRedController.text,
        countBigRainbow: countBigRainbowController.text,
        countBigWhite: countBigWhiteController.text,
        countSideBlue: countSideBlueController.text,
        countSideYellow: countSideYellowController.text,
        countSideGreen: countSideGreenController.text,
        countSideRed: countSideRedController.text,
        countSideRainbow: countSideRainbowController.text,
        countRegBlue: countRegBlueController.text,
        countRegYellow: countRegYellowController.text,
        countRegGreen: countRegGreenController.text,
        countRegRed: countRegRedController.text,
        countRegRainbow: countRegRainbowController.text,
        countRegWhite: countRegWhiteController.text,
        haibun: haibunControllers.map((c) => c.text).toList(),
        machine: selectedMachine,
      );

      // 結果が変更された場合のみ setState を呼び出す
      if (result?.probabilities != newResult.probabilities) {
        setState(() {
          result = newResult;
        });

        // スクロールを最適化
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }
}