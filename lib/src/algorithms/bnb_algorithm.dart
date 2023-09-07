import 'package:dart_coinselect/src/utils.dart' as utils;
import 'package:dart_coinselect/src/models/models.dart';

const totalTries = 100000;

List<OutputModel> bnbAlgorithm(
    List<OutputModel> utxos, int selectionTarget, int costOfChange) {
  int currValue = 0;
  List<bool> currSelection = List.empty(growable: true);
  List<OutputModel> outSet = List.empty(growable: true);
  int currAvailableValue = 0;

  utxos.asMap().forEach((key, value) {
    currAvailableValue += utils.getSelectionAmount(true, value, key);
  });

  if (currAvailableValue < selectionTarget) {
    return [];
  }

  utxos.sort((a, b) => b.effectiveValue! - a.effectiveValue!);

  int currWaste = 0;
  List<bool> bestSelection = List.empty(growable: true);
  int bestWaste = (21000000 * 100000000);

  for (int i = 0; i < totalTries; ++i) {
    bool backtrack = false;

    if (currValue + currAvailableValue < selectionTarget ||
        currValue > selectionTarget + costOfChange ||
        (currWaste > bestWaste &&
            (utxos[0].fee! - utxos[0].longTermFee!) > 0)) {
      backtrack = true;
    } else if (currValue >= selectionTarget) {
      currWaste += (currValue - selectionTarget);

      if (currWaste <= bestWaste) {
        bestSelection = currSelection;
        bestWaste = currWaste;
        if (bestWaste == 0) {
          break;
        }
      }
      currWaste -= (currValue - selectionTarget);
      backtrack = true;
    }

    if (backtrack) {
      while (currSelection.isNotEmpty &&
          !currSelection[currSelection.length - 1]) {
        currSelection.removeLast();
        currAvailableValue +=
            utils.getSelectionAmount(true, utxos[currSelection.length], i);
      }

      if (currSelection.isEmpty) {
        break;
      }

      currSelection[currSelection.length - 1] = false;
      OutputModel utxo = utxos[currSelection.length - 1];
      currValue -= utils.getSelectionAmount(true, utxo, i);
      currWaste -= utxo.fee! - utxo.longTermFee!;
    } else {
      OutputModel utxo = utxos[currSelection.length];

      currAvailableValue -= utils.getSelectionAmount(true, utxo, i);

      if (currSelection.isNotEmpty &&
          !currSelection[currSelection.length - 1] &&
          utils.getSelectionAmount(true, utxo, i) ==
              utils.getSelectionAmount(
                  true, utxos[currSelection.length - 1], i) &&
          utxo.fee == utxos[currSelection.length - 1].fee) {
        currSelection.add(false);
      } else {
        currSelection.add(true);
        currValue += utils.getSelectionAmount(true, utxo, i);
        currWaste += utxo.fee! - utxo.longTermFee!;
      }
    }
  }

  if (bestSelection.isEmpty) {
    return [];
  }

  for (int i = 0; i < bestSelection.length; i++) {
    if (bestSelection[i]) {
      outSet.add(utxos[i]);
    }
  }

  return outSet;
}
