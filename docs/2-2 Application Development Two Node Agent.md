# Two Node Agent Development Example

## Overview

A two node agent builds upon a single node agent by connecting nodes in series to achieve more complex workflows. This example demonstrates how to connect two Chat Node nodes in series: the first node (`generate_node`) is responsible for generating content and invoking tools, while the second node (`polish_node`) is responsible for polishing and stylizing the output of the first node.

**Workflow Diagram:**
```
Input → generate_node (Generate + Tool Call) → polish_node (Polish) → Output
```

## Development Steps

### 1. Register Tools

Same as a single node agent, you need to register the required tools first. For detailed steps, please refer to the single node agent development documentation.

### 2. Configure the First Node (Generate Node)

Create and configure the first Chat Node for generating content and invoking tools:

```c++
#include <tools.h>

chat_node::chat_node_settings s_generate;
s_generate.model = "gpt-4.1";           // Use a more powerful model
s_generate.temperature = 0.7;
s_generate.top_p = 0.95;
s_generate.max_tokens = 4096;
s_generate.tool_choice = "auto";        // Allow automatic tool invocation
s_generate.tools_json = common_tools::tools::get_all_tools_json();
const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
```

### 3. Configure the Second Node (Polish Node)

Create and configure the second Chat Node for polishing the output of the first node:

```c++
chat_node::chat_node_settings s_polish;
s_polish.model = "gpt-4o-mini";         // Use a more economical model for polishing
s_polish.temperature = 0.7;
s_polish.top_p = 0.95;
s_polish.max_tokens = 4096;
s_polish.tool_choice = "none";          // Polish node doesn't need to invoke tools
const auto polish_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_polish);
```

### 4. Configure Node Preprocessing and Postprocessing (`Advanced Application`)

HADK supports setting preprocessor and postprocessor functions for each node, used for customizing data processing before and after node execution.

#### 4.1 Set Preprocessor Function

The preprocessor function modifies input data before node execution, commonly used for Prompt Engineering (PE) optimization:

```c++
polish_node->setPreprocessor([](const std::string& in) -> std::string {
    HYB_LOG_INFO("polish_node input: {}", in);
    
    // Parse input JSON
    nlohmann::json inJson = nlohmann::json::parse(in);
    
    // Extract the content of the last message
    std::string content = inJson.back()["content"].get<std::string>();
    
    // Build polishing prompt
    std::string prompt = R"(
### CONTEXT
polish the following content:
Content: )" + content + R"(
## YOUR ANSWER:
Provide a comprehensive answer using the content.)";

    // Update message content
    inJson.back()["content"] = prompt;
    return inJson.dump();
});
```

#### 4.2 Set Postprocessor Function

The postprocessor function modifies output data after node execution, commonly used for result parsing and formatting:

```c++
polish_node->setPostprocessor([](const std::string& output) -> std::string {
    HYB_LOG_INFO("polish_node output: {}", output);
    // You can parse, format, etc. the output here
    return output;
});
```

### 5. Connect Nodes in Series

Use the `chain` function to connect the two nodes in series, establishing data flow:

```c++
chain(generate_node, polish_node, "polish");
```

**Parameter Description:**
- First parameter: Source node (`generate_node`)
- Second parameter: Target node (`polish_node`)
- Third parameter: Connection name (optional, used to identify the connection)

**Execution Flow:**
1. `generate_node` receives input and generates content (may invoke tools)
2. `generate_node`'s output is automatically passed to `polish_node`
3. `polish_node` polishes the input
4. `polish_node`'s output is returned as the final result

### 6. Create Workflow and Execute

```c++
// Create workflow
auto f = std::make_shared<nodeflow::Flow>();

// Set start node (must be the first node in the workflow)
f->start(generate_node);

// Execute workflow
auto result = f->runWithInput<std::string, std::string>(message);
```

**Parameter Description:**
- Template parameter `IN`: Input data type
- Template parameter `OUT`: Output data type
- `message`: Actual input data (JSON string in OpenAI Chat Completion format)

**Return Value:**
- The workflow's final output result, type is `OUT`

## Complete Example

The following is a complete two node agent implementation example:

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

        // Create workflow
        auto f = std::make_shared<nodeflow::Flow>();

        // Configure first node: Generate node (supports tool invocation)
        chat_node::chat_node_settings s_generate;
        s_generate.model = "gpt-4.1";
        s_generate.temperature = 0.7;
        s_generate.top_p = 0.95;
        s_generate.max_tokens = 4096;
        s_generate.tool_choice = "auto";
        s_generate.tools_json = common_tools::tools::get_all_tools_json();
        const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);

        // Configure second node: Polish node (doesn't invoke tools)
        chat_node::chat_node_settings s_polish;
        s_polish.model = "gpt-4o-mini";
        s_polish.temperature = 0.7;
        s_polish.top_p = 0.95;
        s_polish.max_tokens = 4096;
        s_polish.tool_choice = "none";
        const auto polish_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_polish);

        // Set polish node's preprocessor function
        polish_node->setPreprocessor([](const std::string& in) -> std::string {
            HYB_LOG_INFO("polish_node input: {}", in);
            
            // Parse input JSON
            nlohmann::json inJson = nlohmann::json::parse(in);
            
            // Extract the content of the last message
            std::string content = inJson.back()["content"].get<std::string>();
            
            // Build polishing prompt
            std::string prompt = R"(
### CONTEXT
polish the following content:
Content: )" + content + R"(
## YOUR ANSWER:
Provide a comprehensive answer using the content.)";

            // Update message content
            inJson.back()["content"] = prompt;
            return inJson.dump();
        });

        // Set polish node's postprocessor function
        polish_node->setPostprocessor([](const std::string& output) -> std::string {
            HYB_LOG_INFO("polish_node output: {}", output);
            // You can parse, format, etc. the output here
            return output;
        });

        // Connect nodes in series: generate_node -> polish_node
        nodeflow::chain(generate_node, polish_node, "polish");

        // Set workflow's start node
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
    std::string response = call_tool_impl_cpp(inputJson.dump());
    
    // Response contains complete conversation history
    std::cout << response << std::endl;

    return 0;
}
```

