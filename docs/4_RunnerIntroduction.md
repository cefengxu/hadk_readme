# Runner Framework Introduction

## Overview

Runner is a lightweight task management framework for managing and executing Agent tasks in HADK. It provides a unified task lifecycle management interface with safe cross-DLL boundary calls.

**Core Features:**
- **ABI Safe**: Uses pure C interfaces and pure virtual interfaces to avoid ABI compatibility issues across DLL boundaries
- **Simplified Registration**: Automatically registers task classes through the `REGISTER_TASK` macro
- **Lifecycle Management**: Provides complete task initialization, execution, and cleanup flow
- **Structured History**: Supports structured conversation history format `[[S],[U,A],[U,A,T,A]]`

## Core Concepts

### Task Class

Task classes need to inherit from `hybrid_runner::task_base` and implement the `run()` method:

```cpp
class MyTask : public hybrid_runner::task_base
{
protected:
    std::string run(const char* input) override
    {
        // Process input and return result
        return "result";
    }
};
```

### Task Registration

Use the `REGISTER_TASK` macro to register task classes:

```cpp
namespace
{
    class MyTask : public hybrid_runner::task_base
    {
        // ... implementation
    };
    
    REGISTER_TASK("MyTask", MyTask);
}
```

### C API Interface

Runner provides pure C interfaces for task management:

- `runner_init(class_name, key)`: Initialize a task instance and return a key
- `runner_run(key, history, input)`: Execute the task and return the result
- `runner_release(key)`: Release the task instance

## API Reference

### C API Functions

#### `runner_init`

```cpp
const char* runner_init(const char* class_name, const char* key);
```

Initialize a task instance.

- **Parameters:**
  - `class_name`: Task class name (the name used during registration)
  - `key`: Optional, if provided, uses the specified key; otherwise, automatically generates one
- **Returns:** The key of the task instance, returns `nullptr` on failure

#### `runner_run`

```cpp
const char* runner_run(const char* key, const char* history, const char* input);
```

Execute the task.

- **Parameters:**
  - `key`: The key of the task instance (returned by `runner_init`)
  - `history`: Conversation history in JSON format `[[S],[U,A],[U,A,T,A]]`
  - `input`: Current user input
- **Returns:** Task execution result (string pointer)

#### `runner_release`

```cpp
void runner_release(const char* key);
```

Release the task instance.

- **Parameters:**
  - `key`: The key of the task instance

### C++ Helper Classes

#### `hybrid_runner::task_base`

Task base class that simplifies task implementation:

```cpp
namespace hybrid_runner
{
    class task_base : public i_task
    {
    protected:
        // Users only need to implement this method
        virtual std::string run(const char* input) = 0;
    };
}
```

#### `REGISTER_TASK` Macro

Macro that simplifies task registration:

```cpp
#define REGISTER_TASK(NAME, TYPE) \
    static hybrid_runner::registrar<TYPE> registrar_##TYPE(NAME);
```

## Conversation History Format

Runner supports a structured conversation history format, where each inner array represents a complete conversation turn:

- `[[S]]`: System message
- `[[S],[U,A]]`: System message + user-assistant turn
- `[[S],[U,A],[U,A,T,A]]`: System message + multiple turns, including tool calls

Where:
- `S`: System message
- `U`: User message
- `A`: Assistant message
- `T`: Tool call


## Key Points

1. **Anonymous Namespace**: Task classes are typically defined in anonymous namespaces to avoid exposing implementation details
2. **Thread Safety**: The `run()` method can use `thread_local` to store results, ensuring thread safety
3. **Memory Management**: Runner is responsible for managing the lifecycle of task instances; users don't need to manage them manually
4. **Error Handling**: `runner_init` returns `nullptr` on failure; the return value should be checked
5. **History Format**: Conversation history must be valid JSON format that meets the structured requirements

## Best Practices

1. **Task Registration**: Use the `REGISTER_TASK` macro to register tasks in anonymous namespaces
2. **Error Handling**: Always check the return value of `runner_init`
3. **Resource Cleanup**: Call `runner_release` to release resources after using the task
4. **Thread Safety**: Use `thread_local` to store temporary results in multi-threaded environments
5. **History Management**: Properly construct and pass conversation history, ensuring correct format
