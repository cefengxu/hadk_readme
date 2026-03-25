# Chat Node

Chat Node is a node component that integrates large language models (LLM) and function calling capabilities, supporting both online and offline model invocation. Its interface strictly follows the OpenAI Chat Completion API specification.

## Building a Chat Node

Build a chat node in the following way, allowing parameter configuration for model invocation:

```c++
chat_node::chat_node_settings s_generate = chat_node_default_settings();
s_generate.llm_provider = lm_mode::OpenAI;  //default
s_generate.llm_url = "http://3rd/api/chat";
s_generate.llm_key = "3rdkey"; 
s_generate.model = "gpt-4.1";
s_generate.temperature = 0.7;
s_generate.top_p = 0.95;
s_generate.max_tokens = 4096;
s_generate.tool_choice = "none";
const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
```
Currently, two LLM Modes are supported, allowing you to use a local Ollama model via:

```c++
chat_node::chat_node_settings s_generate = chat_node_default_settings();
s_generate.llm_mode = lm_mode::Ollama;
s_generate.model = "qwen3-vl:4b"; // model to use
s_generate.llm_url = "http://127.0.0.1:11434/api/chat";
s_generate.llm_key = "";
s_generate.temperature = 0.7;
s_generate.top_p = 0.95;
s_generate.max_tokens = 4096;
s_generate.tool_choice = "none";
const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
```
Otherwise , you can configure the following environment variables for LLM Model:

```bash
export LLM_API_URL="https://xxx/v1/chat/completions"
export LLM_API_KEY="sk-zkxxxa5944"
```

## chat_node_settings Reference

All Chat Node instances are configured through `chat_node::chat_node_settings`. Start from `chat_node_default_settings()` and override the fields you need. A typical full configuration looks like this:

```c++
chat_node::chat_node_settings settings = chat_node_default_settings();
settings.llm_provider = lm_mode::OpenAI;
// settings.llm_url = "https://api.xxx.com/v1/chat/completions";
// settings.llm_key = "sk-xx";
settings.model = "gemini-3.1-flash-lite-preview";
settings.temperature = 0.7;
settings.top_p = 0.95;
settings.max_tokens = 8096;
settings.tool_choice = "auto";
settings.tools_json = cached_tools_json.c_str();  // OpenAI-style tools JSON (see tool calling docs)
settings.enable_tools = false;
settings.max_consecutive_tool_calls = 20;
settings.node_name = "decide_node";
const auto node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(settings);
```

| Field | Description |
| ----- | ----------- |
| `llm_provider` | LLM backend mode, e.g. `lm_mode::OpenAI` (default) or `lm_mode::Ollama` as shown in the examples above. |
| `llm_url` | HTTP endpoint for chat completions. Can be omitted when using `LLM_API_URL` / defaults. |
| `llm_key` | API key for the provider. Can be omitted when using `LLM_API_KEY` or providers that do not require a key. |
| `model` | Model identifier string accepted by the configured endpoint. |
| `temperature` | Sampling temperature for the model. |
| `top_p` | Nucleus sampling parameter. |
| `max_tokens` | Upper bound on tokens generated in the completion. |
| `tool_choice` | Tool-calling policy string in OpenAI style (e.g. `"none"`, `"auto"`, or a specific tool selection). |
| `tools_json` | C string pointer to the JSON definition of tools (schemas / function list). Meaningful when `enable_tools` is true. |
| `enable_tools` |When set to `true`, the Chat Node is allowed to invoke tools based on `tools_json` and `tool_choice`. When set to `false`, the LLM’s response will be returned directly without any tool invocation. |
| `max_consecutive_tool_calls` | Maximum number of consecutive tool-call rounds in Chat Node execution (safety cap). |
| `node_name` | Logical name for Chat Node ( tracing via Telemetry). |

## Chat Node Input and Output

The default data type for both input and output is `std::string` (for custom data types, please refer to `Advanced Usage`).

### Input Format

The input data structure strictly follows the OpenAI Chat Completion API specification, with the following format:

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"}
]
```

It also supports multimodal input (if the model supports it):

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

Alternatively, images can be represented in base64 format:

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

### Output Format

The output data structure strictly follows the OpenAI Chat Completion API specification, with the following format:

```json
[
  {"role":"system","content":"you are a helpful assistant"},
  {"role":"user","content":"who are you?"},
  {"role":"assistant","content":"my name is bob."}
]
```

