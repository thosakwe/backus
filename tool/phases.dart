import 'package:backus/builder.dart';
import 'package:build_runner/build_runner.dart';

final PhaseGroup PHASES = new PhaseGroup.singleAction(const BackusBuilder(),
    new InputSet('backus', const ['test/grammars/*.ebnf']));
