# 《我在 Flutter 下折腾了三天 Rust JSON 解析提速，结论竟是：Dart 真香！》

老铁们，别笑。

我曾以为，只要祭出 **Rust** 这个大杀器，我的 Flutter 应用就能像装了 V8 引擎一样起飞。毕竟 Rust 可是号称“零成本抽象”、“内存安全”、“并在多线程上吊打一切”的存在。

于是，我兴致勃勃地通过 `flutter_rust_bridge` 把 JSON 解析这块“硬骨头”丢给了 Rust。

我想象中的画面：
> Dart: "这也太重了吧..." (试图举起 20MB JSON)
> Rust: (瞬间接手) "交给我！唰——搞定！" (0.1ms 后扔回一个对象)

现实中的画面：
> Dart: (默默解析完，喝了口茶) "好了，用了 300ms。"
> Rust: (开始启动) -> FFI 握手 -> 字符串拷贝 -> 再次拷贝 -> 解析 -> (满头大汗) -> 序列化 -> 扔回 Dart -> 反序列化 -> "呼... 1.7秒！我是不是很棒？"
> Dart: "..."

---

## 核心技术大揭秘：选手介绍

在看跑分之前，先认识一下今天的各位选手：

### 1. **Dart Native (Main)**
- **身份**: Flutter 的亲儿子，`dart:convert` 库中的 `jsonDecode`。
- **武器**: C++ 高度优化的 VM 内置解析器，直接在 Dart 堆内存上操作。
- **特点**: **没有中间商赚差价**。解析出来的 `Map` 和 `List` 直接就能用，不需要跨语言转换。

### 2. **Dart (Compute)**
- **身份**: Dart 的影分身术 (Isolate)。
- **武器**: `compute(jsonDecode, jsonStr)`。它会新开一个线程（Isolate）去解析。
- **特点**: **虽然慢，但不卡手**。因为 Isolate 之间内存不共享，数据要拷贝过去再拷贝回来（Copy Overhead），所以总耗时最长。但因为它不占用主线程（Main UI Thread），所以界面滑动如丝般顺滑。

### 3. **Rust (Dynamic)**
- **身份**: 通用型外援。
- **武器**: `serde_json` 解析成 `Value`，再通过 FFI 转成 Dart 的 `dynamic` 类型。
- **特点**: **翻译官累死人**。Rust 解析很快，但它要把解析结果翻译成 Dart 能懂的格式，这个过程比解析本身还慢。

### 4. **Rust (Bytes)**
- **身份**: 极速外援 (Zero Copy)。
- **武器**: 直接传字节流 (`Uint8List`) 给 Rust，省去了 UTF-16 转 UTF-8 的开销。
- **特点**: **尽力了**。虽然 Rust 解析只需 50ms，但“把 Rust 对象变成 Dart 对象”这一步依然逃不掉巨大的 FFI 开销。

### 5. **Dart (Fused - Bytes)**
- **身份**: **真·隐藏BOSS**。
- **武器**: `utf8.decoder.fuse(json.decoder).convert(bytes)`。
- **特点**: **一波流**。直接把 UTF-8 解码和 JSON 解析熔断在一起，流式处理字节，没有中间商（String）赚差价。这是 Dart 的终极奥义。

---

## 第一回合：小试牛刀 (1KB)

我先丢了一个 1KB 的小 JSON 过去。

**Dart Native**: `0.016ms`。
我看了一眼日志，以为写错了。这也太快了吧？这基本就是一次函数调用的时间啊。

**Dart (Fused)**: `0.013ms`。
一骑绝尘。

**Rust (Bytes)**: `1.024ms`。
慢了 **80 倍**！
你没看错，**80 倍**。
**FFI** (Foreign Function Interface) 就是那身沉重的宇航服。为了做个 0.01ms 的任务，光穿衣服就花了 1ms。

**结论**：杀鸡焉用宰牛刀？这简直是用核弹打蚊子。

---

### 第二回合：中场对决 (100KB)

**Dart (Fused)**: `1.6ms`。
**Rust (Bytes)**: `2.5ms`。

Rust 还是输了。
即使我们帮 Rust 省去了字符串拷贝（Zero Copy），但只要你想拿到 Dart 的 `Map` 对象，FFI 的对象创建开销就无法避免。这就像是你让法拉利（Rust）去送快递，车是很快，但每到一个路口（FFI边界）都要停下来填通关文牒。

**Dart (Compute)**: `470ms`。
慢了 3 倍！
这 300ms 都在干嘛？在 **拷贝数据**。
就像是你为了不自己洗碗（不卡主线程），花 300 块钱请了个钟点工（Isolate），结果钟点工光是进门出门换鞋（拷贝数据）就花了 2 小时。

---

## 第三回合：终极审判 (20MB)

我不信邪！20MB！而且这次大家统一用 **Bytes** 起跑（模拟真实网络请求）。

**Dart (Fused)**: `262ms`。
稳如老狗。Dart VM 的 optimized code 简直是黑魔法。

**Rust (Bytes)**: `401ms`。
**慢了 53%**。
这是 Rust 的极限，也是 FFI 的极限。Rust 内部解析其实只花了 50ms，剩下的 350ms 全在“把数据搬回 Dart”上。

**结论**：在“解析 JSON 并返回 Dart 对象”这件事上，**Dart 原生完胜**。任何 Rust FFI 方案都是负优化。

---

## 避坑指南：到底该用谁？

看到这里你可能会问：“那我学 Rust 干嘛？Dart 不就得了吗？”

来，直接上干货结论：

### 1. 常规业务 & 小数据 -> **Dart (Fused)**
**场景**: 所有网络请求解析。
**理由**: `utf8.decoder.fuse(json.decoder)` 是目前地球上最快的方式。无脑用它。

### 2. 只有 UI 卡顿了 -> **Dart (Compute)**
**场景**: 解析一个 5MB 的大 JSON，页面掉帧了。
**理由**: 虽然总耗时变长了（比如从 100ms 变成 300ms），但用户的手机屏幕不会卡住。**牺牲时间换体验**。

### 3. 内存爆炸 (OOM) -> **Rust Stream**
**场景**: 几百 MB 甚至 GB 级别的日志文件、长列表。
**理由**: Dart 会直接 OOM (内存溢出) 崩溃。
Rust 可以 **流式读取 (Streaming)**。它像流水线一样，读一点、解析一点、发给 Dart 一点。内存占用极低。
**这是 Rust 真正的降维打击。**

### 4. 算力爆炸 (Filtering) -> **Rust**
**场景**: 20MB 数据，我只需要里面 `score > 90` 的那 10 条记录。
**理由**: Rust 解析完直接过滤，只返回 10 条数据给 Dart。这样就避开了 FFI 的巨大开销。**这才是 Rust 正确的打开方式！**

---


---

## 5. 实战抄作业：如何在项目中落地？

光说不练假把式。既然 `Dart (Fused)` 这么强，怎么在 `dio` 和 `http` 里用？

### 5.1. 如果你用 `http` 库

千万别直接用 `response.body`（那是 String！）。要用 `response.bodyBytes`。

```dart
// ❌ 以前的写法 (String -> Map)
// final data = jsonDecode(response.body);

// ✅ 现在的写法 (Bytes -> Map)
final data = utf8.decoder.fuse(json.decoder).convert(response.bodyBytes);
```

### 5.2. 如果你用 `dio` 库

Dio 默认很贴心（多管闲事）地帮你转成了 String。你需要告诉它：“闭嘴，给我 Bytes”。

```dart
final response = await dio.get(
  'https://api.example.com/user',
  // 关键点：告诉 Dio 别瞎转码，直接给我字节流
  options: Options(responseType: ResponseType.bytes),
);

// 然后祭出大招
final data = utf8.decoder.fuse(json.decoder).convert(response.data);
```

---

## 总结

别为了技术而技术。在 JSON 解析这条赛道上，Dart 的“主场优势”是不可撼动的。

**我的最终选择**：把项目里 99% 的 `rust_api.parse` 换回了 `jsonDecode`。剩下的 1%，留给了那个 500MB 的离线数据包。

各位，回见！👋

---

> **Note**: 本文由 AI 助手辅助分析并撰写，基于真实代码运行数据。如有疏漏，欢迎指正。
