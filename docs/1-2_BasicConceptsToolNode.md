# Tool Node

Tool Node is a tool management node that supports the following features:

- **Tool Registration and Management**: Supports registration, execution, and destruction of MCP (Model Context Protocol) tools (SSE/STDIO) and local tools
- **Function Call Integration**: Can serve as the foundation for Chat Node's Function Call, or execute independently
- **Custom Extensions**: Supports user-defined local functions registered to the Tool Node

## Registering Tools

### Registering Local Tools

For local tool development specifications, please refer to `Local Tool Development Specifications`.

```c++
common_tools::tools::add_function_call(search_news_tool,
    R"({"type":"function","function":{"name":"search_news","description":"Search for the latest news information using keywords","parameters":{"type":"object","properties":{"query":{"type":"string","description":"Search keywords","minLength":1},"time_range":{"type":"string","enum":["day","week"]},"country":{"type":"string","enum":["china","usa","japan"]}},"required":["query"]}}})"
);
```

### Registering MCP Tools

```c++
const auto r1 = common_tools::tools::add_server(
    R"({"WeatherServer":{"url":"http://18.119.131.41:8006","sse_endpoint":"/sse"}})"
);
```

## Getting Tool Status (MCP Tools Only)

The function to get the initialization status of MCP tools is as follows:

```c++
int status = common_tools::tools::get_server_init_status(std::string(name));
```

**Parameter Description:**
- `name`: The unique identifier name of the tool (case-sensitive)

**Return Value:**
- `1`: Initialization successful
- `2`: Initialization failed
- `0`: Initialization in progress
- `-1`: Unknown status

## Closing Tools (MCP Tools Only)

The function to close all MCP tools is as follows:

```c++
common_tools::tools::shutdown_all_servers();
```

## Executing Tools

### Automatic Invocation via Chat Node

Tools can serve as Chat Node's Function Call functions, automatically judged and invoked by the model. By configuring as follows, Chat Node will have tool invocation capabilities:

```c++
chat_node::chat_node_settings s;
s.model = "gpt-4o-mini";
s.temperature = 0.7;
s.max_tokens = 4096;
s.tool_choice = "auto";  // Enable automatic tool selection
s.tools_json = common_tools::tools::get_all_tools_json();  // Get all registered tools
const auto node = std::make_shared<chat_node::ChatNode<std::string, std::string>>(s);
```

### Manually Invoking a Specified Tool

Manually execute a specified tool in the following way:

```c++
std::string ws_out = common_tools::tools::call_tool("search_web2", ws_in_json.dump());
```

### Tool Input Format

Tool input parameters strictly follow the OpenAI Chat Completion API's Function Call parameter format, passed as `std::string` type. The input is a JSON-formatted parameter string:

```json
{
  "query": "Search keywords",
  "time_range": "day",
  "country": "china"
}
```

**Example Code:**

```c++
nlohmann::json params;
params["query"] = "Latest tech news";
params["time_range"] = "day";
params["country"] = "china";
std::string arguments = params.dump();

std::string result = common_tools::tools::call_tool("search_news", arguments);
```

### Tool Output Format

Tool output results strictly follow the OpenAI Chat Completion API's Function Call response format, returned as `std::string` type. The output is in JSON format:

```json
{
  "content": [
    {
      "type": "text",
      "text": "Tool execution result content"
    }
  ],
  "isError": false
}
```

**Field Description:**
- `content`: Result content array, each element contains `type` and `text` fields
- `isError`: Boolean value indicating whether an error occurred

For local tool development sample, please refer to [link](https://gitlab.xpaas.lenovo.com/ai-now-team/hadk_dylibs/-/tree/main/local_tools/tavily?ref_type=heads).



### Optional: Call the Tool in Custom Code**

You can invoke the custom tool’s API directly, as shown below, [ref link about Custom Code](https://cefengxu.github.io/hadk_readme/1-3_BasicConceptsDIYNode/):

```c++

// 构建工具参数 JSON
nlohmann::json arguments = {
  {"name", "search_web2"},
  {"arguments", nlohmann::json{{"query", in}}.dump()}
};

std::string result = common_tools::tools::call_tool("search_news", arguments.dump());
nlohmann::json result_json = nlohmann::json::parse(result);

if (!result_json["isError"].get<bool>()) {
    std::string text = result_json["content"][0]["text"].get<std::string>();
    // Process result
}
```

For local tool development specifications, please refer to `Local Tool Development Specifications`.

