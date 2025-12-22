# Normal Agent Development Example

## Overview

The normal agent demonstrates how to use HADK's sequential workflow with context compression to implement a three-stage question-answering system. This example implements an agent that compresses conversation context, generates responses using LLM with tool support, and then polishes the final answer. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/normal_agent?ref_type=heads)

**Workflow Diagram:**
```
Input → ce_node (Context Compression) → generate_node (Generate Response) → polish_node (Polish Response) → Output
```

**Core Features:**
- Context compression: Automatically compresses conversation history when it exceeds the limit using SUMMARIZING strategy
- Tool support: Generate node can use tools (e.g., search_web2) to gather information
- Response polishing: Final polish node refines the generated response for better quality
- Sequential workflow: Linear flow through three specialized nodes

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

The `normal_agent` project consists of:
- **Library**: `normal_agent` (shared library containing `koba_agent` implementation)
- **Executable**: `normal_agent_app` (application layer)
