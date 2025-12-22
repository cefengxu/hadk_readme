# CoT Agent Development Example

## Overview

This example demonstrates how to use CoT (Chain of Thought) nodes from HADK to create an Agent that can solve complex problems through step-by-step reasoning. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/cot_agent?ref_type=heads)

**Workflow Diagram:**
```
Input → extra_node (Extract Problem) → cot_node (Chain of Thought, Loop) → polish_node (Polish Answer) → Output
```

**Core Features:**
- Chain of Thought reasoning: Uses iterative step-by-step reasoning to solve complex problems
- Loop workflow: The cot_node loops until it reaches a conclusion, then routes to polish_node
- Problem extraction: Extracts and clarifies the problem before reasoning
- Answer polishing: Refines the final answer for better quality

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

The `cot_agent` project consists of:
- **Library**: `cot_agent` (shared library containing `koba_agent` implementation)
- **Executable**: `cot_agent_app` (application layer)
