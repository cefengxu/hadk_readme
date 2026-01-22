# Chat Bot Development Example

## Overview

This example demonstrates how to construct a simple interactive chat bot based on Single Node Agent. The chat bot supports multi-turn conversations with automatic history management using the Runner pattern. [ref. link](https://gitlab.xpaas.lenovo.com/latc/Components/hybrid-agent-rumtime/hadk_apps/-/tree/main/src/chat_bot?ref_type=heads)

**Workflow Diagram:**
```
User Input → Chat History → koba_agent (Single Node) → Update History → Display Response → Loop
```

**Core Features:**
- Multi-turn conversations: Maintains full conversation context across turns
- Automatic history management: Tracks and updates conversation history automatically
- Runner pattern: Uses Runner framework for task management
- Interactive console: Reads user input and displays responses in real-time

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

The `chat_bot` project consists of:
- **Library**: `chat_bot` (shared library containing `koba_agent` implementation)
- **Executable**: `loop_chat_rt_app` (interactive chat bot application)
