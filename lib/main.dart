import 'package:flutter/material.dart';
import 'rust_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust Logger Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Rust Logger Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _logPath = '';

  @override
  void initState() {
    super.initState();
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
    final logPath = await RustLogger.getDefaultLogPath();
    if (logPath != null) {
      setState(() {
        _logPath = logPath;
      });
      
      final success = await RustLogger.initialize(logPath: logPath);
      if (success) {
        print('日志系统初始化成功，日志文件路径: $logPath');
      } else {
        print('日志系统初始化失败');
      }
    }
  }

  Future<void> _logMessage(String level, String message) async {
    switch (level) {
      case 'debug':
        await RustLogger.debug(message);
        break;
      case 'info':
        await RustLogger.info(message);
        break;
      case 'warn':
        await RustLogger.warn(message);
        break;
      case 'error':
        await RustLogger.error(message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '日志文件路径:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _logPath,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logMessage('debug', '这是一条调试日志消息'),
              child: const Text('记录调试日志'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logMessage('info', '这是一条信息日志消息'),
              child: const Text('记录信息日志'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logMessage('warn', '这是一条警告日志消息'),
              child: const Text('记录警告日志'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _logMessage('error', '这是一条错误日志消息'),
              child: const Text('记录错误日志'),
            ),
          ],
        ),
      ),
    );
  }
}
