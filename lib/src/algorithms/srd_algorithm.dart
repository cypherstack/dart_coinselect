import 'package:dart_coinselect/src/models/models.dart';

List<InputModel> srd(List<OutputModel> utxos, int target) {
  utxos.shuffle();

  List<InputModel> finalSolution = [];
  int accumulativeValue = 0;

  for (int index = 0; index <= utxos.length; index++) {
    finalSolution.add(InputModel(
        i: index, value: utxos[index].value, script: utxos[index].script));
    accumulativeValue += utxos[index].value!;

    if (accumulativeValue >= target) {
      break;
    }
  }
  return finalSolution;
}
