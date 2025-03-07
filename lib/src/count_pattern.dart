import 'dart:math';

import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/src/utils.dart';

/// [Count] `pattern`.

class CountPattern extends Module {
  /// [_output] is output of CountPattern
  late Logic _output;

  /// The resulting count.
  Logic get count => _output;

  /// [Count] `pattern`.
  ///
  /// Takes in [bus] of type [Logic].
  /// [pattern] is the pattern to be counted in the bus.
  CountPattern(Logic bus, Logic pattern)
      : super(definitionName: 'CountPattern_W${bus.width}_P${pattern.width}') {
    bus = addInput('bus', bus, width: bus.width);
    pattern = addInput('pattern', pattern, width: pattern.width);
    Logic count = Const(0, width: max(1, log2Ceil(bus.width + 1)));

    print('bus: ${bus.value.toInt()}, width: ${bus.width}');
    print('pattern: ${pattern.value.toInt()}, width: ${pattern.width}');

    print('====CountPattern=======');
    for (var i = 0; i <= bus.width - pattern.width; i++) {
      print(
          '$i busRange = ${bus.getRange(i, i + pattern.width).value.toInt()}');
      if (bus.getRange(i, i + pattern.width).value.toInt() ==
          pattern.value.toInt()) {
        print('busRange == pattern');
        count += Const(1, width: count.width);
      }
      print('count: ${count.value}, width: ${count.width}');
      print('=======================');
    }
    _output = addOutput('count', width: count.width);
    _output <= count;
  }
}
