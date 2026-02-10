import 'package:flutter/material.dart';
import 'package:my_rust_app/src/rust/api/simple.dart';
import 'package:my_rust_app/src/rust/frb_generated.dart';
import 'json_benchmark_page.dart'; // 引入新页面

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Rust Bridge Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Rust Greet Result:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              greet(name: "Tom"),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const JsonBenchmarkPage()),
          );
        },
        label: const Text('性能对比测试'),
        icon: const Icon(Icons.speed),
      ),
    );
  }
}
