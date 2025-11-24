# CE Node

CE Node（Context Engine Node）是一个上下文引擎节点组件，用于管理和压缩对话历史记录。它支持两种上下文管理策略：裁剪（Trimming）和摘要（Summarizing），可以有效控制对话历史的长度，避免超出模型的上下文窗口限制。

## Building a CE Node

构建一个 CE 节点的方式如下，允许配置上下文管理策略和相关参数：

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::SUMMARIZING;
s_ce.context_limit = 3; // 触发压缩阈值，历史记录轮数
s_ce.keep_last_n_turns = 1; // 保留最近原始消息轮数
s_ce.tool_trim_limit = 600; // 工具结果在历史消息中不是很重要，所以工具结果的前600个字符会保留
s_ce.summarizer_model = "gpt-4o-mini";
s_ce.summarizer_max_tokens = 400;
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

## Context Management Strategies

CE Node 支持两种上下文管理策略：

### TRIMMING Strategy

裁剪策略直接删除超出限制的历史消息，保留最近的 `max_turns` 轮对话。

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::TRIMMING;
s_ce.max_turns = 3; // 历史记录最大保留轮数
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

### SUMMARIZING Strategy

摘要策略使用 LLM 将旧的历史消息压缩为摘要，保留最近 `keep_last_n_turns` 轮的原始消息。当历史记录轮数超过 `context_limit` 时，会触发摘要压缩。

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::SUMMARIZING;
s_ce.context_limit = 3; // 触发压缩阈值，历史记录轮数
s_ce.keep_last_n_turns = 1; // 保留最近原始消息轮数
s_ce.tool_trim_limit = 600; // 工具结果保留的字符数
s_ce.summarizer_model = "gpt-4o-mini";
s_ce.summarizer_max_tokens = 400;
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

## Configuration Parameters

### Common Parameters

- `strategy`: 上下文管理策略，可选值为 `ContextStrategy::TRIMMING` 或 `ContextStrategy::SUMMARIZING`，默认为 `SUMMARIZING`

### TRIMMING Strategy Parameters

- `max_turns`: 历史记录最大保留轮数，默认为 8

### SUMMARIZING Strategy Parameters

- `context_limit`: 触发压缩阈值，当历史记录轮数超过此值时触发摘要压缩，默认为 5
- `keep_last_n_turns`: 保留最近原始消息轮数，这些消息不会被压缩，默认为 2
- `tool_trim_limit`: 工具结果在历史消息中保留的字符数，默认为 600
- `summarizer_model`: 用于摘要的模型名称，默认为 "gpt-4o-mini"
- `summarizer_max_tokens`: 摘要模型的最大 token 数，默认为 400
- `summarizer_tools_json`: 摘要器的工具配置（JSON 字符串），默认为 "[]"
- `summarizer_tool_choice`: 摘要器的工具选择策略，默认为 "none"

## CE Node Input and Output

默认的数据类型为 `std::string`（自定义数据类型请参考 `Advanced Usage`）。

### Input Format

输入数据格式严格遵循 OpenAI Chat Completion API 规范，格式如下：

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"},
  {"role":"assistant","content":"my name is bob."},
  {"role":"user","content":"what can you do?"}
]
```

### Output Format

输出数据格式同样遵循 OpenAI Chat Completion API 规范。根据配置的策略，输出可能是：

- **TRIMMING 策略**：保留最近 `max_turns` 轮对话的原始消息
- **SUMMARIZING 策略**：将超出 `keep_last_n_turns` 的旧消息压缩为摘要，保留最近 `keep_last_n_turns` 轮的原始消息

输出格式示例：

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"assistant","content":"[Summary of previous conversation]"},
  {"role":"user","content":"what can you do?"}
]
```

