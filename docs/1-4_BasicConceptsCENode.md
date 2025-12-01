# CE Node

CE Node (Context Engine Node) is a context engine node component for managing and compressing conversation history. It supports two context management strategies: Trimming and Summarizing, which effectively control conversation history length and avoid exceeding model context window limits.

## Building a CE Node

Build a CE node as follows, allowing configuration of context management strategy and related parameters:

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::SUMMARIZING;
s_ce.context_limit = 3; // Compression trigger threshold, number of history turns
s_ce.keep_last_n_turns = 1; // Number of recent original message turns to keep
s_ce.tool_trim_limit = 600; // Tool results are not very important in history messages, so the first 600 characters of tool results will be kept
s_ce.summarizer_model = "gpt-4o-mini";
s_ce.summarizer_max_tokens = 400;
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

## Context Management Strategies

CE Node supports two context management strategies:

### TRIMMING Strategy

The trimming strategy directly deletes history messages that exceed the limit, keeping the most recent `max_turns` conversation turns.

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::TRIMMING;
s_ce.max_turns = 3; // Maximum number of history turns to keep
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

### SUMMARIZING Strategy

The summarizing strategy uses LLM to compress old history messages into summaries, keeping the most recent `keep_last_n_turns` original message turns. When the number of history turns exceeds `context_limit`, summarization compression is triggered.

```c++
ce_node::ce_node_settings s_ce;
s_ce.strategy = ContextStrategy::SUMMARIZING;
s_ce.context_limit = 3; // Compression trigger threshold, number of history turns
s_ce.keep_last_n_turns = 1; // Number of recent original message turns to keep
s_ce.tool_trim_limit = 600; // Number of characters to keep for tool results
s_ce.summarizer_model = "gpt-4o-mini";
s_ce.summarizer_max_tokens = 400;
const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

## Configuration Parameters

### Common Parameters

- `strategy`: Context management strategy, options are `ContextStrategy::TRIMMING` or `ContextStrategy::SUMMARIZING`, default is `SUMMARIZING`

### TRIMMING Strategy Parameters

- `max_turns`: Maximum number of history turns to keep, default is 8

### SUMMARIZING Strategy Parameters

- `context_limit`: Compression trigger threshold, triggers summarization compression when history turns exceed this value, default is 5
- `keep_last_n_turns`: Number of recent original message turns to keep, these messages won't be compressed, default is 2
- `tool_trim_limit`: Number of characters to keep for tool results in history messages, default is 600
- `summarizer_model`: Model name for summarization, default is "gpt-4o-mini"
- `summarizer_max_tokens`: Maximum tokens for summarizer model, default is 400
- `summarizer_tools_json`: Tool configuration for summarizer (JSON string), default is "[]"
- `summarizer_tool_choice`: Tool selection strategy for summarizer, default is "none"

## CE Node Input and Output

The default data type is `std::string` (for custom data types, please refer to `Advanced Usage`).

### Input Format

Input data format strictly follows the OpenAI Chat Completion API specification, format as follows:

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"},
  {"role":"assistant","content":"my name is bob."},
  {"role":"user","content":"what can you do?"}
]
```

### Output Format

Output data format also follows the OpenAI Chat Completion API specification. Depending on the configured strategy, output may be:

- **TRIMMING Strategy**: Keeps the most recent `max_turns` original message turns
- **SUMMARIZING Strategy**: Compresses old messages beyond `keep_last_n_turns` into summaries, keeping the most recent `keep_last_n_turns` original message turns

Output format example:

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"assistant","content":"[Summary of previous conversation]"},
  {"role":"user","content":"what can you do?"}
]
```
