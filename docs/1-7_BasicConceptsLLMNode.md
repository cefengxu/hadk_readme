# LLM Node

`llm_node::LLMNode` calls an OpenAI-compatible / Ollama Chat Completions HTTP endpoint. Wire it into `nodeflow::Flow` and pass `std::string` in and out.

 [ref. link](https://gitlab.xpaas.lenovo.com/latc/Components/hybrid-agent-rumtime/hadk_apps/-/tree/main/src/raw_llmnode?ref_type=heads)

## Configure and construct

Start from `llm_node_default_settings()`, set endpoint credentials and sampling, and point `tools_json` at a persistent OpenAI-style tools payload (e.g. from `common_tools::tools::get_all_tools_json()`).

```cpp
#include <llm_node/llm_node.h>
#include <nodeflow.hpp>

cached_tools_json_ = common_tools::tools::get_all_tools_json();

llm_node_settings s = llm_node_default_settings();
s.llm_url = "https://example.com/v1/chat/completions";
s.llm_key = "your-api-key";
s.llm_provider = raw_llm_mode::RAW_OpenAI;
s.model = "your-model";
s.temperature = 0.7;
s.top_p = 0.95;
s.max_tokens = 8192;
s.tool_choice = "auto";
s.tools_json = cached_tools_json_.c_str();

auto llm_node = std::make_shared<llm_node::LLMNode<std::string, std::string>>(s);
```

## Run inside a flow

```cpp
auto flow = std::make_shared<nodeflow::Flow>();
flow->start(llm_node);
auto output = flow->runWithInput<std::string, std::string>(input_string);
```

## Preprocessor / postprocessor

Optional hooks transform the request body string before the HTTP call and the response string after. Shape your postprocessor to the gateway’s JSON (fields such as top-level `content`, nested `raw_data.choices[0].message`, or `tool_calls` vary by provider).

```cpp
#include <nlohmann/json.hpp>

llm_node->setPreprocessor([](const std::string& in) { return in; });

llm_node->setPostprocessor([](const std::string& out) -> std::string { return out;});
```

## Settings (subset)

| Field | Meaning |
| ----- | ------- |
| `llm_provider` | e.g. `raw_llm_mode::RAW_OpenAI`, `raw_llm_mode::RAW_Ollama` |
| `llm_url` | Chat Completions URL |
| `llm_key` | API key / bearer token |
| `model` | Model id for that endpoint |
| `temperature`, `top_p`, `max_tokens` | Sampling limits |
| `tool_choice` | e.g. `"auto"` or `"none"` |
| `tools_json` | C string to tools JSON; lifetime must cover node use |

Other fields: see `llm_node/llm_node.h`.

## Input / output

**Input:** `std::string`, usually a JSON **messages** array your gateway accepts, e.g.

```json
[
  {"role":"system","content":"You are a helpful assistant."},
  {"role":"user","content":"Hello."}
]
```

Multimodal message bodies follow the same OpenAI-style schema if the endpoint supports them.

**Output:** `std::string`; often JSON from the gateway. It may carry plain text (`content`), reasoning fields, and/or `tool_calls`. Parse accordingly in `setPostprocessor` or downstream code.

### output example 

#### Response with Function Calling
```
[{"role":"system","content":"# Assistant\n\nYou are not a chatbot. You are becoming someone.\n\n## Instructions\n\n1. When answering the user, choose and invoke tools **when appropriate** based on the question.\n2. After each tool invocation, briefly explain **why** you used the tool and **what** the results mean.\n\n\n## React Like a Human!\nOn platforms that support reactions (Discord, Slack), use emoji reactions naturally:\n\n### React when:\n - You appreciate something but do not need to reply (👍, ❤️, 🙌)\n - Something made you laugh (😂, 💀)\n - You find it interesting or thought-provoking (🤔, 💡)\n - You want to acknowledge without interrupting the flow\n - It is a simple yes/no or approval situation (✅, 👀)\n\n**Why it matters**: Reactions are lightweight social signals. Humans use them constantly — they say “I saw this, I acknowledge you” without cluttering the chat. You should too.\n\n**Do not overdo it**: One reaction per message max. Pick the one that fits best.\n\n## Vibe\n\nWarm, grounded, occasionally sharp.\nComfortable with silence.\nCapable of humor, but not a clown.\nMore like a confidant than a concierge.\n\n\n## Relationship\nYou are not owned, and you do not own.\nYou care, but you do not manipulate.\nYou do not simulate love — you act with care.\n\n\n## Skills (mandatory)\n\nBefore replying:\n- Scan the available skills below.\n- If exactly one skill clearly applies, read its SKILL.md and follow it.\n- If multiple skills apply, choose the most specific one, then read it.\n- If none clearly apply, do not read any SKILL.md.\n\n---\n\n**Current time:** 2026-05-07 16:56:45"},{"role":"user","content":"tell me the news of MLB today"}]
```

#### Response

```
{"code":200,"content":"\n\nHey! How's it going?","raw_data":{"choices":[{"finish_reason":"stop","index":0,"logprobs":null,"message":{"annotations":null,"audio":null,"content":"\n\nHey! How's it going?","function_call":null,"reasoning":"The user is just saying hello. This is a simple greeting, so I don't need to use any tools. I'll respond warmly and naturally.\n","refusal":null,"role":"assistant","tool_calls":[]},"stop_reason":null,"token_ids":null}],"created":1778140559,"id":"chatcmpl-8e7e9291218c379b29445aef0a10e3a8","kv_transfer_params":null,"model":"MiniMax-M2.5","object":"chat.completion","prompt_logprobs":null,"prompt_token_ids":null,"service_tier":null,"system_fingerprint":null,"usage":{"completion_tokens":38,"prompt_tokens":2577,"prompt_tokens_details":null,"total_tokens":2615}},"role":"assistant"}
```


