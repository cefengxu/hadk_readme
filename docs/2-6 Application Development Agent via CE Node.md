# Context Compression Agent Development Example

## Overview

The context compression agent demonstrates how to use HADK's CE Node (Context Engine Node) and Chat Node to build an agent that supports long conversation history. This example implements an intelligent assistant that automatically compresses and manages conversation context, avoiding context window limits through context compression while supporting tool invocation and answer polishing.

**Workflow Diagram:**
```
Input → ce_node (Context Engine Node) → generate_node (Generate Answer/Tool Call) → polish_node (Polish Answer) → Output
```

**Core Features:**
- **Context Compression**: Uses CE Node to automatically compress long conversation history, avoiding model context window limits
- **Tool Invocation**: Generate Node supports automatic tool invocation (e.g., web search)
- **Answer Polishing**: Polish Node polishes the final answer
- **Linear Workflow**: Simple chain structure, easy to understand and maintain

## Development Steps

### 1. Register Tools

First, register the required tools. This example registers two search tools: `search_news` and `search_web2`:

```c++
#include <tools.h>
#include <web_search.h>

// Register tools in initialization function
common_tools::tools::add_function_call(search_news_tool,
    R"({"type":"function","function":{"name":"search_news","description":"Search the web using keywords to get the latest, time-sensitive information such as weather and news, supporting filtering by time range, country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"time_range":{"type":"string","description":"Time range used to limit search results from a specific time","enum":["day","week"]},"country":{"type":"string","description":"Region name (must be in English) used to limit search results from a specific region","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);

common_tools::tools::add_function_call(search_web_tool,
    R"({"type":"function","function":{"name":"search_web2","description":"Search the web using keywords to get general information that doesn't change over time, supporting filtering by country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"country":{"type":"string","description":"Country name (must be in English) used to limit search results from a specific country","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);
```

### 2. Configure CE Node (Context Engine Node)

CE Node is responsible for compressing and managing conversation history to avoid exceeding model context window limits:

```c++
#include <ce_node.h>
#include <hybrid_llm.h>

ce_node::ce_node_settings s_ce;

// Configure summarization strategy (recommended for long conversations)
s_ce.strategy = ContextStrategy::SUMMARIZING;
s_ce.context_limit = 3; // Compression trigger threshold, number of history turns
s_ce.keep_last_n_turns = 1; // Number of recent original message turns to keep
s_ce.tool_trim_limit = 600; // Number of characters to keep for tool results in history messages
s_ce.summarizer_model = "gpt-4o-mini";
s_ce.summarizer_max_tokens = 400;

// Or use trimming strategy (simple but may lose information)
// s_ce.strategy = ContextStrategy::TRIMMING;
// s_ce.max_turns = 3; // Maximum number of history turns to keep

const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);
```

**Parameter Description:**
- `strategy`: Context management strategy, `SUMMARIZING` (summarization) or `TRIMMING` (trimming)
- `context_limit`: Compression trigger threshold, triggers summarization compression when history turns exceed this value
- `keep_last_n_turns`: Number of recent original message turns to keep, these messages won't be compressed
- `tool_trim_limit`: Number of characters to keep for tool results in history messages
- `summarizer_model`: Model name for summarization
- `summarizer_max_tokens`: Maximum tokens for summarizer model
- `max_turns`: Maximum number of history turns to keep (when using `TRIMMING` strategy)

### 3. Configure CE Node Postprocessing and Routing

Set postprocessor function for logging and configure routing to generate node:

```c++
route(ce_node, [&](const std::string&, const std::string& output) -> std::optional<std::string> {
    return "generate"; // Always route to generate node
});
```

### 4. Configure Generate Node

Generate Node is responsible for generating answers and supports automatic tool invocation:

```c++
#include <chat_node.h>

chat_node::chat_node_settings s_generate;
s_generate.model = "gpt-4o-mini";
s_generate.temperature = 0.7;
s_generate.top_p = 0.95;
s_generate.max_tokens = 4096;
s_generate.tool_choice = "auto"; // Automatically choose whether to invoke tools
s_generate.tools_json = common_tools::tools::get_all_tools_json(); // Get all registered tools

const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
```

**Configuration Notes:**
- `tool_choice = "auto"`: Allows the model to automatically decide whether to invoke tools
- `tools_json`: Pass in all registered tools, the model can invoke them as needed

### 5. Configure Generate Node Preprocessing, Postprocessing, and Routing

Generate Node's preprocessor and postprocessor functions can be used for data transformation and logging:

```c++
generate_node->setPreprocessor([](const std::string& in) -> std::string {
    // Pass input directly without modification
    // Can also perform data transformation or validation here
    return in;
});

generate_node->setPostprocessor([](const std::string& output) -> std::string {
    // Pass output directly without modification
    // Can also perform result processing or logging here
    return output;
});

route(generate_node, [&](const std::string&, const std::string& output) -> std::optional<std::string> {
    return "polish"; // Always route to polish node
});
```

### 6. Configure Polish Node

Polish Node is responsible for polishing the final answer:

```c++
chat_node::chat_node_settings s_polish;
s_polish.model = "gpt-4o-mini";
s_polish.temperature = 0.7;
s_polish.top_p = 0.95;
s_polish.max_tokens = 4096;
s_polish.tool_choice = "none"; // Polish node doesn't need tool invocation

const auto polish_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_polish);
```

### 7. Configure Polish Node Preprocessing and Postprocessing

Polish Node's preprocessor function builds the polishing prompt:

```c++
polish_node->setPreprocessor([](const std::string& in) -> std::string {
    nlohmann::json inJson = nlohmann::json::parse(in);
    
    // Extract content of the last message
    std::string _content = inJson.back()["content"].get<std::string>();
    
    // Build polishing prompt
    std::string prompt = R"(### CONTEXT
polish the following content:
Content: )" + _content + R"(
## YOUR ANSWER:
Provide a comprehensive answer using the content.)";

    // Replace content of the last message
    inJson.back()["content"] = prompt;
    
    return inJson.dump();
});

```

### 8. Connect Nodes

Use the `chain` function to establish chain connections between nodes:

```c++
#include <nodeflow.hpp>

// CE Node to Generate Node
chain(ce_node, generate_node, "generate");

// Generate Node to Polish Node
chain(generate_node, polish_node, "polish");
```

### 9. Create Workflow and Execute

Create workflow, set start node and execute:

```c++
// Create workflow
auto f = std::make_shared<nodeflow::Flow>();

// Set start node to CE Node
f->start(ce_node);

// Execute workflow
auto result = f->runWithInput<std::string, std::string>(message);
```

**Execution Flow:**
1. Input message enters `ce_node` for context compression processing
2. Compressed context is passed to `generate_node`
3. `generate_node` generates answer based on context, invoking tools (e.g., search) when necessary
4. Generated result is passed to `polish_node` for polishing
5. Return final polished answer

## Complete Example

The following is a complete context compression agent implementation example:

```c++
#include "hybrid_agents.h"
#include <chat_node.h>
#include <ce_node.h>
#include <hybrid_llm.h>
#include <log_util.hpp>
#include <nodeflow.hpp>
#include <tools.h>
#include <web_search.h>
#include <nlohmann/json.hpp>

namespace
{
    // Lazy initialization function
    void ensure_initialized()
    {
        static bool initialized = []() -> bool
        {
            try
            {
                HYB_LOG_DEBUG("===== hybrid_agent lazy initialization start =====");

                // Register default local tools
                HYB_LOG_DEBUG("🔧 Register default tools");
                common_tools::tools::add_function_call(search_news_tool,
                    R"({"type":"function","function":{"name":"search_news","description":"Search the web using keywords to get the latest, time-sensitive information such as weather and news, supporting filtering by time range, country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"time_range":{"type":"string","description":"Time range used to limit search results from a specific time","enum":["day","week"]},"country":{"type":"string","description":"Region name (must be in English) used to limit search results from a specific region","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
                );
                common_tools::tools::add_function_call(search_web_tool,
                    R"({"type":"function","function":{"name":"search_web2","description":"Search the web using keywords to get general information that doesn't change over time, supporting filtering by country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"country":{"type":"string","description":"Country name (must be in English) used to limit search results from a specific country","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
                );

                HYB_LOG_DEBUG("✅ hybrid_agent lazy initialization complete");
                return true;
            }
            catch (const std::exception& ex)
            {
                HYB_LOG_ERROR(std::string("hybrid_agent ensure_initialized exception: ") + ex.what());
                return false;
            }
        }();
        (void)initialized;
    }

    // Bridge function between C and C++
    std::string call_tool_impl_cpp(const std::string& message)
    {
        try
        {
            HYB_LOG_INFO("===== call_tool_impl_cpp BEGIN =====");

            auto f = std::make_shared<nodeflow::Flow>();

            // Configure CE Node
            ce_node::ce_node_settings s_ce;
            s_ce.strategy = ContextStrategy::SUMMARIZING;
            s_ce.context_limit = 3; // Compression trigger threshold, number of history turns
            s_ce.keep_last_n_turns = 1; // Number of recent original message turns to keep
            s_ce.tool_trim_limit = 600; // Number of characters to keep for tool results in history messages
            s_ce.summarizer_model = "gpt-4o-mini";
            s_ce.summarizer_max_tokens = 400;

            const auto ce_node = std::make_shared<ce_node::CeNode<std::string, std::string>>(s_ce);

            ce_node->setPostprocessor([](const std::string& output) -> std::string {
                HYB_LOG_INFO("🤢 ce_node output: {}", output);
                return output;
            });

            route(ce_node, [&](const std::string&, const std::string& output) -> std::optional<std::string> {
                return "generate";
            });

            // Configure Generate Node
            chat_node::chat_node_settings s_generate;
            s_generate.model = "gpt-4o-mini";
            s_generate.temperature = 0.7;
            s_generate.top_p = 0.95;
            s_generate.max_tokens = 4096;
            s_generate.tool_choice = "auto";
            s_generate.tools_json = common_tools::tools::get_all_tools_json();

            const auto generate_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_generate);
            
            generate_node->setPreprocessor([](const std::string& in) -> std::string {
                return in;
            });

            generate_node->setPostprocessor([](const std::string& output) -> std::string {
                return output;
            });

            route(generate_node, [&](const std::string&, const std::string& output) -> std::optional<std::string> {
                return "polish";
            });

            // Configure Polish Node
            chat_node::chat_node_settings s_polish;
            s_polish.model = "gpt-4o-mini";
            s_polish.temperature = 0.7;
            s_polish.top_p = 0.95;
            s_polish.max_tokens = 4096;
            s_polish.tool_choice = "none";

            const auto polish_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_polish);
            
            polish_node->setPreprocessor([](const std::string& in) -> std::string {
                nlohmann::json inJson = nlohmann::json::parse(in);
                std::string _content = inJson.back()["content"].get<std::string>();
                std::string prompt = R"(### CONTEXT
polish the following content:
Content: )" + _content + R"(
## YOUR ANSWER:
Provide a comprehensive answer using the content.)";

                inJson.back()["content"] = prompt;
                return inJson.dump();
            });

            polish_node->setPostprocessor([](const std::string& output) -> std::string {
                return output;
            });

            // Connect nodes
            chain(ce_node, generate_node, "generate");
            chain(generate_node, polish_node, "polish");

            // Create workflow and execute
            f->start(ce_node);
            auto result = f->runWithInput<std::string, std::string>(message);

            return result;
        }
        catch (const std::exception& ex)
        {
            HYB_LOG_ERROR(std::string("call_tool_impl_cpp exception: ") + ex.what());
            return {R"({"ok":false,"error":"exception"})"};
        }
        catch (...)
        {
            HYB_LOG_ERROR("call_tool_impl_cpp unknown exception");
            return {R"({"ok":false,"error":"unknown exception"})"};
        }
    }
}

HYBRID_AGENT_API const char* hybrid_agents(const char* input)
{
    try
    {
        ensure_initialized();

        thread_local std::string tls_result;
        const std::string message = input ? std::string(input) : std::string();

        tls_result = call_tool_impl_cpp(message);
        return tls_result.c_str();
    }
    catch (...)
    {
        static constexpr char k_empty[] = "{}";
        return k_empty;
    }
}
```

## Key Points

1. **Context Compression**: CE Node automatically manages long conversation history, using summarization strategy to compress old messages, avoiding model context window limits
2. **Tool Invocation**: Generate Node configured with `tool_choice = "auto"`, allowing the model to automatically invoke registered tools as needed
3. **Linear Workflow**: Use `chain` function to establish simple chain connections, workflow is clear and easy to understand
4. **Answer Polishing**: Polish Node polishes generated results to improve answer quality
5. **Routing Configuration**: Although the workflow is linear, you still need to use `route` function to configure routing, ensuring data is correctly passed

## Use Cases

This example is suitable for the following scenarios:
- Intelligent assistants that need to support long conversation history
- Applications that need automatic tool invocation (e.g., search)
- Scenarios requiring high-quality answer output
- Simple, maintainable workflow structures

## Differences from Conditional Routing Agent

| Feature | Context Compression Agent | Conditional Routing Agent |
|---------|-------------------------|--------------------------|
| Workflow Structure | Linear chain | Conditional routing with loops |
| Context Management | CE Node automatic compression | Manual context management |
| Tool Invocation | Generate Node automatic invocation | Custom node manual invocation |
| Complexity | Simple | Medium |
| Use Cases | Long conversations, automatic tool invocation | Scenarios requiring decision-making and loops |
