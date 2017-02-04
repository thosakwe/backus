import 'package:backus/build.dart' as backus;
import 'package:build_runner/build_runner.dart';

final PhaseGroup phases = new PhaseGroup()
  ..addPhase(
      backus.backusPhase(new InputSet('backus_json', const ['lib/text/*.ebnf'])));
