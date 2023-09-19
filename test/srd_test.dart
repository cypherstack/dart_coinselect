import 'dart:convert';

import 'package:dart_coinselect/src/algorithms/srd_algorithm.dart';
import 'package:test/test.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'fixtures/utxos.dart' as utxos_json;

void main() {
  group("Test SRD", () {
    List<OutputModel> utxos = [];
    var utxoJson = jsonEncode(utxos_json.utxos);
    var utxoObj = json.decode(utxoJson);

    utxoObj.forEach((element) {
      OutputModel outputGroup =
          OutputModel(value: element['value'], fee: 10, longTermFee: 10);
      utxos.add(outputGroup);
    });

    test('1 satoshi as target, should return 1 input', () {
      List<InputModel> result = srd(utxos, 1);
      expect(result.length, 1);
    });

    test('1000000 satoshis as target, should return more than 1 input', () {
      List<InputModel> result = srd(utxos, 1000000);
      expect(result.length, greaterThan(1));
    });

    test('sum of the value of the inputs must be greater or equal the target',
        () {
      List<InputModel> result = srd(utxos, 1000000);

      int sum = 0;
      for (var number in result) {
        sum += number.value!;
      }
      expect(sum, greaterThanOrEqualTo(1000000));
    });
  });
}
