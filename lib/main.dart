import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'rust_logger_binding.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the Rust logger with a file in the app's documents directory
  await initRustLogger();
  
  runApp(const MyApp());
}

Future<void> initRustLogger() async {
  try {
    // Get the app documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    // Create a log directory if it doesn't exist
    final logDir = Directory(path.join(appDocDir.path, 'logs'));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    
    // Set the log file path
    final logFilePath = path.join(logDir.path, 'app.log');
    print('Log file path: $logFilePath');
    
    // Initialize the Rust logger
    final initialized = RustLogger.initLogger(logFilePath);
    if (initialized) {
      print('Rust logger initialized successfully');
      RustLogger.info('Flutter app started');
    } else {
      print('Failed to initialize Rust logger');
    }
  } catch (e) {
    print('Error initializing Rust logger: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust Logger Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rust Logger Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _logFilePath = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    _getLogFilePath();
  }
  
  Future<void> _getLogFilePath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logFilePath = path.join(appDocDir.path, 'logs', 'app.log');
    setState(() {
      _logFilePath = logFilePath;
    });
  }

  void _logMessage(String level) {
    final message = 'Test $level log message at ${DateTime.now()}';
    
    switch (level.toLowerCase()) {
      case 'debug':
        RustLogger.debug(message);
        break;
      case 'info':
        RustLogger.info(message);
        break;
      case 'warn':
        RustLogger.warn(message);
        break;
      case 'error':
        RustLogger.error(message);
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$level message logged'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Test Rust logging with log4rs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('Log file location:'),
              Text(
                _logFilePath,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _logMessage('debug'),
                child: const Text('Log DEBUG Message'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _logMessage('info'),
                child: const Text('Log INFO Message'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _logMessage('warn'),
                child: const Text('Log WARN Message'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _logMessage('error'),
                child: const Text('Log ERROR Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
