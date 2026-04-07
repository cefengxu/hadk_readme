# Agent Skills (Chat Node and `workspace/skills`)

## Overview

The HADK **Chat Node** already supports a **ReAct-style** loop when `tool_choice` is `auto`: the model reasons, calls tools, and continues until it produces an answer. This example is a minimal **HADK + Agent Skill** setup. [ref. link](https://gitlab.xpaas.lenovo.com/latc/Components/hybrid-agent-rumtime/hadk_apps/-/tree/expe/src/agent_skill?ref_type=heads)

In a **single-node agent** layout, a single **`generate_node`** (`chat_node::ChatNode`) is enough to deliver **Agent Skill** behavior—no extra agent tier is required beyond that node plus tools.

Local tools (built from this repo under `local_tools/`, registered in `koba_agent.cpp`) work with skills to run the full flow, for example:

- `local_tools/abang_exec`
- `local_tools/abang_read`
- `local_tools/abang_write`
- `local_tools/abang_edit`
- `local_tools/abang_find` (beta)


**Typical flow:**

```
User input → KBChatHistory (system prompt with Skills) → Flow + ChatNode (tool_choice=auto) →
Model calls tools as needed (e.g. abang_read to load SKILL.md) → history update → response
```

**References:** `src/chat_bot/src/abang_messages.cpp` (system prompt and `workspace/skills` scanning), `src/chat_bot/src/koba_agent.cpp` (single Chat Node, `enable_tools`, local tool registration).

### Key points

- **Chat Node is the execution surface for skills:** With tools enabled (e.g. `abang_read`) and `tool_choice` set to `auto`, the model can follow the Skills section in the system prompt, **select** a skill, and **read and apply** the matching `SKILL.md`. This is independent of whether you use a multi-node graph—skill use depends on the model and tools, not on node count.
- **The Skills block in the system prompt** is built by `build_system_prompt_with_workspace_skills()` from `SKILL.md` files on disk (see below).

## Environment (LLM / search)

**hard-code LLM URLs or API keys** in sample code or configure endpoints and secrets via environment variables, for example:

```bash
export LLM_API_URL="https://your-endpoint/v1/chat/completions"
export LLM_API_KEY="your-api-key"
export TAVILY_API_URL="https://api.tavily.com/search"
export TAVILY_API_KEY="your-tavily-key"
```

## `workspace/skills` layout (next to the executable)

Store skills under **`workspace/skills/`** or **`.workspace/skills/`** in the **same directory as the executable** (your install or build output directory).

**Example layout:**

```text
<install_or_build_dir>/
  loop_chat_rt_app          # executable
  workspace/
    skills/
      <skill_name>/
        SKILL.md
```

**Path resolution:** `abang_messages.cpp` resolves `workspace/skills` relative to the **process current working directory (cwd)**, not relative to the executable path. So:

- Keep `workspace/skills` beside the binary as above, and  
- **Start the process with cwd set to that directory** (e.g. `cd` to the install dir before running `./loop_chat_rt_app`).

If cwd or layout is wrong, no skills are discovered, the Skills list is empty, and the system prompt will not list any skills.

## `SKILL.md` conventions

- Skills downloaded from **Clawhub.ai** can be used as-is when paths and front matter are valid.
- For custom skills, follow the standard **Claude Skill** and **OpenClaw Skill** formats.

Implementation details (recursive discovery, YAML front matter, `name` / `description`) match `kb_scan_workspace_skills()` and related helpers in `abang_messages.cpp`.

## Summary

| Topic | Description |
|--------|-------------|
| Agent Skill vs Chat Node | One `ChatNode` plus tools is enough; skills are listed in the system prompt and invoked by the model reading `SKILL.md` via tools (e.g. `abang_read`). |
| `workspace/skills` | Place next to the executable; run with cwd set to that directory so scanning finds `./workspace/skills`. |
| Config | Use environment variables for LLM and search credentials—do not commit real URLs or keys. |
