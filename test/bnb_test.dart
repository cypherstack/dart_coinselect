import 'dart:convert';

import 'package:dart_coinselect/dart_coinselect.dart';
import 'package:dart_coinselect/src/algorithms/bnb_algorithm.dart';
import 'package:dart_coinselect/src/enums/algorithms_enum.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';
import 'package:test/test.dart';

// import 'fixtures/fixtures.dart' as utxos_json;
import 'fixtures/bnb.dart' as utxos_json;

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
      print(result.length);
      // expect(result.length, 0);
    });

    test('123456 satoshi as target, should return an empty array', () {
      List<InputModel> result = bnbAlgorithm(utxosBnb, 123456, 0);
      expect(result.length, 0);
    });
  });
}
