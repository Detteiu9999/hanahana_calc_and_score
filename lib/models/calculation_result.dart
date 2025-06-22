// lib/models/calculation_result.dart

class CalculationResult {
  final List<double> probabilities;
  final double averageSettings;
  final double averagePayout;
  final double averageWage;
  final List<String> probStrings;

  CalculationResult({
    required this.probabilities,
    required this.averageSettings,
    required this.averagePayout,
    required this.averageWage,
    required this.probStrings,
  });
}