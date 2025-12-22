# Batch Node Agent Development Example

## Overview

This example demonstrates how to use HADK `BatchFuncNode` to build a simple batch processing flow, where multiple text inputs are generated, processed in batch, and then routed to the next node. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/batch_flow?ref_type=heads)

**Workflow Diagram:**
```
Input → create_node (Generate Batch) → batch_node (Batch Processing) → summarize_node (Summarize) → Output
```

**Core Features:**
- Batch processing: Uses `BatchFuncNode` to process multiple inputs in parallel
- Vector transformation: Converts single input to vector of strings for batch processing
- Sequential workflow: Linear flow through create, batch, and summarize nodes
- Routing support: Uses routing values to connect nodes in the flow

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

The `batch_flow` project consists of:
- **Library**: `batch_flow` (shared library containing `koba_agent` implementation)
- **Executable**: `batch_flow_app` (application layer)
