# CoT Agent Development Example

## Overview

This example demonstrates how to use CoT (Chain of Thought) nodes from HADK to create an Agent that can solve complex problems through step-by-step reasoning. [ref. link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/src/cot_agent?ref_type=heads)

## Question Ref.
- If a train travels 60 miles in 1 hour and then 90 miles in 1.5 hours, what is its average speed for the entire trip?
- Alice is older than Bob. Bob is older than Charlie. Who is the youngest?
- You flip a fair coin 3 times. What is the probability of getting exactly 2 heads?

## Environment Configuration

Before using the agent, configure the following environment variables:

```bash
export LLM_API_URL="https://xxx/v1/chat/completions"
export LLM_API_KEY="sk-zkxxxa5944"
export TAVILY_API_URL="https://api.tavily.com/search"
export TAVILY_API_KEY="tvly-dev-DPxxxwkFxVHPIf4D"
```

`LLM_API_URL` and  `LLM_API_KEY` can be configured using `chat_node::chat_node_settings`, For more details, please refer to [BasicConceptsChatNode](https://cefengxu.github.io/hadk_readme/1-1_BasicConceptsChatNode/) 

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
#include "src/cot_agent/koba_agent.h"

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
        "query": {"type": "string", "description": "Search query"}
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
#include "src/cot_agent/koba_agent.h"

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
#include "src/cot_agent/koba_agent.h"

int status = get_tools_init_status("WeatherServer");
```

### 4. koba_agent()

Core agent function that processes user queries using CoT (Chain of Thought) reasoning and returns responses.

**Function Signature:**
```c++
const char* koba_agent(const char* message);
```

**Parameters:**
- `message`: JSON string in OpenAI Chat Completion format (array of message objects)

**Return Value:**
- Returns a JSON string containing the conversation response

**Message Format:**
The input message should be a JSON array following OpenAI Chat Completion format:

```json
[
  {"role": "user", "content": "What is the weather like in San Francisco today?"}
]
```

**Example:**
```c++
#include "src/cot_agent/koba_agent.h"
#include <nlohmann/json.hpp>

nlohmann::json inputJson = nlohmann::json::array({
    {{"role", "user"}, {"content", "What is the weather like in San Francisco today?"}}
});

const char* response = koba_agent(inputJson.dump().c_str());
```

**Environment Variables:**
This function requires the following environment variables to be set:
- `LLM_API_URL`: LLM API endpoint URL
- `LLM_API_KEY`: LLM API key

**Node Configuration:**
The agent uses CoT nodes with the following configuration:
- **extra_node**: Extracts problem from input
- **cot_node**: Chain of thought node for step-by-step reasoning
  - Model: `gpt-4o-mini`
  - Temperature: `0.7`
  - Top-p: `0.95`
  - Max tokens: `4096`
  - Tool choice: `none`
- **polish_node**: Polishes final answer
  - Model: `gpt-4o-mini`
  - Temperature: `0.7`
  - Top-p: `0.95`
  - Max tokens: `2048`
  - Tool choice: `none`

**Flow:** query → extra_node → cot_node (loop) → polish_node → response

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
#include "src/cot_agent/koba_agent.h"

close_tools();
```
