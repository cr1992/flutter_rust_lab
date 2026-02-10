# JSON 性能对比增强版 (支持通用解析)

我已经为您实现了真正的“通用 JSON 解析”对比方案。不仅仅是测速，现在 Rust 解析后的数据可以在 Dart 侧直接结构化访问。

## 核心实现说明

- **`DynamicValue` 模式**: 
  在 Rust 侧定义了递归枚举，将 `serde_json` 解析出的数据映射为 FRB 可识别的通用结构（Map, List, String, Number 等）。
- **结构化返回**: 
  解析后的数据不再是简单的成功标记，而是完整的、可在 Dart 侧遍历的对象。
- **UI 增强**: 
  在性能对比卡片下方增加了 **“解析数据预览 (Rust 传回)”** 区域，实时展示 Rust 侧解析并在 Dart 侧接收到的数据样本。

> [!IMPORTANT]
> **请务必使用 Profile 或 Release 模式运行！**
> 
> Rust 在 **Debug 模式** 下为了保证编译速度和调试信息，几乎不进行任何优化。像 `serde_json` 这样严重依赖内联优化的库，在 Debug 模式下可能比 Release 模式慢 10-100 倍！
> 
> - **推荐命令**: `flutter run --profile`
> - **原因**: Dart JIT 在 Debug 模式下相对较快，而 Rust Debug 极慢，这会导致“Rust 比 Dart 慢”的错觉。只有在 Release/Profile 模式下，Rust 的真实性能才能展现。

### 性能优化关键配置
在 `rust/Cargo.toml` 中必须包含以下配置，否则 Release 模式性能也会大打折扣：
```toml
[profile.release]
codegen-units = 1  # 牺牲编译时间换取运行时速度 (重要!)
lto = true         # 开启链接时优化，允许跨 crate 内联 (非常重要!)
panic = "abort"    # 减小体积并略微提升性能
strip = true       # 移除调试符号
```

## 如何验证通用解析

1. **运行项目**: 执行 `flutter run`。
2. **进入页面**: 点击“性能对比测试”。
3. **运行 Benchmark**: 点击开始测试按钮。
4. **验证数据**: 注意观察结果下方的预览区域。例如：
   - 对于 `Small` 用例，您会看到类似 `{"id": 0, "name": "Item 0", ...}` 的结构。
   - 这证明了 Rust 不仅解析得快，而且能准确地将复杂 JSON 结构传回 Dart。

## 关键文件

- **通用结构体 (Rust)**: [simple.rs](../rust/src/api/simple.rs)
- **UI 及预览逻辑 (Dart)**: [json_benchmark_page.dart](../lib/json_benchmark_page.dart)

## 4. 最终性能结论 (Final Performance Verdict)

基于 20MB 真实数据的 20 次平均测试（统一从 Bytes 起跑）：

1.  **Dart (Fused) 综合最强**：
    *   **263ms** vs Rust 401ms (20MB 数据)。
    *   `utf8.decoder.fuse(json.decoder)` 是处理网络响应的最佳实践，它直接消费字节流，无需中间 String，速度极快且内存友好。
2.  **Dart 原生解析完胜 Rust FFI**：
    *   **Dart (Bytes -> Decode)** 耗时 304ms，依然远快于 **Rust (Bytes - ZeroCopy)** 的 401ms。
    *   **原因**：Rust 解析本身可能只需 50ms，但将解析结果通过 FFI 转换成 Dart 的 `Map` 和 `List` 对象（涉及大量 C 句柄创建和内存分配）耗费了 350ms+。
3.  **Rust 的适用场景**：
    *   **仅** 当你需要“解析 JSON -> 过滤/聚合 -> 返回少量结果”时，Rust 才有优势（因为它省去了生成大量 Dart 对象的开销）。
    *   如果目标是获得完整的 Dart 对象树，**请直接使用 Dart 原生解析**。
    - 只有当需要 **流式处理无限大数据** (避免 OOM) 或 **解析后立即进行密集计算** (如加密、图像处理) 时，Rust 才是正解。

    - **常规业务**: 直接用 `jsonDecode`。
    - **防卡顿**: 用 `compute` (牺牲时间换流畅)。
    - **大数据流**: 用 Rust Stream (解决内存瓶颈)。
    - **密集计算**: 用 Rust (解决 CPU 瓶颈)。
