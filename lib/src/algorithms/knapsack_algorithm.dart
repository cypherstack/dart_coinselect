import 'dart:typed_data';

import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/utils.dart';

const minChange = 500;

List<InputModel> knapsack(List<OutputModel> utxos, int targetValue) {
  OutputModel lowestLarger = OutputModel();
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
    } else if (!lowestLarger.isEqual(utxo) ||
        amount < getSelectionAmount(false, lowestLarger, key)) {
      lowestLarger = utxo;
    }
  });

  if (totalLower == targetValue) {
    List<InputModel> returnData = List.empty(growable: true);
    applicableGroups.asMap().forEach((key, element) {
      returnData.add(InputModel(
          i: key, value: element.value, script: element.script ?? ByteData(0)));
    });
    return returnData;
  }

  if (totalLower < targetValue) {
    if (lowestLarger.isEqual(OutputModel())) {
      return [];
    }
    return [
      InputModel(
          i: 0,
          value: lowestLarger.value,
          script: lowestLarger.script ?? ByteData(0))
    ];
  }

  applicableGroups.sort((a, b) => b.value! - a.value!);
  Map<int, List<bool>> abs =
      approximateBestSubset(applicableGroups, totalLower, targetValue);

  if (abs.keys.first != targetValue && totalLower >= targetValue + minChange) {
    abs = approximateBestSubset(
        applicableGroups, totalLower, targetValue + minChange);
  }

  if (!lowestLarger.isEqual(OutputModel()) &&
          (abs.keys.first != targetValue &&
              abs.keys.first < targetValue + minChange) ||
      getSelectionAmount(false, lowestLarger, 0) <= abs.keys.first) {
    return [
      InputModel(
          i: 0,
          value: lowestLarger.value ?? 0,
          script: lowestLarger.script ?? ByteData(0))
    ];
  } else {
    List<InputModel> finalReturn = List.empty(growable: true);
    for (int i = 0; i < applicableGroups.length; i++) {
      if (abs.values.isNotEmpty) {
        finalReturn.add(InputModel(
            i: i,
            value: applicableGroups[i].value,
            script: applicableGroups[i].script ?? ByteData(0)));
      }
    }
    return finalReturn;
  }
}
