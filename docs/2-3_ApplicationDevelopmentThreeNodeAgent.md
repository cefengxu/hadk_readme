# Conditional Routing Agent Development Example

## Overview

The conditional routing agent demonstrates how to use HADK's conditional routing (`route`) functionality to implement complex workflows. This example implements a research assistant agent that can dynamically decide whether to continue searching for information or directly answer questions based on the current context, supporting iterative searches until sufficient information is obtained. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/reflector_agent?ref_type=heads)

**Workflow Diagram:**
```
Input → decide_node (Decision) → [Conditional Routing]
                                  ├─ "search" → web_search_node (Web Search) → decide_node (Loop)
                                  └─ "answer" → answer_node (Generate Answer) → Output
```

**Core Features:**
- Conditional routing: Dynamically select the next node based on the decision node's output
- Loop workflow: Supports looping between decision node and search node until sufficient information is obtained
- Context accumulation: Each search result accumulates into the context for subsequent decisions

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

The `reflector_agent` project consists of:
- **Library**: `reflector_agent` (shared library containing `koba_agent` implementation)
- **Executable**: `reflector_agent_app` (application layer)
