# Dynafeat 🚩

A powerful, type-safe feature flagging and dynamic configuration library for Dart and Flutter.

## Key Features
- 🎯 **Context-Aware Rules:** Toggle features based on user ID, OS, build flavor, or any custom context.
- 🛡️ **Type Safety:** Native support for Strings, Numbers, and Booleans with compile-time safety.
- ⚙️ **Complex Conditions:** Use logical operators (eq, etc.) to define sophisticated release strategies.
- 🚀 **Built-in Caching:** High-performance resolution with an internal cache.
- ✅ **Validation:** Verify your configuration for consistency and logic errors.
- 🔌 **Offline-First:** Works entirely locally without needing a dedicated server or cloud provider.
- 🏗️ **Hybrid Ready:** Use it as a standalone local engine or as a client-side resolver for your own backend.

## Quick Start

```dart
// Define your feature configuration
final config = FeatureConfig(
  rev: 1,
  context: [Context.string(id: 'os')],
  features: [
    Feature.number(
      id: 'port',
      value: 3000,
      rules: [
        Rule(
          id: 'windows_port',
          conditions: [Condition.eq('os', 'windows')],
          value: 5000,
        ),
      ],
    ),
  ],
);

// Initialize Dynafeat
final dynafeat = Dynafeat.from(config);

// Evaluate feature based on context
final port = dynafeat.feature<int>(
  'port', 
  context: {'os': 'windows'}
); // returns 5000
```