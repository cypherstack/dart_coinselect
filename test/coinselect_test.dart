import 'dart:convert';

import 'package:dart_coinselect/dart_coinselect.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';
import 'fixtures/bnb.dart' as utxos_json;

void main() {
  // group('Testing blackjack algorithm', () {
  //   for (Fixture fixture in coinSelectFixtures) {
  //     test(fixture.description, () {
  //       List<InputModel> inputModels =
  //           List<InputModel>.from(fixture.inputs.map((e) => e.toInputModel()));
  //       List<OutputModel> outputModels = List<OutputModel>.from(
  //           fixture.outputs.map((e) => e.toOutputModel()));
  //
  //       final SelectionModel actual =
  //           coinSelect(inputModels, outputModels, fixture.feeRate);
  //
  //       final SelectionModel expected = fixture.expected.toSelectionModel();
  //
  //       expect(actual.isEqual(expected), isTrue);
  //     });
  //   }
  // });

  List<OutputModel> utxos = [];
  var utxoJson = jsonEncode(utxos_json.utxos);
  var utxoObj = json.decode(utxoJson);

  utxoObj.forEach((element) {
    OutputModel outputGroup =
        OutputModel(value: element['value'], fee: 10, longTermFee: 10);
    utxos.add(outputGroup);
  });

  group('Test coin selection', () {
    test('9560 satoshis, should return 1 input (BnB solution)', () {
      List<OutputModel> outputs = [];
      outputs.add(OutputModel(value: 9560));
      // print(testMe);
      // OutputModel testOutput = OutputModel(value: 9560);

      var result = coinSelection(utxos, outputs, 10, 10);
      // expect(result.length, 1);
    });
  });
}
