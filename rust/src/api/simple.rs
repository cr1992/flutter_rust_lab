use serde_json::Value;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

pub fn hello(a: String) -> String {
    a.repeat(2)
}

/// 通用的动态值结构，支持在 Dart 侧进行结构化访问
#[derive(Debug, Clone)]
pub enum DynamicValue {
    Null,
    Bool(bool),
    Number(f64),
    String(String),
    List(Vec<DynamicValue>),
    Map(Vec<(String, DynamicValue)>),
}

/// 将 serde_json::Value 递归映射为 DynamicValue
fn map_value(value: Value) -> DynamicValue {
    match value {
        Value::Null => DynamicValue::Null,
        Value::Bool(b) => DynamicValue::Bool(b),
        Value::Number(n) => DynamicValue::Number(n.as_f64().unwrap_or(0.0)),
        Value::String(s) => DynamicValue::String(s),
        Value::Array(arr) => DynamicValue::List(arr.into_iter().map(map_value).collect()),
        Value::Object(obj) => {
            DynamicValue::Map(obj.into_iter().map(|(k, v)| (k, map_value(v))).collect())
        }
    }
}

// 在 Rust 侧实现的通用 JSON 解码
pub fn quick_json_decode(json_str: String) -> DynamicValue {
    // 核心解析步骤：利用 serde_json 的高性能
    let value: Value = serde_json::from_str(&json_str).unwrap_or(Value::Null);
    // 转换为 FRB 可识别的通用结构 (这一步非常耗时，因为涉及大量内存分配)
    map_value(value)
}

// 纯解析测试：不涉及复杂数据结构的跨语言传输
// 仅用于测量 Rust 侧本地解析 JSON 的原生速度
pub fn pure_json_parse(json_str: String) {
    let _value: Value = serde_json::from_str(&json_str).unwrap_or(Value::Null);
}

// 零拷贝解析测试：直接接收二进制数据，避免 UTF-8 校验和字符串转换开销
// 这模拟了从网络或文件直接读取数据给 Rust 处理的最佳实践
pub fn pure_json_parse_bytes(bytes: Vec<u8>) {
    let _value: Value = serde_json::from_slice(&bytes).unwrap_or(Value::Null);
}

// -------------------------------------------------------------------------
// Struct 解析测试：模拟具体的业务对象解析
// -------------------------------------------------------------------------

#[derive(Debug, Clone, serde::Deserialize)]
pub struct SimpleUser {
    pub id: i32,
    pub name: String,
    pub email: String,
}

// 强类型解析：直接解析为具体的 Rust 结构体，避免 DynamicValue 的中间映射开销
pub fn parse_user_struct(json_str: String) -> SimpleUser {
    serde_json::from_str(&json_str).unwrap_or(SimpleUser {
        id: 0,
        name: "Unknown".into(),
        email: "unknown@example.com".into(),
    })
}

// -------------------------------------------------------------------------
// Stream 解析测试：彻底解决大文件 OOM 问题
// -------------------------------------------------------------------------

// 流式解析：从 Bytes 中逐个解析对象并通过 StreamSink 发送给 Dart
// 优势：
// 1. 内存占用极低：无论 JSON 多大，内存中只保留当前解析的一个对象
// 2. 首屏极快：解析出第一个对象立刻发送，Dart 端可以立即渲染
pub fn parse_user_stream(sink: crate::frb_generated::StreamSink<SimpleUser>, json_bytes: Vec<u8>) {
    // 假设输入是一个 JSON 数组 [...]
    // 使用 serde_json 的流式迭代器
    let stream = serde_json::Deserializer::from_slice(&json_bytes).into_iter::<SimpleUser>();

    for value in stream {
        if let Ok(user) = value {
            // 将解析出的对象发送给 Dart
            // 如果 Dart 端取消了订阅，这里会返回 false，我们可以停止解析
            if sink.add(user).is_err() {
                break;
            }
        }
    }
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
