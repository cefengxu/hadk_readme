# HADK 开发文档

欢迎来到 HADK 框架开发文档！

## 他是什么

**HADK (Hybrid Agent Development Kit)** 是一个基于 C++ 实现的跨平台智能体开发套件，基于《数据结构》中描述的计算图概念，为开发者提供一套完整的、模块化的智能体构建框架。通过提供丰富的功能节点和灵活的节点编排机制，开发者可以快速构建具备复杂推理能力、工具调用能力和多模态交互能力的多平台适配智能体应用。

## 他的优势

- **跨平台**：同一份代码支持 Windows、Linux、Android，统一 API
- **节点化架构**：基于计算图的流程编排，支持条件路由、嵌套流、自循环
- **类型安全**：C++ 模板实现编译期类型检查，减少运行时错误
- **高性能**：原生编译，零拷贝优化，支持并发处理
- **工具生态**：支持本地工具、远程工具服务器（MCP/SSE）和自定义工具
- **模块化**：组件职责清晰，易于扩展和复用

## 开发环境

- **C++ 编译器**：支持 C++17 或更高版本
- **CMake**：3.24 或更高版本
- **操作系统**：Windows 10+、Linux (Ubuntu 20.04+)、Android (API 21+)

## 快速开始

### 基本概念

- [Chat Node](1%20基本概念%20Chat%20Node.md) - 集成大语言模型的聊天节点
- [Tool Node](2%20基本概念%20Tool%20Node.md) - 工具管理节点
- [DIY Node](3%20基本概念%20DIY%20Node.md) - 自定义节点
- [路由 Route](4%20基本概念%20路由%20Route.md) - 路由节点
- [链和流 Chain Flow](5%20基本概念%20链和流%20Chain%20Flow.md) - 工作流管理

### 应用开发

- [单节点智能体](6%20应用开发%20单节点智能体.md) - 单节点智能体开发示例
- [双节点智能体](7%20应用开发%20双节点智能体.md) - 双节点智能体开发示例
- [三节点智能体](8%20应用开发%20三节点智能体.md) - 三节点智能体开发示例
- [指定工具的智能体](9%20应用开发%20使用工具节点的条件路由智能体.md) - 使用工具节点的条件路由智能体开发示例

## 开始使用

请从左侧导航栏选择您感兴趣的章节开始阅读。

## 致谢

感谢以下开源项目的支持：

- [cpr](https://github.com/libcpr/cpr) - HTTP 客户端
- [nlohmann/json](https://github.com/nlohmann/json) - JSON 库
- [spdlog](https://github.com/gabime/spdlog) - 日志库
- [yaml-cpp](https://github.com/jbeder/yaml-cpp) - YAML 解析库
- [inja](https://github.com/pantor/inja) - 模板引擎

## 联系方式
  - liusong9@lenovo.com
  - zengjl1@lenovo.com
  - xufeng8@lenovo.com
