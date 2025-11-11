# 路由（Route）

路由机制用于根据节点的输入和输出动态决定工作流的执行路径。通过 `route` 函数配合 `chain` 函数，可以实现条件分支和循环控制。

## 路由函数

每个节点都支持通过 `route` 函数设置路由逻辑。路由函数基于 Lambda 表达式实现，接收节点的输入和输出作为参数，返回下一步执行的 action 标识。

### 函数签名

```c++
template <typename Node, typename Selector>
void route(
    const std::shared_ptr<Node>& node, 
    Selector selector
);
```

**参数说明：**
- `node`：要设置路由的节点
- `selector`：路由选择器函数，类型为 `std::function<std::optional<std::string>(const IN&, const OUT&)>`

**返回值：**
- `std::optional<std::string>`：返回 action 字符串表示下一步执行路径，返回 `std::nullopt` 表示使用默认连接

### 示例 1：基于决策结果的路由

```c++
route(decide_node, [&](const std::string& input, const std::string& output) -> std::optional<std::string> {
    // 解析输出中的决策信息
    if (g_yaml_node["action"].as<std::string>() == "search") {
        return "search";  // 路由到搜索节点
    }
    if (g_yaml_node["action"].as<std::string>() == "answer") {
        return "answer";  // 路由到回答节点
    }
    return std::nullopt;  // 使用默认路由
});
```

### 示例 2：基于验证结果的路由

```c++
route(supervisor_node, [&](const std::string& input, const std::string& output) -> std::optional<std::string> {
    if (g_validation_result.valid) {
        return "done";   // 验证通过，路由到完成节点
    } else {
        return "retry"; // 验证失败，路由到重试节点
    }
});
```
