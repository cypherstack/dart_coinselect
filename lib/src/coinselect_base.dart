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
        fee: utxo.fee,
        longTermFee: utxo.longTermFee);
    coins.add(coin);
  }

  // print(coins);

  print(srd(coins, amountWithFees));
  SelectionModel srdResult =
      utils.finalize(srd(coins, amountWithFees), outputs, feeRate);
  SelectionModel bnbResult =
      utils.finalize(bnbAlgorithm(coins, amountWithFees, 0), outputs, feeRate);
  SelectionModel knapsackResult =
      utils.finalize(knapsack(coins, amountWithFees), outputs, feeRate);

  print(srdResult);
  // print(bnbResult);
  // print(knapsackResult);

  // print("SRD RESULT IS $srd_result");
  // var selection_waste =
  //     utils.getSelectionWaste(srd_result.outputs!, 10, amountWithFees, false);

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

  int min = 0;
  print("I AM PRINTING THIS VALUE ${result.map((e) => e['waste'])}");

  //  result.where((element) => {
  //   return element['waste'] == 0;
  // });
  // print(result.fi);

  // var bnb_result =
  //     utils.finalize(bnbAlgorithm(coins, amountWithFees, 0), outputs, feeRate);
  // var ks_result =
  //     utils.finalize(knapsack(coins, amountWithFees), outputs, feeRate);
  // // var sum = 0;
  // // utxos.forEach((element) { })
  // // var amountUtxos = utxos.fold(0, (sum, next) => sum.hashCode + next.value!);
  //
  // print("SRD RESULT IS $srd_result");
  // print("SELECTION WASTE IS $selection_waste");
  // print("SELECTION WASTE IS $selection_waste");
  // var sum = outputs.fold(0, (sum, next) => sum.v + next.value!);
  // var amount = outputs.reduce((v, e) {
  //   print('v=$v e=$e result=${v.value! + e.value!}');
  //   var result = v.value! + e.value!;
  //   print("RESULT IS $result");
  //   return result;
  // });
  // console.log(amount);
  // const amount_with_fees = input_bytes * fee_rate + amount;
  // const amount_utxos = utxos.reduce((a, {value}) => a + value, 0);
  print(inputBytes);
  return {};
}
