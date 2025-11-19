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
const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
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

同时，也支持输入多模态的信息（如果模型支持的话）：

```json
[
    {
        "content": "You are a helpful assistant with multiple tools.",
        "role": "system"
    },
    {
        "content": [
            {
                "text": "what is this?",
                "type": "text"
            },
            {
                "image_url": {
                    "detail": "low",
                    "url": "https://1.bp.blogspot.com/529.jpg"
                },
                "type": "image_url"
            }
        ],
        "role": "user"
    }
]
```
亦可，基于base64格式表示图片内容：
```json
[
    {
        "content": "You are a helpful assistant with multiple tools.",
        "role": "system"
    },
    {
        "content": [
            {
                "text": "what is this?",
                "type": "text"
            },
            {
                "image_url": {
                    "detail": "low",
                    "url": "data:image/png;base64,dfadfnakjenqlkmdcklasjdflkadslfkadsokfqmldf"
                },
                "type": "image_url"
            }
        ],
        "role": "user"
    }
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