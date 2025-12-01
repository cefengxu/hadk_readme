# Custom Node

## Building a Custom Node

You can build custom processing nodes using `OneFuncNode` to implement arbitrary business logic. Nodes define processing functions through Lambda expressions and support custom input and output types.

### Basic Usage

```c++
auto custom_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
    [&](const std::string& input) -> std::string {
        // Custom processing logic
        std::string processed = process_input(input);
        return processed;
    }
);
```

### Practical Example

The following example shows how to build a text polishing prompt generation node:

```c++
auto polish_prompt_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
    [&](const std::string& draft) -> std::string {
        std::string polish_prompt = 
            "Please rewrite the following draft to make it more friendly and engaging:\n\n" +
            draft + "\n\n"
            "Rewriting requirements:\n"
            "- The tone should be natural, like chatting, warm and infectious\n"
            "- You can add some rhetorical questions to guide readers to think\n"
            "- Appropriately add metaphors or analogies to make the content more vivid\n"
            "- The opening should catch the eye, and the ending should be powerful and memorable\n"
            "Final language: English.\n";
        
        return polish_prompt;
    }
);
```

**Notes:**
- `OneFuncNode<IN, OUT>`: Template parameters specify input and output types respectively
- Lambda expression: Receives input parameters and returns processed output
- Type safety: Compile-time checking of input and output type matching

