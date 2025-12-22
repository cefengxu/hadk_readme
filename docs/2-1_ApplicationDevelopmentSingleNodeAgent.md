# Single Node Agent Development Example

## Overview

In this example, we will construct only one Chat Node from HADK to materialize an Agent that can understand or invoke functions automatically according to user's query. This is a simple agent implementation that creates a single Chat Node and Flow for each request. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/single_node?ref_type=heads)

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

## Project Structure

The `single_node` project consists of:
- **Library**: `single_node` (shared library containing `koba_agent` implementation)
- **Executable**: `single_node_app` (application layer)



### If you need a more advanced implementation with task management and Runner pattern, consider using `single_node_cls` instead.
