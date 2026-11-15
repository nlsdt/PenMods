import 'dart:io' show exit;

import 'package:flutter/material.dart';

/// 笔的界面并不铺满整块屏：宿主自带 UI 的内容只占中间一条（在 YDP03X 上实测
/// 800x480 屏的 y=127..353），上下都是纯黑。guest 应用跟随同一版式才不会显得
/// 突兀，所以 runner 会通过 `--band=<top>,<bottom>` 把这个带子传给 Dart。
class Band {
  const Band(this.top, this.bottom);
  final double top;
  final double bottom;

  static const none = Band(0, 0);

  /// 从 `main(List<String> args)` 里解析 `--band=127,127`。
  static Band parse(List<String> args) {
    for (final a in args) {
      if (!a.startsWith('--band=')) continue;
      final parts = a.substring('--band='.length).split(',');
      if (parts.length != 2) continue;
      final t = double.tryParse(parts[0]);
      final b = double.tryParse(parts[1]);
      if (t != null && b != null) return Band(t, b);
    }
    return none;
  }
}

void main(List<String> args) => runApp(SpikeApp(band: Band.parse(args)));

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key, this.band = Band.none});
  final Band band;

  @override
  Widget build(BuildContext context) {
    // Material 3, dark, pure-black surface.
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8E8E93),
      brightness: Brightness.dark,
    ).copyWith(surface: Colors.black);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme),
      // 所有页面统一套内容带：外面填黑，和宿主自带的上下黑边对齐。
      builder: (context, child) => ColoredBox(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.only(top: band.top, bottom: band.bottom),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: const SpikeHome(),
    );
  }
}

class SpikeHome extends StatefulWidget {
  const SpikeHome({super.key});
  @override
  State<SpikeHome> createState() => _SpikeHomeState();
}

class _SpikeHomeState extends State<SpikeHome> {
  int taps = 0;
  bool _loggedSize = false;
  bool switchOn = true;
  final textCtrl = TextEditingController(text: '中文输入测试');

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    if (!_loggedSize) {
      _loggedSize = true;
      debugPrint('APP logical size=${sz.width}x${sz.height} dpr=${MediaQuery.of(context).devicePixelRatio}');
    }
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (d) {
        debugPrint('TAPDOWN ui=${d.globalPosition.dx.toStringAsFixed(1)},${d.globalPosition.dy.toStringAsFixed(1)}');
        setState(() => taps++);
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '退出（结束进程）',
          // 笔的界面没有任务切换，返回的唯一语义就是退出这个应用。
          onPressed: () => exit(0),
        ),
        title: const Text('Flutter MD3'),
        backgroundColor: Colors.black,
        foregroundColor: c.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _snack(context, 'MD3 图标可用'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Flutter on PenMods', style: t.headlineSmall),
          const SizedBox(height: 4),
          Text('Mali G31 · Wayland · 800×480', style: t.bodySmall?.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('点击计数：$taps', style: t.titleMedium),
                const SizedBox(height: 12),
                Row(children: [
                  FilledButton(
                    onPressed: () => setState(() => taps++),
                    child: const Text('点我'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () => setState(() => taps = 0),
                    child: const Text('清零'),
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              SwitchListTile(
                title: const Text('开关 · Switch'),
                subtitle: const Text('MD3 开关'),
                value: switchOn,
                onChanged: (v) => setState(() => switchOn = v),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('列表项 · ListTile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _snack(context, '列表项被点击'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textCtrl,
            decoration: const InputDecoration(
              labelText: '输入框 · TextField',
              border: OutlineInputBorder(),
            ),
            onTap: () => _snack(context, '输入框获得焦点（宿主键盘不会弹出）'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Chip(label: Text('chip')),
            const SizedBox(width: 8),
            FilterChip(label: const Text('filter'), selected: true, onSelected: (_) {}),
            const Spacer(),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('MD3 对话框'),
                  content: const Text('这是真正的 Material 3 组件，不是手写的 QML。'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                    FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定')),
                  ],
                ),
              ),
              child: const Text('打开对话框'),
            ),
          ]),
        ],
      ),
    ));
  }

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
