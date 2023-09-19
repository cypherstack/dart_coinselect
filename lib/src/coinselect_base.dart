import 'dart:convert';
import 'dart:math';

import 'package:dart_coinselect/src/algorithms/algorithms.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';
import 'package:dart_coinselect/src/utils.dart' as utils;

// Coin selection TS to dart
SelectionModel coinSelection(List<InputModel> utxos, List<OutputModel> outputs,
    int feeRate, int longTermFee) {
  int inputBytes = utils.transactionBytes([], outputs);

  var amount = utils.sumForgiving(outputs);
  int amountWithFees = inputBytes * feeRate + amount!;
  int? amountUtxos = utils.sumForgiving(utxos);

  if (amountWithFees > amountUtxos! || (feeRate < 0 || longTermFee < 0)) {
    int bytesAccum = utils.transactionBytes([], []);
    int fee = feeRate * bytesAccum;
    return SelectionModel(fee, inputs: [], outputs: []);
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

  List<Map<dynamic, dynamic>> results = [
    {
      "result": srdResult,
      "waste": srdResult.inputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(
              srdResult.inputs!, 10, amountWithFees, false)
    },
    {
      "result": bnbResult,
      "waste": bnbResult.inputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(bnbResult.inputs!, 0, amountWithFees, false)
    },
    {
      "result": knapsackResult,
      "waste": knapsackResult.inputs!.isEmpty
          ? 1000000
          : utils.getSelectionWaste(
              knapsackResult.inputs!, 0, amountWithFees, false)
    }
  ];

  results.sort((Map u1, Map u2) => u2['waste'] - u1['waste']);
  return results.last["result"];
}
