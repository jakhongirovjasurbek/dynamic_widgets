# Dynamic JSON Widgets for Flutter

This module provides a **Server-Driven UI system** for Flutter.
It allows building Flutter widgets dynamically from **JSON configuration**.

Instead of hardcoding UI in Dart, the interface can be described in JSON and rendered at runtime. This makes it possible to update parts of the UI **without releasing a new app version**.

---

# Features

* Build Flutter UI from JSON
* Support for common layout widgets
* Recursive widget rendering
* Argument injection system
* Easy to extend with custom widgets
* Useful for **remote UI**, **in-app campaigns**, and **dynamic screens**

---

# Supported Widgets

Currently supported widget types:

| JSON Type               | Flutter Widget        |
| ----------------------- | --------------------- |
| `container`             | Container             |
| `row`                   | Row                   |
| `column`                | Column                |
| `stack`                 | Stack                 |
| `sizedBox`              | SizedBox              |
| `padding`               | Padding               |
| `center`                | Center                |
| `align`                 | Align                 |
| `positioned`            | Positioned            |
| `icon`                  | CustomImage           |
| `text`                  | Text                  |
| `expanded`              | Expanded              |
| `singleChildScrollView` | SingleChildScrollView |
| `backDropFilter`        | BackdropFilter        |
| `clipRRect`             | ClipRRect             |

All widget types are defined in:

```
dynamic_widgets/types/types.dart
```

---

# How It Works

Each widget type has a corresponding class that extends `JsonWidget`.

Example:

```
abstract class JsonWidget {
  JsonWidget(this.context);

  final BuildContext context;

  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments});
}
```

The system reads the `type` field from JSON and delegates rendering to the corresponding widget builder.

Example dispatcher:

```
JsonWidget.fromType(
  context: context,
  json: json,
)
```

Internally this uses a `switch` on `JsonWidgetTypes`.

---

# Example JSON

Example UI configuration:

```
{
  "type": "column",
  "children": [
    {
      "type": "text",
      "data": "Hello World"
    },
    {
      "type": "container",
      "padding": 16,
      "child": {
        "type": "text",
        "data": "Dynamic UI"
      }
    }
  ]
}
```

This JSON will render:

```
Column
 ├─ Text("Hello World")
 └─ Container
     └─ Text("Dynamic UI")
```

---

# Rendering Widgets

To render a widget from JSON:

```dart
Widget widget = JsonWidget.fromType(
  context: context,
  json: jsonData,
);
```

This will recursively build all child widgets.

---

# Arguments System

The system supports runtime arguments using `InAppArgument`.

These arguments allow injecting dynamic values into JSON configuration.

Example:

```dart
JsonWidget.fromType(
  context: context,
  json: jsonData,
  arguments: arguments,
);
```

This is useful for:

* user data
* runtime values
* navigation parameters

---

# Adding a New Widget

To add a new widget:

### 1️⃣ Create a new widget class

Example:

```
class JsonWidget$Example extends JsonWidget {
  JsonWidget$Example(super.context);

  @override
  Widget fromJson(Map<String, dynamic> json, {List<InAppArgument>? arguments}) {
    return ExampleWidget();
  }
}
```

### 2️⃣ Add it to `JsonWidgetTypes`

```
enum JsonWidgetTypes {
  ...
  example
}
```

### 3️⃣ Register it in `JsonWidget.fromType`

```
JsonWidgetTypes.example =>
    JsonWidget$Example(context).fromJson(json),
```

---

# Use Cases

This system is useful for:

* Server-Driven UI
* Feature flags
* A/B testing
* Dynamic banners
* In-app campaigns
* Remote layouts
* Fintech promotions

---

# Notes

* JSON values for sizes may come as `int` or `double`.
* The helper method `fromIntToDouble()` converts them safely.

Example:

```
double? fromIntToDouble(dynamic value)
```

---

# License

Internal project module.
