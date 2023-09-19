import 'dart:convert';
import 'package:dart_coinselect/dart_coinselect.dart';
import 'package:dart_coinselect/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group("Test util functions", () {
    test('test empty inputbyte', () {
      int inBytes = inputBytes(InputModel(i: 0, value: 100));
      expect(inBytes, 148);
    });

    test('test empty outputbytes', () {
      int outBytes = outputBytes(OutputModel(value: 100));
      expect(outBytes, 34);
    });

    test('test dustThreshold', () {
      int dust = dustThreshold(100);
      expect(dust, 14800);
    });
  });
}
