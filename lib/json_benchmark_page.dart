import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/rust/api/simple.dart' as rust_api;
import 'src/rust/frb_generated.dart';

class JsonBenchmarkPage extends StatefulWidget {
  const JsonBenchmarkPage({super.key});

  @override
  State<JsonBenchmarkPage> createState() => _JsonBenchmarkPageState();
}

class _JsonBenchmarkPageState extends State<JsonBenchmarkPage> {
  bool _isRunning = false;
  int _testIterations = 1; // 默认测试 1 次
  final List<BenchmarkResult> _results = [];

  // 测试用例定义
  final List<BenchmarkCase> _cases = [
    BenchmarkCase(
      name: 'Small (1KB)',
      description: '简单对象解析',
      generator: () => _generateJson(10),
    ),
    BenchmarkCase(
      name: 'Medium (100KB)',
      description: '包含 1000 个对象的列表',
      generator: () => _generateJson(1000),
    ),
    BenchmarkCase(
      name: 'Large (10MB)',
      description: '大规模数据集 (约 10MB)',
      generator: () => _generateJson(100000),
    ),
    BenchmarkCase(
      name: 'Extra Large (20MB)',
      description: '超大规模数据集 (约 20MB)',
      generator: () => _generateJson(200000),
    ),
    BenchmarkCase(
      name: 'Deeply Nested',
      description: '20 层深度的嵌套对象',
      generator: () => _generateNestedJson(20),
    ),
    BenchmarkCase(
      name: 'Large Array',
      description: '100,000 个数字的简单数组',
      generator: () => jsonEncode(List.generate(100000, (i) => i)),
    ),
  ];

  static String _generateJson(int count) {
    if (count == 0) return '{}'; // Warmup safe
    final List<Map<String, dynamic>> data = List.generate(
      count,
      (i) => {
        'id': i,
        'name': 'Item $i',
        'active': i % 2 == 0,
        'score': Random().nextDouble() * 100,
        'tags': ['tag1', 'tag2', 'tag3'],
        'metadata': {'timestamp': DateTime.now().toIso8601String(), 'version': '1.0'},
      },
    );
    return jsonEncode(count == 1 ? data.first : data);
  }

  static String _generateNestedJson(int depth) {
    Map<String, dynamic> buildNested(int currentDepth) {
      if (currentDepth >= depth) return {'leaf': 'end'};
      return {'node': buildNested(currentDepth + 1), 'value': currentDepth};
    }
    return jsonEncode(buildNested(0));
  }

  Future<void> _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    // WARMUP: 让 JIT 编译器预热，避免第一次运行特别慢
    await _warmup();

    for (final testCase in _cases) {
      final jsonStr = testCase.generator();
      
      double totalDartStringTime = 0;
      double totalDartBytesTime = 0;
      double totalDartFusedTime = 0;
      double totalDartComputeTime = 0;
      double totalRustTime = 0;
      double totalPureTime = 0;
      double totalBytesTime = 0;
      double totalStructTime = 0;
      double totalStreamTotalTime = 0;
      double totalStreamFirstItemTime = 0;

      for (int i = 0; i < _testIterations; i++) {
        // 0. Prepare Bytes (Simulate Network Response)
        final bytes = utf8.encode(jsonStr);

        // 1. Dart (String Input - Ideal Baseline)
        _forceGc(); 
        final stopwatchDartString = Stopwatch()..start();
        jsonDecode(jsonStr);
        stopwatchDartString.stop();
        totalDartStringTime += stopwatchDartString.elapsedMicroseconds / 1000.0;

        // 1.2 Dart (Bytes Input - Common Case)
        // jsonDecode(utf8.decode(bytes))
        _forceGc();
        final stopwatchDartBytes = Stopwatch()..start();
        final decodedString = utf8.decode(bytes); // Decode to String
        jsonDecode(decodedString);            // Then Parse
        stopwatchDartBytes.stop();
        totalDartBytesTime += stopwatchDartBytes.elapsedMicroseconds / 1000.0;

        // 1.5 Dart Fused (Bytes Input - Optimized)
        _forceGc();
        final stopwatchDartFused = Stopwatch()..start();
        utf8.decoder.fuse(json.decoder).convert(bytes);
        stopwatchDartFused.stop();
        totalDartFusedTime += stopwatchDartFused.elapsedMicroseconds / 1000.0;

        // 1.1 Dart (Compute - Isolate)
        _forceGc();
        final stopwatchDartCompute = Stopwatch()..start();
        await compute(jsonDecode, jsonStr);
        stopwatchDartCompute.stop();
        totalDartComputeTime += stopwatchDartCompute.elapsedMicroseconds / 1000.0;

        // 2. Rust quickJsonDecode
        _forceGc();
        final stopwatchRust = Stopwatch()..start();
        final decodedRust = await rust_api.quickJsonDecode(jsonStr: jsonStr);
        stopwatchRust.stop();
        totalRustTime += stopwatchRust.elapsedMicroseconds / 1000.0;

        // 3. Rust pureParse
        _forceGc();
        final stopwatchPure = Stopwatch()..start();
        await rust_api.pureJsonParse(jsonStr: jsonStr);
        stopwatchPure.stop();
        totalPureTime += stopwatchPure.elapsedMicroseconds / 1000.0;

        // 4. Rust Zero Copy (Bytes)
        // bytes 已经在上面生成了 (line 108)
        _forceGc();
        final stopwatchBytes = Stopwatch()..start();
        await rust_api.pureJsonParseBytes(bytes: bytes);
        stopwatchBytes.stop();
        totalBytesTime += stopwatchBytes.elapsedMicroseconds / 1000.0;

        // 5. Rust Struct & Stream
        if (jsonStr.contains('"email":')) {
           // Struct
           _forceGc();
           final stopwatchStruct = Stopwatch()..start();
           await rust_api.parseUserStruct(jsonStr: jsonStr);
           stopwatchStruct.stop();
           totalStructTime += stopwatchStruct.elapsedMicroseconds / 1000.0;

           // Stream
           _forceGc();
           final stopwatchStream = Stopwatch()..start();
           try {
             final stream = rust_api.parseUserStream(jsonBytes: utf8.encode(jsonStr));
             int count = 0;
             await for (final _ in stream) {
               if (count == 0) {
                 totalStreamFirstItemTime += stopwatchStream.elapsedMicroseconds / 1000.0;
               }
               count++;
             }
             stopwatchStream.stop();
             totalStreamTotalTime += stopwatchStream.elapsedMicroseconds / 1000.0;
           } catch (_) {}
        }
      }
      
      final dartStringTime = totalDartStringTime / _testIterations;
      final dartBytesTime = totalDartBytesTime / _testIterations;
      final dartFusedTime = totalDartFusedTime / _testIterations;
      final dartComputeTime = totalDartComputeTime / _testIterations;
      final rustTime = totalRustTime / _testIterations;
      final pureTime = totalPureTime / _testIterations;
      final bytesTime = totalBytesTime / _testIterations;
      final structTime = totalStructTime / _testIterations;
      final streamTotalTime = totalStreamTotalTime / _testIterations;
      final streamFirstItemTime = totalStreamFirstItemTime / _testIterations;

      print('--------------------------------------------------');
      print('Benchmark Case: ${testCase.name} (Avg over $_testIterations iterations)');
      print('  Dart (String): ${dartStringTime.toStringAsFixed(3)} ms');
      print('  Dart (Bytes): ${dartBytesTime.toStringAsFixed(3)} ms');
      print('  Dart (Fused): ${dartFusedTime.toStringAsFixed(3)} ms');
      print('  Dart (Compute): ${dartComputeTime.toStringAsFixed(3)} ms');
      print('  Rust (Dynamic): ${rustTime.toStringAsFixed(3)} ms');
      print('  Rust (Bytes): ${bytesTime.toStringAsFixed(3)} ms');
      if (structTime > 0) print('  Rust (Struct): ${structTime.toStringAsFixed(3)} ms');
      if (streamTotalTime > 0) {
        print('  Rust (Stream Total): ${streamTotalTime.toStringAsFixed(3)} ms');
        print('  Rust (Stream First): ${streamFirstItemTime.toStringAsFixed(3)} ms');
      }
      print('--------------------------------------------------');

      // 获取数据样本支持最后一次的结果 (仅用于展示)
      final sampleDecodedRust = await rust_api.quickJsonDecode(jsonStr: jsonStr);
      String sampleData = _formatDynamicValue(sampleDecodedRust);

      setState(() {
        _results.add(BenchmarkResult(
          caseName: testCase.name,
          dartStringTimeMs: dartStringTime,
          dartBytesTimeMs: dartBytesTime,
          dartFusedTimeMs: dartFusedTime, 
          dartComputeTimeMs: dartComputeTime, // 新增
          rustTimeMs: rustTime,
          rustPureTimeMs: pureTime,
          rustBytesTimeMs: bytesTime,
          rustStructTimeMs: structTime,
          rustStreamTotalTimeMs: streamTotalTime, // 新增
          rustStreamFirstItemTimeMs: streamFirstItemTime, // 新增
          sizeKb: jsonStr.length / 1024.0,
          sample: sampleData,
          originalJson: jsonStr,
        ));
      });
      
      await Future.delayed(Duration.zero); // 让 UI 喘口气
    }

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _warmup() async {
    print('Warming up JIT...');
    final warmupJson = _generateJson(100);
    for (int i = 0; i < 5; i++) {
       jsonDecode(warmupJson);
       utf8.decoder.fuse(json.decoder).convert(utf8.encode(warmupJson));
       await rust_api.quickJsonDecode(jsonStr: warmupJson);
       await rust_api.pureJsonParse(jsonStr: warmupJson);
    }
    print('Warmup done.');
  }

  void _forceGc() {
    // Dart 没有直接的 GC API，通过分配大对象并丢弃来暗示 VM 进行 GC
    // 注意：这只是一个 hint，不保证立即 GC，且本身有开销。
    // 但相比在测量过程中发生 GC，我们宁愿在测量前花点时间。
    List<int>? garbage = List.filled(1024 * 1024, 0); // 1MB garbage
    garbage = null; 
  }

  String _formatDynamicValue(rust_api.DynamicValue value) {
    if (value is rust_api.DynamicValue_String) return '"${value.field0}"';
    if (value is rust_api.DynamicValue_Number) return value.field0.toString();
    if (value is rust_api.DynamicValue_Bool) return value.field0.toString();
    if (value is rust_api.DynamicValue_Null) return 'null';
    if (value is rust_api.DynamicValue_List) {
      if (value.field0.isEmpty) return '[]';
      return '[${_formatDynamicValue(value.field0.first)}, ...]';
    }
    if (value is rust_api.DynamicValue_Map) {
      if (value.field0.isEmpty) return '{}';
      final firstEntry = value.field0.first;
      return '{"${firstEntry.$1}": ${_formatDynamicValue(firstEntry.$2)}, ...}';
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON 解码性能对比'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _results.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) => _buildResultCard(_results[index]),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isRunning ? null : _runBenchmark,
        label: Text(_isRunning ? '正在运行...' : '开始基准测试'),
        icon: _isRunning 
          ? const SizedBox(
              width: 18, 
              height: 18, 
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
            ) 
          : const Icon(Icons.play_arrow),
        backgroundColor: _isRunning ? Colors.grey : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '性能测试报告',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '所有测试均模拟**从网络接收字节(Bytes)**的真实场景。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('执行次数: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _testIterations,
                items: [1, 5, 10, 20].map((i) => DropdownMenuItem(
                  value: i,
                  child: Text('${i}x'),
                )).toList(),
                onChanged: _isRunning ? null : (val) {
                  if (val != null) setState(() => _testIterations = val);
                },
              ),
              if (_testIterations > 5) ...[
                const SizedBox(width: 12),
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                const Text('大数据量下建议选择较低次数', style: TextStyle(fontSize: 11, color: Colors.orange)),
              ],
            ],
          ),
          if (_isRunning) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '点击下方按钮开始测试',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BenchmarkResult result) {
    // 比较 Fused (最快 Dart 字节方案) 和 Rust Bytes
    final double bestDartTime = result.dartFusedTimeMs;
    final double bestRustTime = result.rustBytesTimeMs;
    final bool rustWon = bestRustTime < bestDartTime;
    final double speedup = bestDartTime / bestRustTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            result.caseName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: result.originalJson));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('JSON 已拷贝到剪贴板'), duration: Duration(seconds: 1)),
                              );
                            },
                            tooltip: '拷贝原始 JSON',
                          ),
                        ],
                      ),
                      Text(
                        '大小: ${result.sizeKb.toStringAsFixed(2)} KB',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (rustWon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      'Rust 快 ${speedup.toStringAsFixed(1)}x',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBar('Dart (String Input)', result.dartStringTimeMs, Colors.blue[200]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs), isBaseline: true),
            const SizedBox(height: 4),
            _buildBar('Dart (Bytes -> Decode -> Parse)', result.dartBytesTimeMs, Colors.blue[400]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs)),
            const SizedBox(height: 12),
            _buildBar('Dart (Bytes -> Fused)', result.dartFusedTimeMs, Colors.blue[600]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs)),
            const SizedBox(height: 12),
            _buildBar('Dart (compute - Isolate)', result.dartComputeTimeMs, Colors.blue[100]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs)),
            const SizedBox(height: 12),
            _buildBar('Rust (Dynamic - General)', result.rustTimeMs, Colors.orange[400]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs)),
            const SizedBox(height: 12),
            if (result.rustStructTimeMs > 0) ...[
               _buildBar('Rust (Struct - Specific)', result.rustStructTimeMs, Colors.orange[700]!, 
                  max(result.dartBytesTimeMs, result.rustTimeMs)),
               const SizedBox(height: 12),
            ],
            if (result.rustStreamTotalTimeMs > 0) ...[
               _buildBar('Rust (Stream - Total)', result.rustStreamTotalTimeMs, Colors.purple[300]!, 
                  max(result.dartBytesTimeMs, result.rustTimeMs)),
               const SizedBox(height: 4),
               Text('  First Item: ${result.rustStreamFirstItemTimeMs.toStringAsFixed(3)} ms (Instant!)', 
                 style: TextStyle(fontSize: 11, color: Colors.purple[700], fontStyle: FontStyle.italic)),
               const SizedBox(height: 12),
            ],
            _buildBar('Rust (pureJsonParse - String)', result.rustPureTimeMs, Colors.green[300]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs), isBaseline: true),
            const SizedBox(height: 12),
            _buildBar('Rust (Zero Copy - Bytes)', result.rustBytesTimeMs, Colors.green[700]!, 
                max(result.dartBytesTimeMs, result.rustTimeMs)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '解析数据预览 (Rust 传回):',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.sample,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double time, Color color, double maxTime, {bool isBaseline = false}) {
    final double percentage = time / maxTime;
    return Opacity(
      opacity: isBaseline ? 0.6 : 1.0,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${time.toStringAsFixed(3)} ms', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

class BenchmarkCase {
  final String name;
  final String description;
  final String Function() generator;

  BenchmarkCase({required this.name, required this.description, required this.generator});
}

class BenchmarkResult {
  final String caseName;
  final double dartStringTimeMs; // Old "Dart Time"
  final double dartBytesTimeMs; // New "Standard"
  final double dartFusedTimeMs;
  final double dartComputeTimeMs;
  final double rustTimeMs;
  final double rustPureTimeMs;
  final double rustBytesTimeMs;
  final double rustStructTimeMs;
  final double rustStreamTotalTimeMs;
  final double rustStreamFirstItemTimeMs;
  final double sizeKb;
  final String sample;
  final String originalJson;

  BenchmarkResult({
    required this.caseName,
    required this.dartStringTimeMs,
    required this.dartBytesTimeMs,
    required this.dartFusedTimeMs,
    required this.dartComputeTimeMs,
    required this.rustTimeMs,
    required this.rustPureTimeMs,
    required this.rustBytesTimeMs,
    required this.rustStructTimeMs,
    required this.rustStreamTotalTimeMs,
    required this.rustStreamFirstItemTimeMs,
    required this.sizeKb,
    required this.sample,
    required this.originalJson,
  });
}
