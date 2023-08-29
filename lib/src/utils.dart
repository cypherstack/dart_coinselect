import 'dart:math';

import 'package:dart_coinselect/src/abstracts/io_model_abstract.dart';
import 'package:dart_coinselect/src/constants.dart';
import 'package:dart_coinselect/src/models/models.dart';
import 'package:dart_coinselect/src/models/selection_model.dart';

// Get input bytes.
// If the input script is not null, it sums script byte length, the txInputBase, and the txInputPubKeyHash.
int inputBytes(InputModel input) {
  return txInputBase +
      (input.script != null ? input.script!.lengthInBytes : txInputPubKeyHash);
}

// Get output bytes.
// Returns the sum of the script byte length, the txOutputBase and the txOutputPubKeyHash
int outputBytes(OutputModel output) {
  return txOutputBase +
      (output.script != null
          ? output.script!.lengthInBytes
          : txOutputPubKeyHash);
}

// Get dust threshold
// Returns the sum of the empty inputBytes and feeRate
int dustThreshold(/*OutputModel output, */ int feeRate) {
  return inputBytes(InputModel(i: 0)) * feeRate;
}

// Getting transaction bytes
// Returns the sum of the empty transaction length, transaction input bytes and output bytes
int transactionBytes(List<InputModel> inputs, List<OutputModel> outputs) {
  int inputByte =
      inputs.fold(0, (prevValue, input) => prevValue + inputBytes(input));
  int outputByte =
      outputs.fold(0, (prevValue, output) => prevValue + outputBytes(output));
  return txEmptySize + inputByte + outputByte;
}

// Sum all values
int? sumOrNull(List<IOModelAbstract> arr) {
  return arr.fold(
      0,
      (previousValue, element) =>
          element.value == null ? null : previousValue! + element.value!);
}

// Sum all values
// If value is null convert it to zero and continue
int? sumForgiving(List<IOModelAbstract> arr) {
  return arr.fold(
      0,
      (previousValue, element) =>
          (previousValue ?? 0) + (element.value != null ? element.value! : 0));
}

// Finalize UTXOs
SelectionModel finalize(
    List<InputModel> inputs, List<OutputModel> outputs, int feeRate) {
  final int bytesAccum = transactionBytes(inputs, outputs);
  final int feeAfterExtraOutput = feeRate * (bytesAccum + txBlankOutput);

  int? inputSum = sumOrNull(inputs);
  int? outputSum = sumOrNull(outputs);

  int remainderAfterExtraOutput;
  int fee = 0;

  if (inputSum != null && outputSum != null) {
    remainderAfterExtraOutput = inputSum - (outputSum + feeAfterExtraOutput);
    fee = inputSum - outputSum;
  } else {
    return SelectionModel(feeRate * bytesAccum);
  }

  if (remainderAfterExtraOutput > dustThreshold(/*OutputModel(), */ feeRate)) {
    outputs.add(OutputModel(value: remainderAfterExtraOutput));

    inputSum = sumOrNull(inputs);
    outputSum = sumOrNull(outputs);
  }

  if (inputSum != null && outputSum != null) {
    fee = inputSum - outputSum;
  }

  return SelectionModel(fee, inputs: inputs, outputs: outputs);
}

List<int> getRandom(List<int> arr, int n) {
  List<int> result = [n];
  int len = arr.length;
  List<int> taken = [len];
  if (n > len) {
    throw RangeError("getRandom: more elements taken than available");
  }

  while (n > 0) {
    Random random = Random();
    int number = (random.nextInt(1) * len);
    int x = number.floor();
    result[n] = arr[taken.contains(x) ? taken[x] : x];
    taken[x] = taken.contains(len--) ? taken[len] : len;
  }
  return result;
}

int getRandomInt(int minNum, int maxNum) {
  Random random = Random();
  minNum = minNum.ceil();
  maxNum = maxNum.floor();
  return (random.nextInt(1) * (minNum + maxNum) + minNum).floor();
}

List<OutputModel> shuffle(List<OutputModel> outputs) {
  int currentIndex = outputs.length;
  int randomIndex = 0;

  var initialMap = new Map();

  if (currentIndex != 0) {
    Random random = Random();
    int curr = random.nextInt(1) * currentIndex;
    // Pick a remaining element...
    randomIndex = curr.floor();
    currentIndex--;

    // And swap it with the current element.

    // [outputs[currentIndex], outputs[randomIndex]] = [outputs[randomIndex], outputs[currentIndex]];
  }
  return outputs;
}

int getSelectionAmount(bool subtractFeeOutputs, OutputModel utxo) {
  int effectiveValue =
      utxo.value! - (effective_fee_rate * inputBytes(utxo as InputModel));
  return subtractFeeOutputs ? utxo.value! : effectiveValue;
}

int getSelectionWaste(List<OutputModel> inputs, int changeCost, int target,
    bool useEffectiveValue) {
  int waste = 0;
  int selectedEffectiveValue = 0;

  inputs.forEach((element) {
    waste += element.fee! - element.longTermFee!;
    selectedEffectiveValue +=
        useEffectiveValue ? element.effectiveValue! : element.value!;
  });

  if (changeCost > 0) {
    waste += changeCost;
  } else {
    waste += selectedEffectiveValue - target;
  }
  return waste;
}

Map<int, List<bool>> approximateBestSubset(
    List<OutputModel> groups, int totalLower, int targetValue, int iterations) {
  Map<int, List<bool>> _map = {};
  iterations = 1000;
  List<bool> vfIncluded = [];
  List<bool> vfBest = [];
  int best = totalLower;
  for (int rep = 0; rep < iterations && best != targetValue; rep++) {
    int total = 0;
    bool reachedTarget = false;
    for (int pass = 0; pass < 2 && !reachedTarget; pass++) {
      for (int i = 0; i < groups.length; i++) {
        int amount = getSelectionAmount(false, groups[i]);
        Random random = Random();
        if (pass == 0 ? random.nextInt(1) < 0.5 : !vfIncluded[i]) {
          total += amount;
          vfIncluded[i] = true;
          if (total >= targetValue) {
            reachedTarget = true;
            if (total < best) {
              best = total;
              vfBest = vfIncluded;
            }
            total += amount;
            vfIncluded[i] = false;
          }
        }
      }
    }
  }
  _map[best] = vfBest;
  return _map;
}
