import 'dart:convert';

import 'package:dart_coinselect/dart_coinselect.dart';
import 'package:test/test.dart';

import 'fixtures/utxos.dart' as utxos_json;

void main() {
  group("Test BNB", () {
    List<OutputModel> utxosBnb = [];
    var utxoJson = jsonEncode(utxos_json.utxos);
    var utxoObj = json.decode(utxoJson);

    utxoObj.forEach((element) {
      OutputModel outputGroup =
          OutputModel(value: element['value'], fee: 10, longTermFee: 10);
      utxosBnb.add(outputGroup);
    });

    test('227837 satoshis as target, should return 1 input', () {
      List<InputModel> result = bnbAlgorithm(utxosBnb, 10000, 0);
      expect(result.length, 1);
    });

    test('123456 satoshi as target, should return an empty array', () {
      List<InputModel> result = bnbAlgorithm(utxosBnb, 123456, 0);
      expect(result.length, 0);
    });
  });
}
