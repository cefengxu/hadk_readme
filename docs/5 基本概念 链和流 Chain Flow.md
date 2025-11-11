# 链 Chain

`chain` 函数用于连接两个节点，创建节点之间的数据流转路径。可以指定可选的 `action` 参数来创建条件连接。

**函数签名：**

```c++
template <typename NodeA, typename NodeB>
void chain(
    const std::shared_ptr<NodeA>& a,      // 源节点
    const std::shared_ptr<NodeB>& b,      // 目标节点
    std::optional<std::string> action = std::nullopt  // 可选的 action 标识
);
```

**工作原理：**

- 当 `action` 参数为 `std::nullopt` 时，创建**默认连接**（无条件连接）
- 当 `action` 参数有值时，创建**条件连接**，只有当源节点的 `route` 函数返回的 action 值与 `chain` 中指定的 action 匹配时，才会执行该连接

**使用示例：**

```c++
// 设置路由：根据节点输出决定返回的 action
route(decide_node, [](const std::string&, const std::string&) -> std::optional<std::string> {
    // 根据业务逻辑返回不同的 action
    return "search";
});

// 创建条件连接：当 route 返回 "search" 时，执行此连接
chain(decide_node, search_node, "search");

// 创建条件连接：当 route 返回 "answer" 时，执行此连接
chain(decide_node, answer_node, "answer");

// 创建默认连接：无条件执行（当 route 返回 std::nullopt 时使用）
chain(decide_node, default_node);
```

**注意事项：**
- 路由函数在节点执行完成后调用
- 返回的 action 值必须与 `chain` 中指定的 action 匹配
- 返回 `std::nullopt` 时使用默认连接（无 action 参数的 chain）

# 工作流（Flow）

Flow 是工作流的执行容器，与 Chain 配合使用。负责管理节点的执行顺序和数据流转。通过 Flow，可以将多个节点组织成一个完整的执行流程。

## Flow 的基本概念

- **工作流容器**：Flow 是节点的执行容器，管理节点的生命周期和执行顺序
- **起始节点**：每个 Flow 必须指定一个起始节点，作为工作流的入口
- **自动执行**：Flow 会根据节点之间的连接关系自动执行工作流
- **类型安全**：Flow 支持类型化的输入输出，确保类型安全

## 创建和执行工作流

### 1. 创建 Flow 对象

使用 `std::make_shared` 创建 Flow 对象：

```c++
auto f = std::make_shared<nodeflow::Flow>();
```

### 2. 设置起始节点

通过 `start` 方法指定工作流的起始节点：

```c++
f->start(decide_node);  // decide_node 作为工作流的入口
```

### 3. 执行工作流

使用 `runWithInput` 方法执行工作流：

```c++
auto result = f->runWithInput<std::string, std::string>(input);
```

**函数签名：**

```c++
template <typename IN, typename OUT>
OUT runWithInput(const IN& input);
```

**参数说明：**
- 模板参数 `IN`：输入数据类型 ( 即第一个节点的输入 )
- 模板参数 `OUT`：输出数据类型
- `input`：实际的输入数据

**返回值：**
- 工作流的最终输出结果，类型为 `OUT`