# dart_coinselect

An unspent transaction output (UTXO) selection module for bitcoin.

**WARNING:** Value units are in `satoshi`s, **not** Bitcoin.

## Installation

    dart pub add dart_coinselect

## Algorithms
Module | Algorithm | Re-orders UTXOs?
-|-|-
`AlgorithmsEnum.bnb` | Branch and Bound - Searches UTXOs in a depth first fashion and select the least wasteful change-avoidant input set | -
`AlgorithmsEnum.knapsack` | Knapsack - Sort all UTXOs by value and run 1000 iterations of selections randomly picking UTXOs with a 50% chance from largest to smallest | -
`AlgorithmsEnum.srd` | SRD - Pick UTXOs randomly with equal chance from all available UTXOs | -


**Note:** Each algorithm will add a change output if the `input - output - fee` value difference is over a dust threshold.
This is calculated independently by `utils.finalize`, irrespective of the algorithm chosen, for the purposes of safety.

## Example

``` dart
import 'package:dart_coinselect/coinselect.dart';

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
```


## License [MIT](LICENSE)