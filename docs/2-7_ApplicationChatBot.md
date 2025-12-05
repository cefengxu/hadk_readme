# Chat Bot Development Example

## Overview

This example demonstrates how to construct a simple interactive chat bot (`loop_chat.cpp`) based on [Single Node Agent](https://cefengxu.github.io/hadk_readme/2-1_ApplicationDevelopmentSingleNodeAgent/). The chat bot supports multi-turn conversations with automatic history management.

## Environment Configuration

Before using the agent or LLM-based tools, configure the following environment variables:

```bash
export LLM_API_URL="https://xxx/v1/chat/completions"
export LLM_API_KEY="sk-zkxxxa5944"
export TAVILY_API_URL="https://api.tavily.com/search"
export TAVILY_API_KEY="tvly-dev-DPxxxwkFxVHPIf4D"
```

## Implementation Overview

The `loop_chat.cpp` example implements an interactive chat bot with the following key components:

### Chat History Management

The `KBChatHistory` structure manages conversation history:
- Automatically initializes with a system prompt that includes the current timestamp
- Maintains a JSON array of messages following OpenAI Chat Completion format
- Tracks message count to identify new messages from agent responses
- Provides methods to add user input and update from agent responses

### Main Flow

1. **Initialization**: Registers MCP tool servers (e.g., WeatherServer) and local tools
2. **Chat Loop**: 
   - Reads user input from console
   - Adds user message to chat history
   - Calls `koba_agent()` with the complete conversation history
   - Extracts and adds only new messages from the response to history
   - Displays the assistant's reply
3. **Cleanup**: Closes all tool servers before exit

### Key Features

- **Multi-turn Conversations**: Maintains full conversation context across turns
- **Incremental History Updates**: Only adds new messages from agent responses, avoiding duplicates
- **System Prompt**: Automatically includes current time in system prompt for time-aware responses

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
#include "src/single_node/koba_agent.h"

bool reg_loc_tools = init_loc_tools();
```

### 2. add_server() / init_mcp_tools()

Initialize and register MCP (Model Context Protocol) tools by connecting to remote tool servers.

**Function Signature:**
```c++
bool init_mcp_tools(const char* params);
// Or directly use: common_tools::tools::add_server(const std::string& params)
```

**Parameters:**
- `params`: JSON string containing server configuration. Format: `{"ServerName":{"url":"http://host:port","sse_endpoint":"/sse"}}`

**Description:**
- Registers remote MCP tool servers
- Returns `true` on success, `false` on failure

**Example:**
```c++
#include "src/single_node/koba_agent.h"

const auto r1 = add_server(
    R"({"WeatherServer":{"url":"http://18.119.131.41:8006","sse_endpoint":"/sse"}})");
```

### 3. get_server_init_status() / get_tools_init_status()

Get the initialization status of a specific tool server.

**Function Signature:**
```c++
int get_tools_init_status(const char* name);
// Or directly use: common_tools::tools::get_server_init_status(const std::string& name)
```

**Parameters:**
- `name`: Name of the tool server

**Return Value:**
- Returns initialization status code (0 for success, -1 for error or not found)

**Example:**
```c++
#include "src/single_node/koba_agent.h"

int status = get_server_init_status("WeatherServer");
```

### 4. koba_agent()

Core agent function that processes messages using a single node agent and returns the complete conversation history.

**Function Signature:**
```c++
const char* koba_agent(const char* message);
```

**Parameters:**
- `message`: JSON string in OpenAI Chat Completion format (array of message objects), including system prompt and conversation history

**Return Value:**
- Returns a C-style string containing the complete conversation history (JSON array of messages)
- The response includes all previous messages plus new assistant messages

**Message Format:**
The input message should be a JSON array following OpenAI Chat Completion format:

```json
[
  {
    "role": "system",
    "content": "You are a helpful assistant..."
  },
  {
    "role": "user",
    "content": "What's the weather today?"
  }
]
```

**Node Configuration:**
- Uses a single `generate_node` (ChatNode) with LLM to generate responses
- Supports tool calling (can use `search_web2` and registered MCP tools)
- Returns complete conversation history including new assistant messages

**Note:** Environment variables must be configured as described in the [Environment Configuration](#environment-configuration) section above.

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
#include "src/single_node/koba_agent.h"

close_tools();
```
