# Embedding Node

## Building an Embedding Node

You can build vector embedding processing nodes using `EmbeddingNode`. It supports model configuration, preprocessor and postprocessor hooks, and routing to downstream nodes.

### Basic Usage

```c++
embedding_node_settings embedding_settings = embedding_node_default_settings();
std::shared_ptr<embedding_node::EmbeddingNode<std::string, std::string>> embedded_node;

embedding_settings.model = "text-embedding-3-small";
embedding_settings.embedding_dim = 256;
embedding_settings.api_key = "YOUR_API_KEY";
embedding_settings.api_url = "https://3rd-page/v1";

embedded_node = std::make_shared<embedding_node::EmbeddingNode<std::string, std::string>>(embedding_settings);

embedded_node->setPreprocessor([](const std::string& input) -> std::string
{
    std::cout << "🦑 embedded_node input: " << input << std::endl;

    // Example input:
    // {
    //   "content": ["hello", "world"]
    // }
    nlohmann::json inputJson = nlohmann::json::parse(input);
    std::string content = inputJson.back()["content"].get<std::string>();

    nlohmann::json outputJson = {{"content", content}};
    return outputJson.dump();
});

embedded_node->setPostprocessor([](const std::string& output) -> std::string
{
    std::cout << "🦑 embedded_node output: " << output << std::endl;
    return output;
});

route(embedded_node, [this](const std::string& input, const std::string& output)
    -> std::optional<std::string>
{
    return "mem_end";
});
```
### Input Format
```json
{
    "content" : "hello world"
}
```
```json
{
    "content" : ["hello world"]
}
```
### Output Format
```

```


### API Using 

```c++
EMBEDDING_NODE_API const char* embedding_node_run_core_c(const char* name, const embedding_node_settings_c* settings,const char* input, const char* parent_span_name);
```

**Notes:**

- `embedding_node_default_settings()`: Creates default embedding settings, then override required fields.
- `EmbeddingNode<IN, OUT>`: Template parameters specify input and output types.
- `model` / `embedding_dim`: Must match your embedding service capabilities.
- `api_key` / `api_url`: Required for remote embedding API access.

