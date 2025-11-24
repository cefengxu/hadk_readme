# Conditional Routing Agent Development Example

## Overview

The conditional routing agent demonstrates how to use HADK's conditional routing (`route`) functionality to implement complex workflows. This example implements a research assistant agent that can dynamically decide whether to continue searching for information or directly answer questions based on the current context, supporting iterative searches until sufficient information is obtained.

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

## Development Steps

### 1. Register Tools

Same as a single node agent, you need to register the required tools first. This example uses the `search_web2` tool for web search:

```c++
#include <tools.h>
#include <web_search.h>

common_tools::tools::add_function_call(search_web_tool,
    R"({"type":"function","function":{"name":"search_web2","description":"Search the web using keywords to get general information that doesn't change over time, supporting filtering by country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"country":{"type":"string","description":"Country name (must be in English) used to limit search results from a specific country","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);
```

### 2. Configure Decision Node (Decide Node)

The decision node is responsible for analyzing the current context and deciding the next action (search or answer):

```c++
chat_node::chat_node_settings s1;
s1.model = "gpt-4o-mini";
s1.temperature = 0.7;
s1.top_p = 0.95;
s1.max_tokens = 2048;
s1.tool_choice = "none"; 
const auto decide_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s1);
```

### 3. Configure Decision Node Preprocessing and Postprocessing

#### 3.1 Set Preprocessor Function

The preprocessor function builds a decision prompt containing the question, existing context, and available actions:

```c++
decide_node->setPreprocessor([&](const std::string& in) -> std::string {
    nlohmann::json inJson = nlohmann::json::parse(in);
    
    g_question = inJson[0]["content"].get<std::string>();
    
    std::string prompt = build_ws_prompt(g_question, g_context);
    inJson[0]["content"] = prompt;
    return inJson.dump();
});
```

`build_ws_prompt` function example:

```c++
static std::string build_ws_prompt(const std::string &question, const std::string &context) {
    auto now = std::chrono::system_clock::now();
    const std::string local_time = fmt::format("{:%Y-%m-%d %H:%M:%S}", now);
    
    return R"(### CONTEXT
You are a research assistant that can search the web.
Question: )" + question + R"(
Previous Research: )" + context + R"(

### ACTION SPACE
[1] search
Description: Look up more information on the web
Parameters:
    - query (str): What to search for

[2] answer
Description: Answer the question with current knowledge
Parameters:
    - answer (str): Final answer to the question

## NEXT ACTION
Decide the next action based on the context and available actions.
Return your response in this format:

```yaml
thinking: |
    <your step-by-step reasoning process>
action: search OR answer
reason: |
    <why you chose this action>
answer: |
    <if action is answer>
search_query: <specific search query if action is search>
```
Current time: )" + local_time;
}
```

#### 3.2 Set Postprocessor Function

The postprocessor function parses the YAML-formatted decision result and extracts the action type and parameters:

```c++
decide_node->setPostprocessor([&](const std::string& output) -> std::string {
    nlohmann::json output_Json = nlohmann::json::parse(output);
    
    // Extract and clean response content (remove code block markers)
    std::string cleaned_response = StripFenceRegex(
        output_Json.back()["content"].get<std::string>());
    
    // Parse YAML
    g_yaml_node = YAML::Load(cleaned_response);
    
    // Check required fields
    if (!g_yaml_node["thinking"] || !g_yaml_node["action"] || !g_yaml_node["reason"]) {
        HYB_LOG_WARN("Missing required YAML fields");
        return "search";  // Default to search on error
    }
    
    // Return different values based on action type
    if (g_yaml_node["action"].as<std::string>() == "search") {
        return g_yaml_node["search_query"].as<std::string>();  // Return search query
    }
    
    if (g_yaml_node["action"].as<std::string>() == "answer") {
        // Build final answer prompt
        std::string prompt = R"(### CONTEXT
Based on the following information, answer the question.
Question: )" + g_question + R"(
Research: )" + g_context + R"(

## YOUR ANSWER:
Provide a comprehensive answer using the research results.)";
        return prompt;
    }
    
    return "search";  // Default to search
});
```

### 4. Configure Conditional Routing

Use the `route` function to configure conditional routing for the decision node, selecting the next node based on the postprocessor function's output:

```c++
route(decide_node, [&](const std::string &input, const std::string &output) -> std::optional<std::string> {
    if (g_yaml_node["action"].as<std::string>() == "search") {
        return "search";  // Route to search node
    }
    
    if (g_yaml_node["action"].as<std::string>() == "answer") {
        return "answer";  // Route to answer node
    }
    
    return std::nullopt;  // No matching route
});
```

**Parameter Description:**
- First parameter: Source node (`decide_node`)
- Second parameter: Route function that receives input and output, returns route name (`std::optional<std::string>`)

### 5. Configure Search Node (Web Search Node)

The search node uses `OneFuncNode` to implement custom logic, invoke tools, and process results:

```c++
auto web_search_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
    [&](const std::string &input) -> std::string {
        // Build tool invocation parameters
        nlohmann::json ws_in_json;
        ws_in_json["query"] = input;  // input is the search query string
        
        // Invoke search tool
        std::string ws_out = common_tools::tools::call_tool("search_web2", ws_in_json.dump());
        
        // Parse tool return result (tool returns wrapped JSON)
        nlohmann::json ws_out_json = nlohmann::json::parse(ws_out);
        
        std::string web_content;
        try {
            // Extract actual search results from wrapped JSON
            if (ws_out_json.contains("content") && 
                ws_out_json["content"].is_array() && 
                !ws_out_json["content"].empty()) {
                const auto &first = ws_out_json["content"][0];
                if (first.contains("type") && 
                    first["type"].get<std::string>() == "text" && 
                    first.contains("text")) {
                    // Parse actual search results again
                    nlohmann::json ws_payload = nlohmann::json::parse(
                        first["text"].get<std::string>());
                    
                    // Extract and format search results
                    if (ws_payload.contains("responses") && 
                        ws_payload["responses"].is_array()) {
                        for (const auto &resp : ws_payload["responses"]) {
                            web_content +=
                                "TITLE: " + resp["title"].get<std::string>() +
                                "\nURL: " + resp["url"].get<std::string>() +
                                "\nSNIPPET: " + resp["snippet"].get<std::string>() +
                                "\n\n";
                        }
                    }
                }
            }
        } catch (const std::exception &e) {
            HYB_LOG_ERROR("Failed to parse search results: {}", e.what());
        }
        
        // Accumulate context
        std::string new_context = 
            g_context +
            "\n\nSEARCH: " + input +
            "\n\nRESULTS: \n" + 
            (!web_content.empty() ? web_content : "No results");
        
        g_context = new_context;
        
        // Return question for re-entering decision node
        nlohmann::json output_json = nlohmann::json::array();
        output_json.push_back({{"role", "user"}, {"content", g_question}});
        return output_json.dump();
    });
```

### 6. Configure Search Node Routing

The search node always returns to the decision node after execution, forming a loop:

```c++
route(web_search_node, [&](const std::string &input, const std::string &output) -> std::optional<std::string> {
    return "decide";  // Always route back to decision node
});
```

### 7. Configure Answer Node (Answer Node)

The answer node generates the final answer:

```c++
chat_node::chat_node_settings s_answer;
const auto answer_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_answer);

answer_node->setPreprocessor([&](const std::string &in) -> std::string {
    // Convert input to Chat Completion format
    nlohmann::json inJson = nlohmann::json::array();
    inJson.push_back({{"role", "user"}, {"content", in}});
    return inJson.dump();
});
```

### 8. Connect Nodes

Use the `chain` function to establish connections between nodes:

```c++
// Decision node to search node
nodeflow::chain(decide_node, web_search_node, "search");

// Decision node to answer node
nodeflow::chain(decide_node, answer_node, "answer");

// Search node back to decision node (forms loop)
nodeflow::chain(web_search_node, decide_node, "decide");
```

### 9. Create Workflow and Execute

```c++
// Create workflow
auto f = std::make_shared<nodeflow::Flow>();

// Set start node
f->start(decide_node);

// Execute workflow
auto result = f->runWithInput<std::string, std::string>(question);
```

**Execution Flow:**
1. Input question enters `decide_node`
2. `decide_node` analyzes context and decides to search or answer
3. If search is chosen:
   - Route to `web_search_node` to execute search
   - Search results accumulate into context
   - Route back to `decide_node` (loop)
4. If answer is chosen:
   - Route to `answer_node` to generate final answer
   - Return result

## Complete Example

The following is a complete conditional routing agent implementation example:

```c++
#include <chat_node.h>
#include <log_util.hpp>
#include <nodeflow.hpp>
#include <tools.h>
#include <web_search.h>
#include <nlohmann/json.hpp>
#include <yaml-cpp/yaml.h>
#include <fmt/chrono.h>
#include <chrono>
#include <regex>
#include <iostream>

std::string StripFenceRegex(std::string s) {
    s = std::regex_replace(s, std::regex(R"(^\s*```[^\r\n]*\r?\n)"), "");
    s = std::regex_replace(s, std::regex(R"((?:\r?\n)?\s*```\s*$)"), "");
    return s;
}

static std::string build_ws_prompt(const std::string &question, const std::string &context) {
    auto now = std::chrono::system_clock::now();
    const std::string local_time = fmt::format("{:%Y-%m-%d %H:%M:%S}", now);
    
    return R"(### CONTEXT
            You are a research assistant that can search the web.
            Question: )" + question + R"(
            Previous Research: )" + context + R"(

            ### ACTION SPACE
            [1] search
            Description: Look up more information on the web
            Parameters:
                - query (str): What to search for

            [2] answer
            Description: Answer the question with current knowledge
            Parameters:
                - answer (str): Final answer to the question

            ## NEXT ACTION
            Decide the next action based on the context and available actions.
            Return your response in this format:

            ```yaml
            thinking: |
                <your step-by-step reasoning process>
            action: search OR answer
            reason: |
                <why you chose this action>
            answer: |
                <if action is answer>
            search_query: <specific search query if action is search>
            ```
Current time: )" + local_time;
}

// Register tools
common_tools::tools::add_function_call(search_web_tool,
    R"({"type":"function","function":{"name":"search_web2","description":"Search the web using keywords to get general information that doesn't change over time, supporting filtering by country, etc. to get web content, titles, and link information","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search query string used to search for relevant information on the web. Keyword combinations should be concise and clear, avoiding redundant information while ensuring they accurately reflect the core needs of the user's question. Keyword combinations should conform to search engine syntax and logical rules","minLength":1},"country":{"type":"string","description":"Country name (must be in English) used to limit search results from a specific country","enum":["china","usa","japan","..."]}},"required":["query"]}}})"
);

std::string call_tool_impl_cpp(const std::string &question) {
    try {
        // State variables
        std::string g_context = "";
        std::string g_question = "";
        YAML::Node g_yaml_node = YAML::Node();

        // Configure decision node
        chat_node::chat_node_settings s1;
        s1.model = "gpt-4o-mini";
        s1.temperature = 0.7;
        s1.top_p = 0.95;
        s1.max_tokens = 2048;
        s1.tool_choice = "none";
        const auto decide_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s1);

        // Set decision node's preprocessor function
        decide_node->setPreprocessor([&](const std::string& in) -> std::string {
            nlohmann::json inJson = nlohmann::json::parse(in);
            g_question = inJson[0]["content"].get<std::string>();
            std::string prompt = build_ws_prompt(g_question, g_context);
            inJson[0]["content"] = prompt;
            return inJson.dump();
        });

        decide_node->setPostprocessor([&](const std::string& output) -> std::string {
            nlohmann::json output_Json = nlohmann::json::parse(output);
            std::string cleaned_response = StripFenceRegex(
                output_Json.back()["content"].get<std::string>());

            g_yaml_node = YAML::Load(cleaned_response);

            if (!g_yaml_node["thinking"] || !g_yaml_node["action"] || !g_yaml_node["reason"]) {
                HYB_LOG_WARN("Missing required YAML fields");
                return "search";
            }

            HYB_LOG_INFO("Thinking: {}", g_yaml_node["thinking"].as<std::string>());
            HYB_LOG_INFO("Action: {}", g_yaml_node["action"].as<std::string>());
            HYB_LOG_INFO("Reason: {}", g_yaml_node["reason"].as<std::string>());

            if (g_yaml_node["action"].as<std::string>() == "search") {
                return g_yaml_node["search_query"].as<std::string>();
            }

            if (g_yaml_node["action"].as<std::string>() == "answer") {
                std::string prompt = R"(### CONTEXT
Based on the following information, answer the question.
Question: )" + g_question + R"(
Research: )" + g_context + R"(

## YOUR ANSWER:
Provide a comprehensive answer using the research results.)";
                return prompt;
            }
            
            return "search";
        });

        // Configure decision node's conditional routing
        route(decide_node, [&](const std::string &input, const std::string &output) -> std::optional<std::string> {
            if (g_yaml_node["action"].as<std::string>() == "search") {
                HYB_LOG_INFO("Routing to search node");
                return "search";
            }
            if (g_yaml_node["action"].as<std::string>() == "answer") {
                HYB_LOG_INFO("Routing to answer node");
                return "answer";
            }
            return std::nullopt;
        });

        // Configure search node
        auto web_search_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
            [&](const std::string &input) -> std::string {
                // Build tool invocation parameters
                nlohmann::json ws_in_json;
                ws_in_json["query"] = input;

                // Invoke search tool
                std::string ws_out = common_tools::tools::call_tool("search_web2", ws_in_json.dump());
                nlohmann::json ws_out_json = nlohmann::json::parse(ws_out);

                // Parse search results
                std::string web_content;
                try {
                    if (ws_out_json.contains("content") && 
                        ws_out_json["content"].is_array() && 
                        !ws_out_json["content"].empty()) {
                        const auto &first = ws_out_json["content"][0];
                        if (first.contains("type") && 
                            first["type"].get<std::string>() == "text" && 
                            first.contains("text")) {
                            // Parse actual search results again
                            nlohmann::json ws_payload = nlohmann::json::parse(
                                first["text"].get<std::string>());
                            if (ws_payload.contains("responses") && 
                                ws_payload["responses"].is_array()) {
                                for (const auto &resp : ws_payload["responses"]) {
                                    web_content +=
                                        "TITLE: " + resp["title"].get<std::string>() +
                                        "\nURL: " + resp["url"].get<std::string>() +
                                        "\nSNIPPET: " + resp["snippet"].get<std::string>() +
                                        "\n\n";
                                }
                            }
                        }
                    }
                } catch (const std::exception &e) {
                    HYB_LOG_ERROR("Failed to parse search results: {}", e.what());
                }

                // Accumulate context
                std::string new_context = 
                    g_context +
                    "\n\nSEARCH: " + input +
                    "\n\nRESULTS: \n" + 
                    (!web_content.empty() ? web_content : "No results");

                g_context = new_context;

                // Return question for re-entering decision node
                nlohmann::json output_json = nlohmann::json::array();
                output_json.push_back({{"role", "user"}, {"content", g_question}});
                return output_json.dump();
            });

        // Configure search node's routing (always returns to decision node)
        route(web_search_node, [&](const std::string &input, const std::string &output) -> std::optional<std::string> {
            return "decide";
        });

        // Configure answer node
        chat_node::chat_node_settings s_answer;
        const auto answer_node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s_answer);
        answer_node->setPreprocessor([&](const std::string &in) -> std::string {
            nlohmann::json inJson = nlohmann::json::array();
            inJson.push_back({{"role", "user"}, {"content", in}});
            return inJson.dump();
        });

        // Connect nodes
        nodeflow::chain(decide_node, web_search_node, "search");
        nodeflow::chain(decide_node, answer_node, "answer");
        nodeflow::chain(web_search_node, decide_node, "decide");

        // Create workflow and execute
        auto f = std::make_shared<nodeflow::Flow>();
        f->start(decide_node);
        auto result = f->runWithInput<std::string, std::string>(question);

        return result;
    } catch (const std::exception &ex) {
        HYB_LOG_ERROR(std::string("call_tool_impl_cpp exception: ") + ex.what());
        return R"({"ok":false,"error":"exception"})";
    } catch (...) {
        HYB_LOG_ERROR("call_tool_impl_cpp unknown exception");
        return R"({"ok":false,"error":"unknown exception"})";
    }
}

int main() {
    // Build input message
    nlohmann::json inputJson = nlohmann::json::array();
    inputJson.push_back({
        {"role", "user"},
        {"content", "What is the latest news about artificial intelligence?"}
    });
    
    // Call agent and get response
    std::string response = call_tool_impl_cpp(inputJson.dump());
    
    // Output result
    std::cout << response << std::endl;

    return 0;
}
```

## Key Points

1. **Conditional Routing**: Use the `route` function to dynamically select the next node based on node output
2. **Loop Workflow**: Routing can implement loops between nodes, supporting iterative search
3. **Context Management**: Use global variables or state objects to manage context information in workflows
4. **YAML Parsing**: Decision node returns YAML format, needs to be parsed to extract action type and parameters
5. **Tool Invocation**: Use `OneFuncNode` to implement custom logic, invoke tools, and process results

