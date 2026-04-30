import 'dart:convert';
import 'dart:io';

import 'package:dynafeat/dynafeat.dart';

void main() {
  final configFile = File('./dynafeat_config.json');
  final str = configFile.readAsStringSync();
  final json = jsonDecode(str);

  final config = FeatureConfig.import(json);

  final dynafeat = Dynafeat.from(config)..validate();
  print(dynafeat.feature('search_base_url_common', context: {'env': 'prod'}));
  print(dynafeat.feature('appmetrica_api_key', context: {'env': 'stage'}));
}
