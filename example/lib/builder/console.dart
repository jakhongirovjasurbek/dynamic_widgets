import 'package:flutter/material.dart';

enum LogLevel { info, warn, error }

class LogEntry {
  LogEntry(this.level, this.message) : time = DateTime.now();

  final LogLevel level;
  final String message;
  final DateTime time;
}

/// App-wide log shown in the bottom console. Also receives Flutter framework
/// errors (layout failures such as `Positioned` outside a `Stack`) so the user
/// sees why a JSON tree does not render.
class ConsoleLog extends ChangeNotifier {
  ConsoleLog._();

  static final ConsoleLog instance = ConsoleLog._();

  final List<LogEntry> _entries = [];
  List<LogEntry> get entries => List.unmodifiable(_entries);

  void info(String message) => _add(LogLevel.info, message);
  void warn(String message) => _add(LogLevel.warn, message);
  void error(String message) => _add(LogLevel.error, message);

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  void _add(LogLevel level, String message) {
    // Collapse identical consecutive messages (layout errors repeat per frame).
    if (_entries.isNotEmpty &&
        _entries.last.message == message &&
        _entries.last.level == level) {
      return;
    }
    _entries.add(LogEntry(level, message));
    if (_entries.length > 500) _entries.removeAt(0);
    notifyListeners();
  }

  /// Routes framework errors here. Call once from `main`.
  void captureFlutterErrors() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      error(_firstLine(details.exceptionAsString()));
      previous?.call(details);
    };
    ErrorWidget.builder = (details) => Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFFB3261E),
      child: Text(
        _firstLine(details.exceptionAsString()),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  static String _firstLine(String s) {
    final line = s.split('\n').first.trim();
    return line.length > 240 ? '${line.substring(0, 240)}…' : line;
  }
}

/// Bottom panel: log output.
class ConsolePanel extends StatefulWidget {
  const ConsolePanel({super.key});

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Text(
                'CONSOLE',
                style: TextStyle(fontSize: 11, letterSpacing: 1, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Clear console',
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.block),
                onPressed: ConsoleLog.instance.clear,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: ConsoleLog.instance,
            builder: (context, _) {
              final entries = ConsoleLog.instance.entries;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
              });
              return ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: entries.length,
                itemBuilder: (context, i) => _LogRow(entry: entries[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Small underline tab used by the right sidebar.
class PanelTab extends StatelessWidget {
  const PanelTab({required this.label, required this.selected, required this.onTap, super.key});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (entry.level) {
      LogLevel.info => (Icons.info_outline, scheme.onSurfaceVariant),
      LogLevel.warn => (Icons.warning_amber, const Color(0xFFE0A100)),
      LogLevel.error => (Icons.error_outline, scheme.error),
    };
    final t = entry.time;
    final stamp =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stamp,
            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: scheme.outline),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: SelectableText(
              entry.message,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: entry.level == LogLevel.error ? scheme.error : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
