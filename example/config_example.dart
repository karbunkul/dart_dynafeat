import 'dart:convert';
import 'dart:io';

import 'package:dynafeat/dynafeat.dart';

void main() {
  final configFile = File('./config.json');
  final str = configFile.readAsStringSync();
  final json = jsonDecode(str);

  final config = FeatureConfig.import(json);

  final dynafeat = Dynafeat.from(config)..validate();
  print(dynafeat.feature('authBaseUrl'));
}
