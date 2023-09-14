import 'dart:math';

import 'package:dart_coinselect/src/algorithms/algorithms.dart';
import 'package:dart_coinselect/src/algorithms/bnb_algorithm.dart';
import 'package:dart_coinselect/src/algorithms/knapsack_algorithm.dart';
import 'package:dart_coinselect/src/algorithms/srd_algorithm.dart';
import 'package:dart_coinselect/src/enums/algorithms_enum.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';
import 'package:dart_coinselect/src/utils.dart' as utils;

export 'algorithms/blackjack_algorithm.dart';

// order by descending value, minus the inputs approximate fee
int _utxoScore(InputModel input, int feeRate) {
  if (input.value == null) {
    return 0;
  }
  return input.value! - (feeRate * utils.inputBytes(input));
}

// Coin selection
SelectionModel coinSelect(
    List<InputModel> utxos, List<OutputModel> outputs, int feeRate,
    {AlgorithmsEnum? algo}) {
  switch (algo) {
    case AlgorithmsEnum.accumulative:
      return accumulativeAlgorithm(utxos, outputs, feeRate);
    case AlgorithmsEnum.blackjack:
      return blackjackAlgorithm(utxos, outputs, feeRate);
    case AlgorithmsEnum.breakAlgo:
      if (outputs.length > 1) {
        throw ArgumentError(
            'Output parameter must contain at most one element.');
      }

      return breakAlgorithm(utxos, outputs.first, feeRate);
    case AlgorithmsEnum.split:
      return splitAlgorithm(utxos, outputs, feeRate);
    default:
      {
        utxos.sort((a, b) => _utxoScore(b, feeRate) - _utxoScore(a, feeRate));

        // attempt to use the blackjack strategy first (no change output)
        SelectionModel base = blackjackAlgorithm(utxos, outputs, feeRate);
        if (base.inputs != null) {
          return base;
        }

        // else, try the accumulative strategy
        return accumulativeAlgorithm(utxos, outputs, feeRate);
      }
  }
}

// Coin selection TS to dart
Map<dynamic, dynamic> coinSelection(List<OutputModel> utxos,
    List<OutputModel> outputs, int feeRate, int longTermFee) {
  int inputBytes = utils.transactionBytes([], outputs);

  var amount = utils.sumForgiving(outputs);
  int amountWithFees = inputBytes * feeRate + amount!;
  int? amountUtxos = utils.sumForgiving(utxos);

  if (amountWithFees > amountUtxos! || (feeRate < 0 || longTermFee < 0)) {
    return {"inputs": [], "outputs": []};
  }

  List<OutputModel> coins = [];

  for (var utxo in utxos) {
    OutputModel coin = OutputModel(
        value: utxo.value!,
        script: utxo.script,
        fee: utxo.fee ?? feeRate,
        longTermFee: utxo.longTermFee ?? longTermFee);
    coins.add(coin);
  }

  final srdOutputs = outputs.toList();
  final bnbOutputs = outputs.toList();
  final ksOutputs = outputs.toList();

  SelectionModel srdResult =
      utils.finalize(srd(coins, amountWithFees), srdOutputs, feeRate);
  SelectionModel bnbResult = utils.finalize(
      bnbAlgorithm(coins, amountWithFees, 0), bnbOutputs, feeRate);
  SelectionModel knapsackResult =
      utils.finalize(knapsack(coins, amountWithFees), ksOutputs, feeRate);

  List<Map<dynamic, dynamic>> result = [
    {
      "result": srdResult,
      "waste": srdResult.outputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(
              srdResult.outputs!, 10, amountWithFees, false)
    },
    {
      "result": bnbResult,
      "waste": bnbResult.outputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(
              bnbResult.outputs!, 0, amountWithFees, false)
    },
    {
      "result": knapsackResult,
      "waste": knapsackResult.outputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(
              knapsackResult.outputs!, 0, amountWithFees, false)
    }
  ];

  print(result);
  return {};
}
