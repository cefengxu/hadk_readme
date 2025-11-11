# Chat Node

Chat Node 是一个集成了大语言模型（LLM）和函数调用（Function Call）功能的节点组件，支持在线和离线模型调用。其接口严格遵循 OpenAI Chat Completion API 规范。

## 构建 Chat Node 节点

通过以下方式构建聊天节点，可对模型调用进行参数配置：

```c++
chat_node::chat_node_settings s_generate;
s_generate.model = "gpt-4.1";
s_generate.temperature = 0.7;
s_generate.top_p = 0.95;
s_generate.max_tokens = 4096;
s_generate.tool_choice = "none";
const auto generate_node = std::make_shared<chat_node::EchoChatNode<std::string, std::string>>(s_generate);
```

## Chat Node 节点的输入输出

节点的输入输出默认数据类型均为 `std::string`（自定义数据类型请参考`高级用法`）。

### 输入格式

输入数据结构严格遵循 OpenAI Chat Completion API 规范，格式如下：

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"}
]
```

### 输出格式

输出数据结构严格遵循 OpenAI Chat Completion API 规范，格式如下：

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"},
  {"role":"assistant","content":"my name is bob."}
]
```