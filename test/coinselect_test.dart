import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_coinselect/dart_coinselect.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';
import 'fixtures/bnb.dart' as utxos_json;

void main() {
  List<OutputModel> utxos = [];
  var utxoJson = jsonEncode(utxos_json.utxos);
  var utxoObj = json.decode(utxoJson);

  utxoObj.forEach((element) {
    OutputModel outputGroup = OutputModel(value: element['value']);
    utxos.add(outputGroup);
  });

  group('Test coin selection', () {
    test('9560 satoshis, should return 1 input (BnB solution)', () {
      List<OutputModel> outputs = [];
      outputs.add(OutputModel(value: 9560));
      var result = coinSelection(utxos, outputs, 10, 10);
      expect(result.inputs?.length, 1);
    });

    test('100000 + 84975 satoshis, should not generate change (BnB solution)',
        () {
      List<OutputModel> outputs = [];
      outputs.add(OutputModel(value: 100000));
      outputs.add(OutputModel(value: 84975));
      var result = coinSelection(utxos, outputs, 10, 10);

      expect(result.outputs?.length, 2);
    });

    test('Insufficient funds, should return an empty solution', () {
      var utxoJson = jsonEncode([
        {
          "txId":
              "0eb727d9da3cbbabae776d8200221f68473d5a0bc2c456d18e419c493ed0bf2d",
          "vout": 46,
          "value": 14561,
        },
        {
          "txId":
              "d4eb4955286bb97c40302b5ec018b55f9b498f2b64ce726f19b0eadb7f4a7c44",
          "vout": 80,
          "value": 355933,
        }
      ]);
      var utxoObj = json.decode(utxoJson);
      utxoObj.forEach((element) {
        OutputModel outputGroup = OutputModel(value: element['value']);
        utxos.add(outputGroup);
      });
      List<OutputModel> outputs = [];
      outputs.add(OutputModel(value: 100000));
      var result = coinSelection(
          utxos,
          [
            OutputModel(
                value: 69036119, address: "1GsPMkp9dr1nHYoXzuBitiCiGcDzAuhnB5")
          ],
          1,
          1);

      expect(result.inputs?.length, 0);
      expect(result.outputs?.length, 0);
    });
  });
}
