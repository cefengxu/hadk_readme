# Single Node Agent Development With Runner (Class-based with Runner)

## Overview

This module is a class-based refactoring of [single_node](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/single_node?ref_type=heads), converting the original function-based implementation into an object-oriented class format using the Runner pattern. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/single_node_cls?ref_type=heads)

In this example, we construct a single Chat Node from HADK to materialize an Agent that can understand or invoke functions automatically according to user's query. This example implements an agent that generates responses using LLM with tool support in a single node workflow.

**Workflow Diagram:**
```
Input → generate_node (Generate Response) → Output
```

The key difference from `single_node` is that this implementation uses:

- **Class-based architecture**: The agent logic is encapsulated in a `KobaAgentTask` class that inherits from `hybrid_runner::task_base`
- **Runner pattern**: Uses the Runner framework (`runner_init`, `runner_run`, `runner_release`) for task management and execution
- **Structured history format**: Supports the new conversation history format `[[S],[U,A],[U,A,T,A]]` where each inner array represents a complete conversation turn

## Environment Configuration

Before using the agent, you need to configure the following environment variables:

```bash
export LLM_API_URL="https://xxx/v1/chat/completions"
export LLM_API_KEY="sk-zkxxxa5944"
export TAVILY_API_URL="https://api.tavily.com/search"
export TAVILY_API_KEY="tvly-dev-DPxxxwkFxVHPIf4D"
```

Or configure directly in code:

```cpp
chat_node::chat_node_settings model_setting;
model_setting.llm_url = "https://api.xxx.com/v1/chat/completions";
model_setting.llm_key = "sk-you-key";
```

## Tool Initialization

Before using the agent, you need to initialize the tools.

**Available Tools:**
- `search_web2`: Web search tool that supports filtering by country (enum: "china", "germany", "italy", "united kingdom", "united states")


### C API Interface

The module provides a C API interface for easy integration:

- `koba_agent_init()`: Initialize the agent and return a key for subsequent operations
  ```cpp
  const char* key = koba_agent_init();
  if (!key) {
      // handle initialization error
  }
  ```

- `get_koba_agent_result(key, history, input)`: Execute the agent with conversation history and current query
  ```cpp
  const char* response = get_koba_agent_result(key, history.dump().c_str(), "what is the weather in beijing ?");
  ```
  - `key`: The key returned from `koba_agent_init()`
  - `history`: The conversation history in JSON format `[[S],[U,A],[U,A,T,A]]`
  - `input`: The current user query string

- `koba_agent_cleanup(key)`: Clean up and release the agent instance
  ```cpp
  koba_agent_cleanup(key);
  ```

**Note**: These C API functions internally use the Runner framework (`runner_init`, `runner_run`, `runner_release`) for task lifecycle management.

### Conversation History Format

The new structured history format groups messages by conversation turns:

- `[[S]]`: System message as the first group
- `[[S],[U,A]]`: System message followed by a user-assistant turn
- `[[S],[U,A],[U,A,T,A]]`: System message followed by multiple turns, including tool calls

Each inner array represents a complete conversation turn from start to finish.
