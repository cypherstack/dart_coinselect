import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/utils.dart';

const minChange = 500;

List<OutputModel> knapsack(List<OutputModel> utxos, int targetValue) {
  List<OutputModel> lowestLarger = [];
  List<OutputModel> applicableGroups = List.empty(growable: true);
  List<OutputModel> setCoinsRet = List.empty(growable: true);
  int totalLower = 0;

  utxos.shuffle();

  utxos.asMap().forEach((key, utxo) {
    int amount = getSelectionAmount(false, utxo, key);
    if (amount == targetValue) {
      setCoinsRet.add(utxo);
    } else if (amount < targetValue + minChange) {
      applicableGroups.add(utxo);
      totalLower += amount;
    }
  });

  if (totalLower == targetValue) {
    print("DO WE GET IN HERE");
    return applicableGroups;
  }
  applicableGroups.sort((a, b) => b.value! - a.value!);
  // print("APPLICABLE GROUPS IS $applicableGroups");
  Map<int, List<bool>> abs =
      approximateBestSubset(applicableGroups, totalLower, targetValue);
  print("ABS IS ${abs.keys.first}");

  if (abs.keys.first != targetValue && totalLower >= targetValue + minChange) {
    print("GETS IN HERE");
    abs = approximateBestSubset(
        applicableGroups, totalLower, targetValue + minChange);
  }

  return applicableGroups;
}
