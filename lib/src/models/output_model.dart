import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_coinselect/src/abstracts/io_model_abstract.dart';

// Output Model
class OutputModel extends IOModelAbstract {
  @override
  ByteData? script;

  @override
  int? value;

  @override
  String? address;

  int? fee;

  int? longTermFee;

  int? effectiveValue;

  OutputModel(
      {this.value,
      this.script,
      this.address,
      this.fee,
      this.longTermFee,
      this.effectiveValue});

  OutputModel.from(OutputModel other) {
    script = other.script;
    value = other.value;
    address = other.address;
    fee = other.fee;
    longTermFee = other.longTermFee;
    effectiveValue = other.effectiveValue;
  }

  // Compares two OutputModels. Checks equality status
  isEqual(OutputModel other) {
    bool scriptOk = script == null && other.script == null;
    if (script != null && other.script != null) {
      scriptOk = hex.encode(Uint8List.view(script!.buffer)) ==
          hex.encode(Uint8List.view(other.script!.buffer));
    }

    return ((scriptOk &&
        value == other.value &&
        address == other.address &&
        fee == other.fee &&
        longTermFee == other.longTermFee &&
        effectiveValue == other.effectiveValue));
  }

  @override
  String toString() {
    List<String> str = [];
    if (address != null) str.add('"address": "$address"');
    if (value != null) str.add('"value": $value');
    if (script != null) str.add('"script": "${script.toString()}"');
    if (fee != null) str.add('"fee": "$fee"');
    if (longTermFee != null) str.add('"longTermFee": "$longTermFee"');
    if (effectiveValue != null) str.add('"effectiveValue": "$effectiveValue"');

    return "{${str.join(",")}}";
  }
}
