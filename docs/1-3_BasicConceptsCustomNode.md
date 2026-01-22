# Custom Node

## Building a Custom Node

You can build custom processing nodes using `CustomNode` to implement arbitrary business logic. `CustomNode` requires a callback function and supports preprocessor and postprocessor for flexible data transformation.

### Basic Usage

```c++
// Define a callback function: const char* (*)(const char*)
static const char* custom_node_callback(const char* input)
{
    if (input == nullptr) {
        return "";
    }
    static std::string result;
    // Custom processing logic
    result = process_input(input);
    return result.c_str();
}

// Create CustomNode instance
auto custom_node = std::make_shared<custom_node::CustomNode<std::string, std::string>>(
    custom_node_callback
);

// Optional: Set preprocessor for input transformation
custom_node->setPreprocessor([](const std::string& input) -> std::string {
    // Preprocess input before passing to callback
    return input;
});

// Optional: Set postprocessor for output transformation
custom_node->setPostprocessor([](const std::string& output) -> std::string {
    // Postprocess output from callback
    return output;
});

// Configration of Routing to next Node. 
route(custom_node, [&](const std::string&, const std::string& output) -> std::optional<std::string> {
        // setting routing value 'polish'
        return "next_node";
    });
```


**Notes:**

- `CustomNode<IN, OUT>`: Template parameters specify input and output types respectively
- Callback function: Must be of type `const char* (*)(const char*)` and handle the core processing logic
- Preprocessor: Optional function to transform input before passing to callback
- Postprocessor: Optional function to transform output after callback execution
- Type safety: Compile-time checking of input and output type matching

