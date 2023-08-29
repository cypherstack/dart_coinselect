import 'package:dart_coinselect/src/utils.dart' as utils;
import 'package:dart_coinselect/src/models/models.dart';

const totalTries = 100000;

List<InputModel> bnbAlgorithm(
    List<OutputModel> utxos, int selectionTarget, int costOfChange) {
  int currValue = 0;
  List<bool> currSelection = [];
  List<InputModel> outSet = [];

  int currAvailableValue = 0;
  utxos.forEach((utxo) {
    currAvailableValue += utils.getSelectionAmount(true, utxo);
  });

  if (currAvailableValue < selectionTarget) {
    return [];
  }
  utxos.sort((a, b) => b.effectiveValue! - a.effectiveValue!);

  int currWaste = 0;
  List<bool> bestSelection = [];
  int bestWaste = (21000000 * 100000000);

  for (int i = 0; i < totalTries; i++) {
    bool backTrack = false;
    if ((currValue + currAvailableValue) < selectionTarget ||
        currValue > (selectionTarget + costOfChange) ||
        (currWaste > bestWaste &&
            (utxos[0].fee! - utxos[0].longTermFee!) > 0)) {
      backTrack = true;
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
      backTrack = true;
    }

    if (backTrack) {
      while (currSelection.isNotEmpty &&
          !currSelection[currSelection.length - 1]) {
        currSelection.removeLast();
        currAvailableValue +=
            utils.getSelectionAmount(true, utxos[currSelection.length]);
      }
      if (currSelection.isEmpty) {
        // We have walked back to the first utxo and no branch is untraversed. All solutions searched
        break;
      }

      currSelection[currSelection.length - 1] = false;
      OutputModel utxo = utxos[currSelection.length--];
      currValue -= utils.getSelectionAmount(true, utxo);
      currWaste -= utxo.fee! - utxo.longTermFee!;
    } else {
      OutputModel utxo = utxos[currSelection.length];
      currAvailableValue += utils.getSelectionAmount(true, utxo);

      if (currSelection.isNotEmpty &&
          !currSelection[currSelection.length - 1] &&
          utils.getSelectionAmount(true, utxo) ==
              utils.getSelectionAmount(true, utxos[currSelection.length - 1]) &&
          utxo.fee! == utxos[currSelection.length - 1].fee!) {
        currSelection.add(false);
      } else {
        currSelection.add(true);
        currValue += utils.getSelectionAmount(true, utxo);
        currWaste += utxo.fee! - utxo.longTermFee!;
      }
    }
  }

  if (bestSelection.isEmpty) {
    return [];
  }

  for (int i = 0; i < bestSelection.length; i++) {
    if (bestSelection[i]) {
      outSet.add(utxos[i] as InputModel);
    }
  }
  return outSet;
}
