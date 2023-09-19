import 'package:dart_coinselect/dart_coinselect.dart';

const feeRate = 55;

void main() {
  List<InputModel> utxos = [
    InputModel(
        i: 0,
        txid:
            '61d520ccb74288c96bc1a2b20ea1c0d5a704776dd0164a396efec3ea7040349d',
        value: 10000),
  ];

  List<OutputModel> outputs = [
    OutputModel(address: '1EHNa6Q4Jz2uvNExL497mE43ikXhwF6kZm', value: 5000)
  ];

  final selection = coinSelection(utxos, outputs, feeRate, 10);
  print(selection);
  // Output is '{"fee": "5000"}"
  // the accumulated fee is always returned for analysis

  // .inputs and .outputs will be null if no solution was found
  if (selection.inputs!.isEmpty || selection.outputs!.isEmpty) return;

  // Create raw transaciton and sign it...
}
