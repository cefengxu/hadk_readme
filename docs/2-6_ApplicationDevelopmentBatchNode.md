# Batch Node Agent Development Example

## Overview

This example demonstrates how to use HADK `BatchFuncNode` to build a simple batch processing flow, where multiple text inputs are generated, processed in batch, and then routed to the next node.

## Environment Configuration

Before using the agent or LLM-based tools, configure the following environment variables:

```bash
export LLM_API_URL="https://xxx/v1/chat/completions"
export LLM_API_KEY="sk-zkxxxa5944"
export TAVILY_API_URL="https://api.tavily.com/search"
export TAVILY_API_KEY="tvly-dev-DPxxxwkFxVHPIf4D"
```

## API Functions

### 1. init_loc_tools()

Initialize and register local tools.

**Function Signature:**
```c++
bool init_loc_tools();
```

**Description:**
- Registers local tools (e.g., `search_web2` for web search)
- Returns `true` on success, `false` on failure

**Example:**
```c++
#include "src/batch_flow/koba_agent.h"

bool reg_loc_tools = init_loc_tools();
```

**Note:**
The function internally registers tools using the OpenAI Function Call format. The simplest function call format example:

```json
{
  "type": "function",
  "function": {
    "name": "search_web2",
    "description": "Search the web",
    "parameters": {
      "type": "object",
      "properties": {
        "query": { "type": "string", "description": "Search query" }
      },
      "required": ["query"]
    }
  }
}
```

### 2. init_mcp_tools()

Initialize and register MCP (Model Context Protocol) tools by connecting to remote tool servers.

**Function Signature:**
```c++
bool init_mcp_tools(const char* params);
```

**Parameters:**
- `params`: JSON string containing server configuration. Format: `{"ServerName":{"url":"http://host:port/sse"}}`

**Description:**
- Registers remote MCP tool servers
- Waits 10 seconds for server initialization
- Returns `true` on success, `false` on failure

**Example:**
```c++
#include "src/batch_flow/koba_agent.h"

bool reg_mcp_tools = init_mcp_tools(R"({"WeatherServer":{"url":"http://18.119.131.41:8006/sse"}})");
```

### 3. get_tools_init_status()

Get the initialization status of a specific tool server.

**Function Signature:**
```c++
int get_tools_init_status(const char* name);
```

**Parameters:**
- `name`: Name of the tool server

**Return Value:**
- Returns initialization status code (0 for success, -1 for error or not found)

**Example:**
```c++
#include "src/batch_flow/koba_agent.h"

int status = get_tools_init_status("WeatherServer");
```

### 4. koba_agent()

Core agent function that constructs a batch flow, runs it, and returns the final result.

**Function Signature:**
```c++
const char* koba_agent(const char* message);
```

**Parameters:**
- `message`: JSON string in OpenAI Chat Completion format (array of message objects). In the current demo implementation, the content is not used by the batch flow logic.

**Return Value:**
- Returns a C-style string containing the final result of the flow

**Message Format:**
The input message should be a JSON array following OpenAI Chat Completion format, for example:

```json
[
  {
    "role": "user",
    "content": "Run a batch demo."
  }
]
```

**Batch Flow Configuration (Demo):**
- `create_node`: `OneFuncNode<std::string, std::vector<std::string>>`
  - Input: a single string
  - Output: a vector of strings, e.g. `["I love Lenovo", "I love work", "I love life"]`
  - Routed with action `"batch"`
- `batch_node`: `BatchFuncNode<std::string, std::string>`
  - Input: each string from the vector
  - Output: processed string, e.g. `"I love Lenovo Stop lying."`
  - Routed with action `"summarize"`

The current demo implementation returns a fixed string `"hello world"` after running the flow, which can be replaced with real business logic as needed.

**Environment Variables:**
When `koba_agent` is extended to call LLM or tools, the following environment variables must be set:
- `LLM_API_URL`: LLM API endpoint URL  
- `LLM_API_KEY`: LLM API key  
- `TAVILY_API_URL`: Tavily search API endpoint URL  
- `TAVILY_API_KEY`: Tavily API key  

### 5. close_tools()

Close all registered tool servers and clean up resources.

**Function Signature:**
```c++
void close_tools();
```

**Description:**
- Shuts down all MCP tool servers
- Should be called before program exit

**Example:**
```c++
#include "src/batch_flow/koba_agent.h"

close_tools();
```
