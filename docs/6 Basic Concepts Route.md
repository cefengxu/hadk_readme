# Route

The routing mechanism is used to dynamically determine the execution path of a workflow based on node input and output. Through the `route` function combined with the `chain` function, conditional branching and loop control can be implemented.

## Route Function

Each node supports setting routing logic through the `route` function. The route function is implemented based on Lambda expressions, receiving the node's input and output as parameters, and returning the action identifier for the next step.

### Function Signature

```c++
template <typename Node, typename Selector>
void route(
    const std::shared_ptr<Node>& node, 
    Selector selector
);
```

**Parameter Description:**
- `node`: The node to set routing for
- `selector`: Route selector function, type is `std::function<std::optional<std::string>(const IN&, const OUT&)>`

**Return Value:**
- `std::optional<std::string>`: Returns an action string representing the next execution path, returns `std::nullopt` to use the default connection

### Example 1: Routing Based on Decision Results

```c++
route(decide_node, [&](const std::string& input, const std::string& output) -> std::optional<std::string> {
    // Parse decision information from output
    if (g_yaml_node["action"].as<std::string>() == "search") {
        return "search";  // Route to search node
    }
    if (g_yaml_node["action"].as<std::string>() == "answer") {
        return "answer";  // Route to answer node
    }
    return std::nullopt;  // Use default route
});
```

### Example 2: Routing Based on Validation Results

```c++
route(supervisor_node, [&](const std::string& input, const std::string& output) -> std::optional<std::string> {
    if (g_validation_result.valid) {
        return "done";   // Validation passed, route to completion node
    } else {
        return "retry"; // Validation failed, route to retry node
    }
});
```

