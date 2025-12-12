# Chat Node

Chat Node is a node component that integrates large language models (LLM) and function calling capabilities, supporting both online and offline model invocation. Its interface strictly follows the OpenAI Chat Completion API specification.

## Building a Chat Node

Build a chat node in the following way, allowing parameter configuration for model invocation:

```c++
chat_node::chat_node_settings s_generate;
s_generate.llm_mode = chat_node::LLMMode::OpenAI;  //default
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
chat_node::chat_node_settings s_generate;
s_generate.llm_mode = chat_node::LLMMode::Ollama;
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

