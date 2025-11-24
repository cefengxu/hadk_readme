# Single Node Agent Development Example

## Overview

Chat Node is a node component that integrates large language models (LLM) and function calling capabilities, supporting both online and offline model invocation. Its interface strictly follows the OpenAI Chat Completion API specification.

## Development Steps

### 1. Register Tools

Before using Chat Node, you need to register the required tools first. Tools are divided into two categories:

- **Local Tools**: Need to implement tool classes in advance. For development specifications, please refer to `Local Tool Development Specifications`
- **Remote Tools**: Configured through server URLs

#### 1.1 Register Local Tools

Use the `add_function_call` method to register local tools. Tool descriptions must follow the OpenAI Function Call format:

```c++
#include <tools.h>
#include <web_search.h>

common_tools::tools::add_function_call(search_news_tool,
    R"({"type":"function","function":{"name":"search_news","description":"Search the web using keywords to get the latest, time-sensitive information such as weather and news, supporting filtering by time range, country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"time_range":{"type":"string","description":"Time range used to limit search results from a specific time","enum":["day","week"]},"country":{"type":"string","description":"Region name (must be in English) used to limit search results from a specific region","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);
```

Tool description JSON format example:

```json
[
  {
    "type": "function",
    "function": {
      "name": "search_news",
      "description": "Search for the latest news information",
      "parameters": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "Search keywords"
          }
        },
        "required": ["query"]
      }
    }
  }
]
```

#### 1.2 Register Remote Tool Server

Use the `add_server` method to register a remote tool server:

```c++
#include <tools.h>

common_tools::tools::add_server(
    R"({"WeatherServer":{"url":"http://18.119.131.41:8006","sse_endpoint":"/sse"}})"
);
```

### 2. Configure Chat Node

Create a `chat_node_settings` object and configure model parameters:

```c++
#include <tools.h>

chat_node::chat_node_settings s_generate;
s_generate.model = "gpt-4.1";           // Model name
s_generate.temperature = 0.7;           // Temperature parameter, controls output randomness
s_generate.top_p = 0.95;                 // Top-p sampling parameter
s_generate.max_tokens = 4096;           // Maximum generated tokens
s_generate.tool_choice = "auto";        // Tool selection strategy: auto/none/required
s_generate.tools_json = common_tools::tools::get_all_tools_json();  // Get all registered tools
```

### 3. Create Workflow

#### 3.1 Create Chat Node Instance

```c++
const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
```

#### 3.2 Create and Configure Flow

```c++
auto f = std::make_shared<nodeflow::Flow>();
f->start(generate_node);  // Set the workflow's start node
```

#### 3.3 Execute Workflow

Use the `runWithInput` method to execute the workflow:

```c++
auto result = f->runWithInput<std::string, std::string>(message);
```

**Parameter Description:**
- Template parameter `IN`: Input data type
- Template parameter `OUT`: Output data type
- `input`: Actual input data

**Return Value:**
- The workflow's final output result, type is `OUT`

## Complete Example

The following is a complete single node agent implementation example:

```c++
#include <chat_node.h>
#include <log_util.hpp>
#include <nodeflow.hpp>
#include <tools.h>
#include <web_search.h>
#include <nlohmann/json.hpp>

// Register local tools
common_tools::tools::add_function_call(search_news_tool,
    R"({"type":"function","function":{"name":"search_news","description":"Search the web using keywords to get the latest, time-sensitive information such as weather and news, supporting filtering by time range, country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"time_range":{"type":"string","description":"Time range used to limit search results from a specific time","enum":["day","week"]},"country":{"type":"string","description":"Region name (must be in English) used to limit search results from a specific region","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);

// Register remote tool server
common_tools::tools::add_server(
    R"({"WeatherServer":{"url":"http://18.119.131.41:8006","sse_endpoint":"/sse"}})"
);

std::string call_tool_impl_cpp(const std::string& message)
{
    try
    {
        HYB_LOG_INFO("===== call_tool_impl_cpp BEGIN =====");
    
        // Configure Chat Node parameters
        chat_node::chat_node_settings s_generate;
        s_generate.model = "gpt-4.1";
        s_generate.temperature = 0.7;
        s_generate.top_p = 0.95;
        s_generate.max_tokens = 4096;
        s_generate.tool_choice = "auto";
        s_generate.tools_json = common_tools::tools::get_all_tools_json();
        
        // Create Chat Node instance
        const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);

        // Create workflow and set start node
        auto f = std::make_shared<nodeflow::Flow>();
        f->start(generate_node);
        
        // Execute workflow
        auto result = f->runWithInput<std::string, std::string>(message);

        return result;
    }
    catch (const std::exception& ex)
    {
        HYB_LOG_ERROR(std::string("call_tool_impl_cpp exception: ") + ex.what());
        return R"({"ok":false,"error":"exception"})";
    }
    catch (...)
    {
        HYB_LOG_ERROR("call_tool_impl_cpp unknown exception");
        return R"({"ok":false,"error":"unknown exception"})";
    }
}

int main()
{
    // Build input message (OpenAI Chat Completion format)
    nlohmann::json inputJson = nlohmann::json::array();
    inputJson.push_back({
        {"role", "system"},
        {"content", "you are a helper"}
    });
    inputJson.push_back({
        {"role", "user"},
        {"content", "hello there"}
    });
    
    // Call agent and get response
    const char* response = call_tool_impl_cpp(inputJson.dump().c_str());
    std::string responseStr(response);
    
    // Response contains complete conversation history
    std::cout << responseStr << std::endl;

    return 0;
}
```

