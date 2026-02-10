# Flutter + Rust 性能分析实验室 🧪

本项目是一个深度探索 **Flutter (Dart)** 与 **Rust** 在高性能场景下应用分工的实验室。通过针对 JSON 解析、大数据流处理和异构计算的 Benchmark，旨在量化 FFI 开销，寻找跨语言协作的最优解。

## 🚀 核心实验功能

本项目内置了一套完整的 **JSON Benchmark Suite**，涵盖以下维度：

1.  **多级容量测试**: 模拟 1KB (配置) 到 20MB (大型数据集) 的真实业务负载。
2.  **全量方案对比**:
    *   **Dart Native**: 标准 `jsonDecode` 方案。
    *   **Dart Fused (🏅)**: `utf8.decoder.fuse(json.decoder)`，目前已知处理字节流最快的方式。
    *   **Dart Isolate**: 验证 `compute()` 在防 UI 卡顿与内存拷贝开销间的权衡。
    *   **Rust FFI**: 对比 `serde_json` 动态解析与特定 Struct 映射的性能。
    *   **Rust Zero Copy**: 验证 `Uint8List` 直接传参对性能的提升。
    *   **Rust Stream (🛡️)**: 应对超大数据量下的内存压力测试，支持首屏瞬间响应。
3.  **稳定性优化**: 实验环境包含 **JIT 预热 (Warmup)** 和 **GC 提示 (Force GC)**，确保数据真实可靠。

## 📊 性能实验室结论 (TL;DR)

通过在真机环境下的密集测试，我们得出了以下核心选型建议：

*   **常规业务**: 优先使用 `Dart Fused` 解码。由于 FFI 跨语言构造对象的开销超过解析本身带来的收益，普通的 JSON-to-Map 需求中 Rust 并不占优。
*   **防 UI 卡顿**: 大数据解析请使用 `compute()`，即便它总耗时更长，但能保证动画不掉帧。
*   **Rust 优势区**:
    *   **解析 + 密集计算**: 数据留在 Rust 侧处理，仅返回少量计算结果。
    *   **海量数据流**: 利用 Rust Stream 避免 Dart 侧发生 OOM。

## 🛠️ 开始实验

### 1. 环境准备
项目基于 `flutter_rust_bridge` 构建，请确保本地已配置：
- Flutter SDK
- Rust 编译器 (`cargo`)
- `flutter_rust_bridge_codegen`

### 2. 生成 Bindings
```bash
flutter_rust_bridge_codegen generate
```

### 3. 运行测试
建议开启 **Profile 模式** 以获得真实的性能数据：
```bash
flutter run --profile
```

## 📖 实验笔记 (深度文档)

*   [性能对比深度分析报告 (JSON 解析场景)](doc/01_json_performance_analysis.md)
*   [零拷贝与流式处理报告 (大数据场景)](doc/02_zero_copy_and_streaming_walkthrough.md)
*   [技术博文 (Rust vs Dart 选型实战)](doc/03_rust_vs_dart_exploration_blog.md)

---
> 本项目由 AI 辅助分析并撰写。
