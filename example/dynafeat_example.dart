import 'package:dynafeat/dynafeat.dart';

void main() {
  final config = FeatureConfig(
    rev: 1,
    context: [
      Context.string(id: 'userId', summary: 'Логин пользователя', rev: 3),
      Context.string(
        id: 'os',
        summary: 'Операционная система',
        values: ['windows', 'macos', 'ios', 'android'],
      ),
      Context.string(
        id: 'flavor',
        summary: 'Тип сборки приложения',
        rev: 3,
        values: ['dev', 'beta', 'prod'],
      ),
    ],
    features: [
      Feature.string(
        id: 'authBaseUrl',
        summary: 'Базовый адрес сервера авторизации',
        value: 'https://cool.auth.server.com/api',
        rev: 2,
      ),
      Feature.number(
        id: 'port',
        summary: 'TCP порт',
        value: 3000,
        rules: [
          Rule(
            id: 'port',
            conditions: [
              Condition.eq('flavor', 'prod'),
              Condition.eq('os', 'windows'),
            ],
            value: 5000,
            summary: 'TCP порт на основе flavor',
          ),
        ],
      ),
    ],
  );

  final dynafeat = Dynafeat.from(config);

  // print(config.toJson(pretty: true));

  final res = <String, Object>{
    'authBaseUrl': dynafeat.feature('authBaseUrl', context: {'flavor': 'beta'}),
    'port': dynafeat.feature<int>(
      'port',
      context: {'flavor': 'prod', 'os': 'windows1'},
    ),
  };

  print(res);
}
