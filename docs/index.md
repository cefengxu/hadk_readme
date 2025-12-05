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

- [Chat Node](1-1_BasicConceptsChatNode.md) - Chat node integrated with large language models
- [Tool Node](1-2_BasicConceptsToolNode.md) - Tool management node
- [Custom Node](1-3_BasicConceptsDIYNode.md) - User-defined node for custom logic
- [CE Node](1-4_BasicConceptsCENode.md) - Context engine node for managing conversation history
- [Chain and Flow](1-5_BasicConceptsChainFlow.md) - Workflow management
- [Route](1-6_BasicConceptsRoute.md) - Routing node

### Application Development

- [Single Node Agent](2-1_ApplicationDevelopmentSingleNodeAgent.md) - Single node agent development example
- [Normal Agent](2-2_ApplicationDevelopmentNormalAgent.md) - Normal agent development example
- [Three Node Agent](2-3_ApplicationDevelopmentThreeNodeAgent.md) - Three node agent development example
- [Inja Template Formatting](2-4_ApplicationDevelopmentInjaTemplateFormatting.md) - Inja template engine tutorial
- [CoT Agent](2-5_ApplicationDevelopmentCoTAgent.md) - CoT (Chain of Thought) agent development example
- [Batch Node](2-6_ApplicationDevelopmentBatchNode.md) - Batch Node development example
- [Chat Bot](2-7_ApplicationDevelopmentChatBot.md) - Simple Chat Bot development example

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

