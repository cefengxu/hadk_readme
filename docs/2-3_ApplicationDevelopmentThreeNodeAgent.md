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
#include "src/reflector_agent/koba_agent.h"

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
        "query": {
          "type": "string",
          "description": "Search query"
        }
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
#include "src/reflector_agent/koba_agent.h"

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
#include "src/reflector_agent/koba_agent.h"

int status = get_tools_init_status("WeatherServer");
```

### 4. koba_agent()

Core agent function that processes user queries through an iterative decision-making and search workflow.

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
  {
    "role": "user",
    "content": "What is the capital of France?"
  }
]
```

**Example:**
```c++
#include "src/reflector_agent/koba_agent.h"
#include <nlohmann/json.hpp>

nlohmann::json inputJson = nlohmann::json::array({
    {{"role", "user"}, {"content", "What is the capital of France?"}}
});

const char* response = koba_agent(inputJson.dump().c_str());
```

**Workflow Details:**

The agent implements a three-node workflow with conditional routing and loops:

1. **Decide Node (Decision Node)**: Analyzes context and decides next action
   - Model: `gpt-4o-mini`
   - Temperature: `0.7`
   - Top-p: `0.95`
   - Max tokens: `2048`
   - Tool choice: `none`
   - Output format: YAML with fields `thinking`, `action`, `reason`, `search_query`/`answer`
   - Preprocessor: Builds decision prompt with question, previous research context, and current time
   - Postprocessor: Parses YAML response and routes to search or answer based on action

2. **Web Search Node (Tool Node)**: Executes web search using `search_web2` tool
   - Uses `ToolNode` for structured tool invocation
   - Preprocessor: Converts search query to tool input format
   - Postprocessor: Extracts search results (title, URL, snippet) and accumulates context
   - Automatically routes back to decide_node after search completion

3. **Answer Node**: Generates final answer based on accumulated research
   - Model: `gpt-4o-mini`
   - Temperature: `0.7`
   - Top-p: `0.95`
   - Max tokens: `4096`
   - Tool choice: `none`
   - Preprocessor: Converts input to Chat Completion format

**Node Connection:**
- Conditional routing: `decide_node` routes to `web_search_node` (route: "search") or `answer_node` (route: "answer")
- Loop: `web_search_node` routes back to `decide_node` (route: "decide")
- Flow: `decide_node` → (conditional) → `web_search_node` → `decide_node` (loop) OR `answer_node` → output

**Key Implementation Details:**
- Uses YAML parsing to extract decision information from decide node output
- Context accumulation: Each search result is appended to global context
- State management: Uses global variables to track question, context, and YAML node

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
#include "src/reflector_agent/koba_agent.h"

close_tools();
```

## Usage Example

```c++
#include "src/reflector_agent/koba_agent.h"
#include <nlohmann/json.hpp>
#include <iostream>

int main() {
    // Initialize tools
    bool reg_loc_tools = init_loc_tools();
    bool reg_mcp_tools = init_mcp_tools(R"({"WeatherServer":{"url":"http://18.119.131.41:8006/sse"}})");
    
    // Build input message
    nlohmann::json inputJson = nlohmann::json::array({
        {{"role", "user"}, {"content", "What is the capital of France?"}}
    });
    
    // Call agent
    const char* response = koba_agent(inputJson.dump().c_str());
    
    // Parse and display response
    nlohmann::json responseJson = nlohmann::json::parse(response);
    std::cout << responseJson.back()["content"].get<std::string>() << std::endl;
    
    // Clean up
    close_tools();
    
    return 0;
}
```

## Key Points

1. **Conditional Routing**: Use the `route` function to dynamically select the next node based on node output
2. **Loop Workflow**: Routing can implement loops between nodes, supporting iterative search
3. **Context Management**: Use global variables or state objects to manage context information in workflows
4. **YAML Parsing**: Decision node returns YAML format, needs to be parsed to extract action type and parameters
5. **Tool Invocation**: Use `ToolNode` to invoke tools with structured preprocessor and postprocessor functions
6. **ToolNode vs OneFuncNode**: `ToolNode` provides a more structured way to call tools, with automatic handling of tool invocation format, while `OneFuncNode` requires manual tool invocation using `call_tool`
