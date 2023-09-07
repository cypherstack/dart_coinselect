import 'package:dart_coinselect/src/models/models.dart';

List<OutputModel> srd(List<OutputModel> utxos, int target) {
  utxos.shuffle();

  List<OutputModel> finalSolution = [];
  int accumulativeValue = 0;

  for (var element in utxos) {
    finalSolution.add(element);
    accumulativeValue += element.value!;

    if (accumulativeValue >= target) {
      break;
    }
  }
  return finalSolution;
}
