# Inja 模板格式化教程

## 概述

Inja 是一个功能强大的 C++ 模板引擎，HADK 框架通过 `ChatUtils::format_inja` 函数提供了便捷的模板格式化功能。使用 Inja 模板可以轻松地将变量值插入到模板字符串中，实现动态内容生成。

## 基本用法

### 函数签名

```c++
std::string ChatUtils::format_inja(
    const std::string& template_str,
    const std::unordered_map<std::string, std::any>& variables
);
```

**参数说明：**
- `template_str`：模板字符串，使用 `{{变量名}}` 语法定义占位符
- `variables`：变量映射表，键为变量名，值为对应的变量值（支持多种类型）

**返回值：**
- 格式化后的字符串

### 模板语法

Inja 模板使用双大括号 `{{变量名}}` 来定义占位符，模板引擎会将占位符替换为对应的变量值。

## 示例

### 示例1：简单的上下文格式化

这是最基本的用法，展示如何使用字符串变量进行模板替换：

```c++
#include <chat_utils.h>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <any>

std::string simple_template = R"(
你好，{{name}}！

今天是一个{{weather}}的{{time}}。

根据你的{{topic}}，我为你准备了以下内容：

{{content}}

希望这些信息对你有帮助！
)";

std::unordered_map<std::string, std::any> simple_variables;
simple_variables["name"] = std::string("小明");
simple_variables["weather"] = std::string("晴朗");
simple_variables["time"] = std::string("上午");
simple_variables["topic"] = std::string("学习计划");
simple_variables["content"] = std::string("1. 完成数学作业\n2. 阅读英语文章\n3. 复习历史知识");

try {
    std::string formatted_simple = ChatUtils::format_inja(simple_template, simple_variables);
    std::cout << formatted_simple << "\n";
} catch (const std::exception& e) {
    std::cerr << "格式化错误: " << e.what() << std::endl;
}
```

**输出结果：**

```
你好，小明！

今天是一个晴朗的上午。

根据你的学习计划，我为你准备了以下内容：

1. 完成数学作业
2. 阅读英语文章
3. 复习历史知识

希望这些信息对你有帮助！
```

### 示例2：总结格式化（参考 deepsearch.cpp）

这个示例展示了如何构建复杂的提示词模板，适用于多轮迭代的总结场景：

```c++
std::string summary_template = R"(
任务

需要你根据信息围绕主题进行总结。主题：`{{topic}}`

工作流

1、仔细阅读所有信息，结合主题阅读理解，充分理解上下文。

2、选出跟主题相关的内容，对选出内容进行总结。

3、如果主题是问题类的，需要总结推理出相关答案，否则正常根据主题进行总结即可。

要求

- 要求字数不能少于 {{min_words}} 字，必须尽可能多。

- 总结的内容必须是信息里面的内容，不能自己发挥，尤其是时间之类的信息。

- 总结的内容必须要点足够全面。

- 逻辑连贯，语句通顺。

- 直接以 markdown 格式给出最后结果。

需要总结的信息

```{{summary_search}}```
)";

std::unordered_map<std::string, std::any> summary_variables;
summary_variables["topic"] = std::string("人工智能的发展历史");
summary_variables["min_words"] = 3500;

// 模拟多轮迭代的总结内容
std::vector<std::string> all_iteration_summary = {
    "第一轮搜索：人工智能概念最早由约翰·麦卡锡在1956年提出。",
    "第二轮搜索：深度学习技术在2010年代取得了突破性进展。",
    "第三轮搜索：大语言模型如GPT系列在2020年代引起了广泛关注。"
};

// 将多个总结用分隔符连接
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
    std::cerr << "格式化错误: " << e.what() << std::endl;
}
```

**输出结果：**

```
任务

需要你根据信息围绕主题进行总结。主题：`人工智能的发展历史`

工作流

1、仔细阅读所有信息，结合主题阅读理解，充分理解上下文。

2、选出跟主题相关的内容，对选出内容进行总结。

3、如果主题是问题类的，需要总结推理出相关答案，否则正常根据主题进行总结即可。

要求

- 要求字数不能少于 3500 字，必须尽可能多。

- 总结的内容必须是信息里面的内容，不能自己发挥，尤其是时间之类的信息。

- 总结的内容必须要点足够全面。

- 逻辑连贯，语句通顺。

- 直接以 markdown 格式给出最后结果。

需要总结的信息

```第一轮搜索：人工智能概念最早由约翰·麦卡锡在1956年提出。
---
第二轮搜索：深度学习技术在2010年代取得了突破性进展。
---
第三轮搜索：大语言模型如GPT系列在2020年代引起了广泛关注。```
```

### 示例3：使用不同类型的变量

Inja 模板支持多种数据类型的变量，包括字符串、整数、浮点数、布尔值和容器类型：

```c++
std::string mixed_template = R"(
用户信息：

- 姓名: {{name}}
- 年龄: {{age}}
- 是否VIP: {{is_vip}}
- 积分: {{points}}
- 标签: {{tags}}
)";

std::unordered_map<std::string, std::any> mixed_variables;
mixed_variables["name"] = std::string("张三");
mixed_variables["age"] = 28;
mixed_variables["is_vip"] = true;
mixed_variables["points"] = 1250.5;

std::vector<std::string> tags = {"活跃用户", "技术爱好者", "早期用户"};
mixed_variables["tags"] = tags;

try {
    std::string formatted_mixed = ChatUtils::format_inja(mixed_template, mixed_variables);
    std::cout << formatted_mixed << "\n";
} catch (const std::exception& e) {
    std::cerr << "格式化错误: " << e.what() << std::endl;
}
```

**输出结果：**

```
用户信息：

- 姓名: 张三
- 年龄: 28
- 是否VIP: true
- 积分: 1250.5
- 标签: 活跃用户, 技术爱好者, 早期用户
```

## 完整示例程序

以下是一个完整的示例程序，展示了所有三个示例的使用：

```c++
#include <chat_utils.h>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <any>

int main()
{
    std::cout << "=== Inja 模板格式化示例 === \n";
    
    // 示例1: 简单的上下文格式化
    std::cout << "【示例1】简单的上下文格式化\n";
    std::string simple_template = R"(
你好，{{name}}！

今天是一个{{weather}}的{{time}}。

根据你的{{topic}}，我为你准备了以下内容：

{{content}}

希望这些信息对你有帮助！

)";

    std::unordered_map<std::string, std::any> simple_variables;
    simple_variables["name"] = std::string("小明");
    simple_variables["weather"] = std::string("晴朗");
    simple_variables["time"] = std::string("上午");
    simple_variables["topic"] = std::string("学习计划");
    simple_variables["content"] = std::string("1. 完成数学作业\n2. 阅读英语文章\n3. 复习历史知识");

    try {
        std::string formatted_simple = ChatUtils::format_inja(simple_template, simple_variables);
        std::cout << formatted_simple << "\n";
    } catch (const std::exception& e) {
        std::cerr << "格式化错误: " << e.what() << std::endl;
    }

    std::cout << "\n" << std::string(50, '-') << "\n";

    // 示例2: 类似 deepsearch.cpp 的总结格式化
    std::cout << "【示例2】总结格式化（参考 deepsearch.cpp）\n";
    std::string summary_template = R"(
任务

需要你根据信息围绕主题进行总结。主题：`{{topic}}`

工作流

1、仔细阅读所有信息，结合主题阅读理解，充分理解上下文。

2、选出跟主题相关的内容，对选出内容进行总结。

3、如果主题是问题类的，需要总结推理出相关答案，否则正常根据主题进行总结即可。

要求

- 要求字数不能少于 {{min_words}} 字，必须尽可能多。

- 总结的内容必须是信息里面的内容，不能自己发挥，尤其是时间之类的信息。

- 总结的内容必须要点足够全面。

- 逻辑连贯，语句通顺。

- 直接以 markdown 格式给出最后结果。

需要总结的信息

```{{summary_search}}```

)";

    std::unordered_map<std::string, std::any> summary_variables;
    summary_variables["topic"] = std::string("人工智能的发展历史");
    summary_variables["min_words"] = 3500;
    
    // 模拟多轮迭代的总结内容
    std::vector<std::string> all_iteration_summary = {
        "第一轮搜索：人工智能概念最早由约翰·麦卡锡在1956年提出。",
        "第二轮搜索：深度学习技术在2010年代取得了突破性进展。",
        "第三轮搜索：大语言模型如GPT系列在2020年代引起了广泛关注。"
    };
    
    // 将多个总结用分隔符连接
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
        std::cerr << "格式化错误: " << e.what() << std::endl;
    }

    std::cout << "\n" << std::string(50, '-') << "\n";

    // 示例3: 使用不同类型的变量
    std::cout << "【示例3】使用不同类型的变量\n";
    std::string mixed_template = R"(
用户信息：

- 姓名: {{name}}
- 年龄: {{age}}
- 是否VIP: {{is_vip}}
- 积分: {{points}}
- 标签: {{tags}}

)";

    std::unordered_map<std::string, std::any> mixed_variables;
    mixed_variables["name"] = std::string("张三");
    mixed_variables["age"] = 28;
    mixed_variables["is_vip"] = true;
    mixed_variables["points"] = 1250.5;
    
    std::vector<std::string> tags = {"活跃用户", "技术爱好者", "早期用户"};
    mixed_variables["tags"] = tags;

    try {
        std::string formatted_mixed = ChatUtils::format_inja(mixed_template, mixed_variables);
        std::cout << formatted_mixed << "\n";
    } catch (const std::exception& e) {
        std::cerr << "格式化错误: " << e.what() << std::endl;
    }

    std::cout << "\n=== 示例完成 ===\n";
    
    return 0;
}
```

## 支持的变量类型

`ChatUtils::format_inja` 函数支持以下类型的变量：

- **字符串** (`std::string`)：最常用的类型，直接替换到模板中
- **整数** (`int`, `long`, `long long` 等)：自动转换为字符串
- **浮点数** (`float`, `double`)：自动转换为字符串
- **布尔值** (`bool`)：转换为 "true" 或 "false"
- **容器类型** (`std::vector<T>`)：自动转换为逗号分隔的字符串

## 错误处理

当模板格式化失败时，`format_inja` 函数会抛出 `std::exception` 异常。建议使用 `try-catch` 块捕获异常并进行适当的错误处理：

```c++
try {
    std::string result = ChatUtils::format_inja(template_str, variables);
    // 使用格式化后的结果
} catch (const std::exception& e) {
    std::cerr << "模板格式化错误: " << e.what() << std::endl;
    // 处理错误情况
}
```

## 最佳实践

1. **使用原始字符串字面量**：使用 `R"(...)"` 语法定义模板字符串，可以保留换行和特殊字符，提高可读性

2. **变量命名规范**：使用有意义的变量名，便于理解和维护

3. **错误处理**：始终使用 `try-catch` 块捕获可能的异常

4. **模板复用**：将常用的模板定义为常量或函数，便于复用

5. **类型安全**：确保变量类型与模板中的使用场景匹配

## 应用场景

Inja 模板格式化在 HADK 框架中常用于以下场景：

- **提示词构建**：动态构建 LLM 的提示词，根据上下文和任务需求生成不同的提示
- **消息格式化**：格式化用户消息、系统消息等
- **总结生成**：构建多轮迭代的总结提示词
- **工具调用参数**：动态生成工具调用的参数描述

## 参考资源

- [Inja 官方文档](https://github.com/pantor/inja)
- [HADK 框架文档](index.md)

