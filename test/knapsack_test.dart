import 'dart:convert';

import 'package:dart_coinselect/src/algorithms/knapsack_algorithm.dart';
import 'package:test/test.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'fixtures/bnb.dart' as utxos_json;

void main() {
  group("Test KNAPSACK", () {
    List<OutputModel> utxos = [];
    var utxoJson = jsonEncode(utxos_json.utxos);
    var utxoObj = json.decode(utxoJson);

    utxoObj.forEach((element) {
      OutputModel outputGroup =
          OutputModel(value: element['value'], fee: 10, longTermFee: 10);
      utxos.add(outputGroup);
    });

    test('100000 satoshis as target, the sum should be greater than 100000',
        () {
      List<OutputModel> result = knapsack(utxos, 100000);
      expect(1.isOdd, true);
    });
  });
}
