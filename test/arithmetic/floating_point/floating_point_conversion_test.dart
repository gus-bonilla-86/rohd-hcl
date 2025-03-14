// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause
//
// floating_point_conversion_test.dart
// Tests for floating point conversion (FP to FP)
//
// 2025 January 30
// Author: Desmond A Kirkpatrick <desmond.a.kirkpatrick@intel.com

import 'dart:math';
import 'package:rohd_hcl/rohd_hcl.dart';
import 'package:test/test.dart';

void main() {
  test('FP: singleton conversion wide to narrow exponent', () async {
    final fv1 = FloatingPointValue.ofBinaryStrings('0', '000', '0001');
    final exponentWidth = fv1.exponent.width;
    final mantissaWidth = fv1.mantissa.width;
    final fp1 = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);

    const destExponentWidth = 2;
    const destMantissaWidth = 4;

    final fp2 = FloatingPoint(
        exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth);
    fp1.put(fv1);
    final convert = FloatingPointConverter(fp1, fp2);
    await convert.build();

    final expected = FloatingPointValue.populator(
            exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth)
        .ofDoubleUnrounded(
      fv1.toDouble(),
    );
    final expectedRound = FloatingPointValue.populator(
            exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth)
        .ofDouble(fv1.toDouble());

    final computed = convert.destination.floatingPointValue;
    expect(computed, equals(fp2.floatingPointValue));

    expect(computed, equals(expectedRound), reason: '''
      $fv1 (${fv1.toDouble()})\t=
      $computed (${computed.toDouble()})\tcomputed
      $expectedRound (${expectedRound.toDouble()})\texpected
      $expected (${expected.toDouble()})\texpected unrounded

''');
  });

  test('FP: singleton conversion narrow to wide exponent', () {
    final fv1 = FloatingPointValue.ofBinaryStrings('0', '000', '0001');
    final exponentWidth = fv1.exponent.width;
    final mantissaWidth = fv1.mantissa.width;
    final fp1 = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);

    const destExponentWidth = 4;
    const destMantissaWidth = 4;

    fp1.put(fv1);
    final fp2 = FloatingPoint(
        exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth);
    final convert = FloatingPointConverter(fp1, fp2);

    final expected = FloatingPointValue.populator(
            exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth)
        .ofDouble(fv1.toDouble());

    final computed = convert.destination.floatingPointValue;
    expect(computed, equals(fp2.floatingPointValue));

    expect(computed, equals(expected), reason: '''
                              $fv1 (${fv1.toDouble()})\t=
                              $computed (${computed.toDouble()})\tcomputed
                              $expected (${expected.toDouble()})\texpected
''');
  });
  test('FP: conversion wide to narrow exponent exhaustive', () {
    const exponentWidth = 6;
    const mantissaWidth = 6;
    const normal = 0; // set to zero for subnormal testing

    final fp1 = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth)
      ..put(0);
    for (var destExponentWidth = exponentWidth - 1;
        destExponentWidth > 2;
        destExponentWidth--) {
      for (var destMantissaWidth = mantissaWidth + 3;
          destMantissaWidth > 3;
          destMantissaWidth--) {
        final fp2 = FloatingPoint(
            exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth);
        final convert = FloatingPointConverter(fp1, fp2);
        final expLimit = pow(2, exponentWidth) - 1;
        final mantLimit = pow(2, mantissaWidth);
        for (final negate in [false, true]) {
          for (var e1 = normal; e1 < expLimit; e1++) {
            for (var m1 = 0; m1 < mantLimit; m1++) {
              final fv1 = FloatingPointValue.populator(
                      exponentWidth: exponentWidth,
                      mantissaWidth: mantissaWidth)
                  .ofInts(e1, m1, sign: negate);
              fp1.put(fv1.value);

              final expected = FloatingPointValue.populator(
                      exponentWidth: destExponentWidth,
                      mantissaWidth: destMantissaWidth)
                  .ofDouble(fv1.toDouble());

              final computed = convert.destination.floatingPointValue;
              expect(computed, equals(fp2.floatingPointValue));

              expect(computed, equals(expected), reason: '''
                              $fv1 (${fv1.toDouble()})\t=>
                              $computed (${computed.toDouble()})\tcomputed
                              $expected (${expected.toDouble()})\texpected
                              $destExponentWidth destExponentWidth
                              $destMantissaWidth destMantissaWidth
''');
            }
          }
        }
      }
    }
  });
  test('FP: conversion narrow to wide exhaustive', () {
    const exponentWidth = 4;
    const mantissaWidth = 5;
    const normal = 0; // set to zero for subnormal testing

    final fp1 = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);
    // ignore: cascade_invocations
    fp1.put(0);
    for (var destExponentWidth = exponentWidth;
        destExponentWidth < exponentWidth + 4;
        destExponentWidth++) {
      for (var destMantissaWidth = mantissaWidth - 2;
          destMantissaWidth < mantissaWidth + 6;
          destMantissaWidth++) {
        final fp2 = FloatingPoint(
            exponentWidth: destExponentWidth, mantissaWidth: destMantissaWidth);
        final convert = FloatingPointConverter(fp1, fp2);
        final expLimit = pow(2, exponentWidth) - 1;
        final mantLimit = pow(2, mantissaWidth);
        for (final negate in [false, true]) {
          for (var e1 = normal; e1 < expLimit; e1++) {
            for (var m1 = 0; m1 < mantLimit; m1++) {
              final fv1 = FloatingPointValue.populator(
                      exponentWidth: exponentWidth,
                      mantissaWidth: mantissaWidth)
                  .ofInts(e1, m1, sign: negate);
              fp1.put(fv1.value);

              final expected = FloatingPointValue.populator(
                      exponentWidth: destExponentWidth,
                      mantissaWidth: destMantissaWidth)
                  .ofDouble(fv1.toDouble());

              final computed = convert.destination.floatingPointValue;
              expect(computed, equals(fp2.floatingPointValue));

              expect(computed, equals(expected), reason: '''
                              $fv1 (${fv1.toDouble()})\t=>
                              $computed (${computed.toDouble()})\tcomputed
                              $expected (${expected.toDouble()})\texpected
''');
            }
          }
        }
      }
    }
  });

  test('FP: conversion exhaustive', () {
    for (var sEW = 2; sEW < 5; sEW++) {
      for (var sMW = 2; sMW < 5; sMW++) {
        final fp1 = FloatingPoint(exponentWidth: sEW, mantissaWidth: sMW)
          ..put(0);
        for (var dEW = 2; dEW < 6; dEW++) {
          for (var dMW = 2; dMW < 6; dMW++) {
            final fp2 = FloatingPoint(exponentWidth: dEW, mantissaWidth: dMW);
            final convert = FloatingPointConverter(fp1, fp2);
            for (final negate in [false, true]) {
              for (var e1 = 0; e1 < pow(2, sEW) - 1; e1++) {
                for (var m1 = 0; m1 < pow(2, sMW); m1++) {
                  final fv1 = FloatingPointValue.populator(
                          exponentWidth: sEW, mantissaWidth: sMW)
                      .ofInts(e1, m1, sign: negate);
                  fp1.put(fv1.value);

                  final expected = FloatingPointValue.populator(
                          exponentWidth: dEW, mantissaWidth: dMW)
                      .ofDouble(fv1.toDouble());

                  final computed = convert.destination.floatingPointValue;

                  expect(computed, equals(fp2.floatingPointValue));

                  expect(computed, equals(expected), reason: '''
                              $fv1 (${fv1.toDouble()})\t=>
                              $computed (${computed.toDouble()})\tcomputed
                              $expected (${expected.toDouble()})\texpected
''');
                }
              }
            }
          }
        }
      }
    }
  });
  test('FP: conversion subtypes', () {
    final fp32 = FloatingPoint32();
    final bf16 = FloatingPointBF16();

    final one =
        FloatingPoint32Value.populator().ofConstant(FloatingPointConstants.one);

    fp32.put(one);
    FloatingPointConverter(fp32, bf16);
    expect(bf16.floatingPointValue.toDouble(), equals(1.0));
  });
}
