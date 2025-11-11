# Tool Node

Tool Node 是一个工具管理节点，支持以下功能：

- **工具注册与管理**：支持 MCP（Model Context Protocol）工具（SSE/STDIO）和本地工具的注册、执行和销毁
- **函数调用集成**：可作为 Chat Node 的 Function Call 基础函数，也可独立执行
- **自定义扩展**：支持用户自定义本地函数并注册到 Tool Node 中

## 注册工具

### 注册本地工具

本地工具开发规范请参考`本地工具开发规范`。

```c++
tool_node::tool_node::add_function_call<search_news_tool>(
    R"({"type":"function","function":{"name":"search_news","description":"搜索最新新闻信息","parameters":{"type":"object","properties":{"query":{"type":"string","description":"搜索关键词","minLength":1},"time_range":{"type":"string","enum":["day","week"]},"country":{"type":"string","enum":["china","usa","japan"]}},"required":["query"]}}})"
);
```

### 注册 MCP 工具

```c++
const auto r1 = tool_node::tool_node::add_server(
    R"({"WeatherServer":{"url":"http://18.119.131.41:8006","sse_endpoint":"/sse"}})"
);
```

## 获取工具状态（仅适用于 MCP 工具）

获取 MCP 工具初始化状态的函数如下：

```c++
int status = tool_node::tool_node::get_server_init_status(std::string(name));
```

**参数说明：**
- `name`：工具的唯一标识名称（严格区分大小写）

**返回值：**
- `1`：初始化成功
- `2`：初始化失败
- `0`：初始化进行中
- `-1`：未知状态

## 关闭工具（仅适用于 MCP 工具）

关闭所有 MCP 工具的函数如下：

```c++
tool_node::tool_node::shutdown_all_servers();
```

## 执行工具

### 通过 Chat Node 自动调用

工具可作为 Chat Node 的 Function Call 函数，由模型自动判断并调用。通过以下配置，Chat Node 将具备工具调用能力：

```c++
chat_node::chat_node_settings s;
s.model = "gpt-4o-mini";
s.temperature = 0.7;
s.max_tokens = 4096;
s.tool_choice = "auto";  // 启用自动工具选择
s.tools_json = tool_node::tool_node::get_all_tools_json();  // 获取所有已注册工具
const auto node = std::make_shared<chat_node::EchoChatNode<std::string, std::string>>(s);
```

### 手动调用指定工具

通过以下方式手动执行指定工具：

```c++
std::string ws_out = tool_node::tool_node::call_tool("search_web2", ws_in_json.dump());
```

### 工具输入格式

工具的输入参数严格按照 OpenAI Chat Completion API 的 Function Call 参数格式，以 `std::string` 类型传入。输入为 JSON 格式的参数字符串：

```json
{
  "query": "搜索关键词",
  "time_range": "day",
  "country": "china"
}
```

**示例代码：**

```c++
nlohmann::json params;
params["query"] = "最新科技新闻";
params["time_range"] = "day";
params["country"] = "china";
std::string arguments = params.dump();

std::string result = tool_node::tool_node::call_tool("search_news", arguments);
```

本地工具开发规范请参考`本地工具开发规范`。

### 工具输出格式

工具的输出结果严格按照 OpenAI Chat Completion API 的 Function Call 响应格式，以 `std::string` 类型返回。输出为 JSON 格式：

```json
{
  "content": [
    {
      "type": "text",
      "text": "工具执行结果内容"
    }
  ],
  "isError": false
}
```

**字段说明：**
- `content`：结果内容数组，每个元素包含 `type` 和 `text` 字段
- `isError`：布尔值，表示是否发生错误

**示例代码：**

```c++
std::string result = tool_node::tool_node::call_tool("search_news", arguments);
nlohmann::json result_json = nlohmann::json::parse(result);

if (!result_json["isError"].get<bool>()) {
    std::string text = result_json["content"][0]["text"].get<std::string>();
    // 处理结果
}
```

本地工具开发规范请参考`本地工具开发规范`。

