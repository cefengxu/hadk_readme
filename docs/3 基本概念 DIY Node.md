# 自定义节点（DIY Node）

## 构建自定义节点

通过 `OneFuncNode` 可以构建自定义处理节点，实现任意业务逻辑。节点通过 Lambda 表达式定义处理函数，支持自定义输入输出类型。

### 基本用法

```c++
auto custom_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
    [&](const std::string& input) -> std::string {
        // 自定义处理逻辑
        std::string processed = process_input(input);
        return processed;
    }
);
```

### 实际示例

以下示例展示如何构建一个文本润色提示词生成节点：

```c++
auto polish_prompt_node = std::make_shared<nodeflow::OneFuncNode<std::string, std::string>>(
    [&](const std::string& draft) -> std::string {
        std::string polish_prompt = 
            "请你把下面这段初稿改写一下，让它更有亲和力、更吸引人:\n\n" +
            draft + "\n\n"
            "改写要求:\n"
            "- 语气要自然、像聊天一样，温暖有感染力\n"
            "- 可以加入一些反问句，引导读者思考\n"
            "- 适当加入比喻或类比，让内容更生动\n"
            "- 开头要抓人眼球，结尾要有力、让人印象深刻\n"
            "最后呈现的语言:中文。\n";
        
        return polish_prompt;
    }
);
```

**说明：**
- `OneFuncNode<IN, OUT>`：模板参数分别指定输入类型和输出类型
- Lambda 表达式：接收输入参数，返回处理后的输出
- 类型安全：编译时检查输入输出类型匹配
