# HADK Development Documentation

Welcome to the HADK framework development documentation!

## What It Is

**HADK (Hybrid Agent Development Kit)** is a C++-based, cross-platform framework for building intelligent agents. Built on computational graph principles, it offers a modular architecture with rich functional nodes and flexible orchestration. Developers can quickly create agents with advanced reasoning, tool integration, and multimodal capabilities that run seamlessly across Windows, Linux, and Android.

## Its Advantages

- **Cross-platform**: Write once, run on Windows, Linux, and Android with a unified API
- **Node-based Architecture**: Computational graph-based orchestration with conditional routing, nested flows, and loops
- **Type Safety**: Compile-time type checking via C++ templates to catch errors early
- **High Performance**: Native compilation with zero-copy optimization and concurrent processing
- **Tool Ecosystem**: Integrate local tools, remote servers (MCP/SSE), or build your own
- **Modular**: Clean separation of concerns for easy extension and reuse

## Development Environment

- **C++ Compiler**: Supports C++17 or higher
- **CMake**: Version 3.24 or higher
- **Operating System**: Windows 10+, Linux (Ubuntu 20.04+), Android (API 21+)

## Quick Start

### Basic Concepts

- [Chat Node](1-1%20Basic%20Concepts%20Chat%20Node.md) - Chat node integrated with large language models
- [Tool Node](1-2%20Basic%20Concepts%20Tool%20Node.md) - Tool management node
- [Custom Node](1-3%20Basic%20Concepts%20DIY%20Node.md) - User-defined node for custom logic
- [CE Node](1-4%20Basic%20Concepts%20CE%20Node.md) - Context engine node for managing conversation history
- [Chain and Flow](1-5%20Basic%20Concepts%20Chain%20Flow.md) - Workflow management
- [Route](6%20Basic%20Concepts%20Route.md) - Routing node

### Application Development

- [Single Node Agent](2-1%20Application%20Development%20Single%20Node%20Agent.md) - Single node agent development example
- [Double Node Agent](2-2%20Application%20Development%20Two%20Node%20Agent.md) - Two node agent development example
- [Triple Node Agent](2-3%20Application%20Development%20Three%20Node%20Agent.md) - Three node agent development example
- [Agent with Specified Tools](2-4%20Application%20Development%20Conditional%20Routing%20Agent%20with%20Tool%20Node.md) - Conditional routing agent with tool node development example
- [Inja Template Formatting](2-5%20Application%20Development%20Inja%20Template%20Formatting.md) - Inja template engine tutorial
- [Agent via CE Node](2-6%20Application%20Development%20Agent%20via%20CE%20Node.md) - Context compression agent development example

## Getting Started

Please select the chapter you're interested in from the left navigation bar to start reading.

## Acknowledgments

Thanks to the following open-source projects for their support:

- [cpr](https://github.com/libcpr/cpr) - HTTP client
- [nlohmann/json](https://github.com/nlohmann/json) - JSON library
- [spdlog](https://github.com/gabime/spdlog) - Logging library
- [yaml-cpp](https://github.com/jbeder/yaml-cpp) - YAML parsing library
- [inja](https://github.com/pantor/inja) - Template engine

## Contact
  - liusong9@lenovo.com
  - zengjl1@lenovo.com
  - moutz1@lenovo.com
  - xufeng8@lenovo.com

