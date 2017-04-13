import 'package:backus/build.dart' as backus;
import 'package:build_runner/build_runner.dart';

final PhaseGroup phases = new PhaseGroup()
  ..addPhase(
      backus.backusPhase(new InputSet('backus_math', const ['lib/text/*.ebnf'])));
