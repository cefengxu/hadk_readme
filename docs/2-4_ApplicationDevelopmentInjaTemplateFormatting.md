# Inja Template Formatting Tutorial

## Overview

Inja is a powerful C++ template engine. The HADK framework provides convenient template formatting functionality through the `ChatUtils::format_inja` function. Using Inja templates, you can easily insert variable values into template strings to achieve dynamic content generation.

## Basic Usage

### Function Signature

```c++
std::string ChatUtils::format_inja(
    const std::string& template_str,
    const std::unordered_map<std::string, std::any>& variables
);
```

**Parameter Description:**
- `template_str`: Template string using `{{variable_name}}` syntax to define placeholders
- `variables`: Variable map, where keys are variable names and values are corresponding variable values (supports multiple types)

**Return Value:**
- Formatted string

### Template Syntax

Inja templates use double curly braces `{{variable_name}}` to define placeholders. The template engine replaces placeholders with corresponding variable values.

## Examples

### Example 1: Simple Context Formatting

This is the most basic usage, demonstrating how to use string variables for template replacement:

```c++
#include <chat_utils.h>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <any>

std::string simple_template = R"(
Hello, {{name}}!

Today is a {{weather}} {{time}}.

Based on your {{topic}}, I've prepared the following content for you:

{{content}}

I hope this information is helpful!
)";

std::unordered_map<std::string, std::any> simple_variables;
simple_variables["name"] = std::string("Xiao Ming");
simple_variables["weather"] = std::string("sunny");
simple_variables["time"] = std::string("morning");
simple_variables["topic"] = std::string("study plan");
simple_variables["content"] = std::string("1. Complete math homework\n2. Read English articles\n3. Review history knowledge");

try {
    std::string formatted_simple = ChatUtils::format_inja(simple_template, simple_variables);
    std::cout << formatted_simple << "\n";
} catch (const std::exception& e) {
    std::cerr << "Formatting error: " << e.what() << std::endl;
}
```

**Output Result:**

```
Hello, Xiao Ming!

Today is a sunny morning.

Based on your study plan, I've prepared the following content for you:

1. Complete math homework
2. Read English articles
3. Review history knowledge

I hope this information is helpful!
```

### Example 2: Summary Formatting (Reference: deepsearch.cpp)

This example demonstrates how to build complex prompt templates, suitable for multi-iteration summary scenarios:

```c++
std::string summary_template = R"(
Task

You need to summarize information around a theme. Theme: `{{topic}}`

Workflow

1. Carefully read all information, combine with the theme to understand and fully comprehend the context.

2. Select content related to the theme and summarize the selected content.

3. If the theme is question-based, you need to summarize and infer relevant answers, otherwise summarize normally based on the theme.

Requirements

- The word count must not be less than {{min_words}} words, must be as many as possible.

- The summarized content must be from the information provided, you cannot make things up, especially time-related information.

- The summarized content must be comprehensive enough.

- Logical coherence, smooth sentences.

- Provide the final result directly in markdown format.

Information to Summarize

```{{summary_search}}```
)";

std::unordered_map<std::string, std::any> summary_variables;
summary_variables["topic"] = std::string("History of Artificial Intelligence Development");
summary_variables["min_words"] = 3500;

// Simulate multi-iteration summary content
std::vector<std::string> all_iteration_summary = {
    "First search: The concept of artificial intelligence was first proposed by John McCarthy in 1956.",
    "Second search: Deep learning technology made breakthrough progress in the 2010s.",
    "Third search: Large language models such as the GPT series attracted widespread attention in the 2020s."
};

// Connect multiple summaries with separators
std::string all_iteration_summary_str;
for (size_t i = 0; i < all_iteration_summary.size(); ++i) {
    all_iteration_summary_str += all_iteration_summary[i];
    if (i < all_iteration_summary.size() - 1) {
        all_iteration_summary_str += "\n---\n";
    }
}
summary_variables["summary_search"] = all_iteration_summary_str;

try {
    std::string formatted_summary = ChatUtils::format_inja(summary_template, summary_variables);
    std::cout << formatted_summary << "\n";
} catch (const std::exception& e) {
    std::cerr << "Formatting error: " << e.what() << std::endl;
}
```

**Output Result:**

```
Task

You need to summarize information around a theme. Theme: `History of Artificial Intelligence Development`

Workflow

1. Carefully read all information, combine with the theme to understand and fully comprehend the context.

2. Select content related to the theme and summarize the selected content.

3. If the theme is question-based, you need to summarize and infer relevant answers, otherwise summarize normally based on the theme.

Requirements

- The word count must not be less than 3500 words, must be as many as possible.

- The summarized content must be from the information provided, you cannot make things up, especially time-related information.

- The summarized content must be comprehensive enough.

- Logical coherence, smooth sentences.

- Provide the final result directly in markdown format.

Information to Summarize

```First search: The concept of artificial intelligence was first proposed by John McCarthy in 1956.
---
Second search: Deep learning technology made breakthrough progress in the 2010s.
---
Third search: Large language models such as the GPT series attracted widespread attention in the 2020s.```
```

### Example 3: Using Different Types of Variables

Inja templates support variables of multiple data types, including strings, integers, floating-point numbers, booleans, and container types:

```c++
std::string mixed_template = R"(
User Information:

- Name: {{name}}
- Age: {{age}}
- VIP Status: {{is_vip}}
- Points: {{points}}
- Tags: {{tags}}
)";

std::unordered_map<std::string, std::any> mixed_variables;
mixed_variables["name"] = std::string("Zhang San");
mixed_variables["age"] = 28;
mixed_variables["is_vip"] = true;
mixed_variables["points"] = 1250.5;

std::vector<std::string> tags = {"Active User", "Tech Enthusiast", "Early User"};
mixed_variables["tags"] = tags;

try {
    std::string formatted_mixed = ChatUtils::format_inja(mixed_template, mixed_variables);
    std::cout << formatted_mixed << "\n";
} catch (const std::exception& e) {
    std::cerr << "Formatting error: " << e.what() << std::endl;
}
```

**Output Result:**

```
User Information:

- Name: Zhang San
- Age: 28
- VIP Status: true
- Points: 1250.5
- Tags: Active User, Tech Enthusiast, Early User
```

## Complete Example Program

The following is a complete example program demonstrating all three examples:

```c++
#include <chat_utils.h>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <any>

int main()
{
    std::cout << "=== Inja Template Formatting Examples === \n";
    
    // Example 1: Simple context formatting
    std::cout << "【Example 1】Simple Context Formatting\n";
    std::string simple_template = R"(
Hello, {{name}}!

Today is a {{weather}} {{time}}.

Based on your {{topic}}, I've prepared the following content for you:

{{content}}

I hope this information is helpful!

)";

    std::unordered_map<std::string, std::any> simple_variables;
    simple_variables["name"] = std::string("Xiao Ming");
    simple_variables["weather"] = std::string("sunny");
    simple_variables["time"] = std::string("morning");
    simple_variables["topic"] = std::string("study plan");
    simple_variables["content"] = std::string("1. Complete math homework\n2. Read English articles\n3. Review history knowledge");

    try {
        std::string formatted_simple = ChatUtils::format_inja(simple_template, simple_variables);
        std::cout << formatted_simple << "\n";
    } catch (const std::exception& e) {
        std::cerr << "Formatting error: " << e.what() << std::endl;
    }

    std::cout << "\n" << std::string(50, '-') << "\n";

    // Example 2: Summary formatting similar to deepsearch.cpp
    std::cout << "【Example 2】Summary Formatting (Reference: deepsearch.cpp)\n";
    std::string summary_template = R"(
Task

You need to summarize information around a theme. Theme: `{{topic}}`

Workflow

1. Carefully read all information, combine with the theme to understand and fully comprehend the context.

2. Select content related to the theme and summarize the selected content.

3. If the theme is question-based, you need to summarize and infer relevant answers, otherwise summarize normally based on the theme.

Requirements

- The word count must not be less than {{min_words}} words, must be as many as possible.

- The summarized content must be from the information provided, you cannot make things up, especially time-related information.

- The summarized content must be comprehensive enough.

- Logical coherence, smooth sentences.

- Provide the final result directly in markdown format.

Information to Summarize

```{{summary_search}}```

)";

    std::unordered_map<std::string, std::any> summary_variables;
    summary_variables["topic"] = std::string("History of Artificial Intelligence Development");
    summary_variables["min_words"] = 3500;
    
    // Simulate multi-iteration summary content
    std::vector<std::string> all_iteration_summary = {
        "First search: The concept of artificial intelligence was first proposed by John McCarthy in 1956.",
        "Second search: Deep learning technology made breakthrough progress in the 2010s.",
        "Third search: Large language models such as the GPT series attracted widespread attention in the 2020s."
    };
    
    // Connect multiple summaries with separators
    std::string all_iteration_summary_str;
    for (size_t i = 0; i < all_iteration_summary.size(); ++i) {
        all_iteration_summary_str += all_iteration_summary[i];
        if (i < all_iteration_summary.size() - 1) {
            all_iteration_summary_str += "\n---\n";
        }
    }
    summary_variables["summary_search"] = all_iteration_summary_str;

    try {
        std::string formatted_summary = ChatUtils::format_inja(summary_template, summary_variables);
        std::cout << formatted_summary << "\n";
    } catch (const std::exception& e) {
        std::cerr << "Formatting error: " << e.what() << std::endl;
    }

    std::cout << "\n" << std::string(50, '-') << "\n";

    // Example 3: Using different types of variables
    std::cout << "【Example 3】Using Different Types of Variables\n";
    std::string mixed_template = R"(
User Information:

- Name: {{name}}
- Age: {{age}}
- VIP Status: {{is_vip}}
- Points: {{points}}
- Tags: {{tags}}

)";

    std::unordered_map<std::string, std::any> mixed_variables;
    mixed_variables["name"] = std::string("Zhang San");
    mixed_variables["age"] = 28;
    mixed_variables["is_vip"] = true;
    mixed_variables["points"] = 1250.5;
    
    std::vector<std::string> tags = {"Active User", "Tech Enthusiast", "Early User"};
    mixed_variables["tags"] = tags;

    try {
        std::string formatted_mixed = ChatUtils::format_inja(mixed_template, mixed_variables);
        std::cout << formatted_mixed << "\n";
    } catch (const std::exception& e) {
        std::cerr << "Formatting error: " << e.what() << std::endl;
    }

    std::cout << "\n=== Examples Complete ===\n";
    
    return 0;
}
```

## Supported Variable Types

The `ChatUtils::format_inja` function supports the following variable types:

- **String** (`std::string`): The most commonly used type, directly replaced in the template
- **Integer** (`int`, `long`, `long long`, etc.): Automatically converted to string
- **Floating-point** (`float`, `double`): Automatically converted to string
- **Boolean** (`bool`): Converted to "true" or "false"
- **Container Types** (`std::vector<T>`): Automatically converted to comma-separated string

## Error Handling

When template formatting fails, the `format_inja` function throws a `std::exception` exception. It's recommended to use `try-catch` blocks to catch exceptions and perform appropriate error handling:

```c++
try {
    std::string result = ChatUtils::format_inja(template_str, variables);
    // Use formatted result
} catch (const std::exception& e) {
    std::cerr << "Template formatting error: " << e.what() << std::endl;
    // Handle error situation
}
```

## Best Practices

1. **Use Raw String Literals**: Use `R"(...)"` syntax to define template strings, which preserves newlines and special characters, improving readability

2. **Variable Naming Conventions**: Use meaningful variable names for easier understanding and maintenance

3. **Error Handling**: Always use `try-catch` blocks to catch possible exceptions

4. **Template Reuse**: Define commonly used templates as constants or functions for easy reuse

5. **Type Safety**: Ensure variable types match the usage scenarios in templates

## Application Scenarios

Inja template formatting is commonly used in the HADK framework for the following scenarios:

- **Prompt Construction**: Dynamically build LLM prompts, generating different prompts based on context and task requirements
- **Message Formatting**: Format user messages, system messages, etc.
- **Summary Generation**: Build multi-iteration summary prompts
- **Tool Invocation Parameters**: Dynamically generate parameter descriptions for tool invocations

## Reference Resources

- [Inja Official Documentation](https://github.com/pantor/inja)
- [HADK Framework Documentation](index.md)

