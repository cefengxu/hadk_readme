# Chain

The `chain` function is used to connect two nodes, creating a data flow path between nodes. An optional `action` parameter can be specified to create conditional connections.

**Function Signature:**

```c++
template <typename NodeA, typename NodeB>
void chain(
    const std::shared_ptr<NodeA>& a,      // Source node
    const std::shared_ptr<NodeB>& b,      // Target node
    std::optional<std::string> action = std::nullopt  // Optional action identifier
);
```

**How It Works:**

- When the `action` parameter is `std::nullopt`, it creates a **default connection** (unconditional connection)
- When the `action` parameter has a value, it creates a **conditional connection**, which only executes when the action value returned by the source node's `route` function matches the action specified in `chain`

**Usage Example:**

```c++
// Set routing: determine the returned action based on node output
route(decide_node, [](const std::string&, const std::string&) -> std::optional<std::string> {
    // Return different actions based on business logic
    return "search";
});

// Create conditional connection: execute this connection when route returns "search"
chain(decide_node, search_node, "search");

// Create conditional connection: execute this connection when route returns "answer"
chain(decide_node, answer_node, "answer");

// Create default connection: execute unconditionally (used when route returns std::nullopt)
chain(decide_node, default_node);
```

**Notes:**
- The route function is called after the node execution completes
- The returned action value must match the action specified in `chain`
- When returning `std::nullopt`, use the default connection (chain without action parameter)

# Flow

Flow is the execution container for workflows, used in conjunction with Chain. It is responsible for managing node execution order and data flow. Through Flow, multiple nodes can be organized into a complete execution flow.

## Basic Concepts of Flow

- **Workflow Container**: Flow is the execution container for nodes, managing node lifecycle and execution order
- **Start Node**: Each Flow must specify a start node as the workflow entry point
- **Automatic Execution**: Flow automatically executes the workflow based on connections between nodes
- **Type Safety**: Flow supports typed input and output, ensuring type safety

## Creating and Executing Workflows

### 1. Create Flow Object

Use `std::make_shared` to create a Flow object:

```c++
auto f = std::make_shared<nodeflow::Flow>();
```

### 2. Set Start Node

Specify the workflow's start node through the `start` method:

```c++
f->start(decide_node);  // decide_node as the workflow entry point
```

### 3. Execute Workflow

Use the `runWithInput` method to execute the workflow:

```c++
auto result = f->runWithInput<std::string, std::string>(input);
```

**Function Signature:**

```c++
template <typename IN, typename OUT>
OUT runWithInput(const IN& input);
```

**Parameter Description:**
- Template parameter `IN`: Input data type (i.e., the first node's input)
- Template parameter `OUT`: Output data type
- `input`: Actual input data

**Return Value:**
- The workflow's final output result, type is `OUT`

