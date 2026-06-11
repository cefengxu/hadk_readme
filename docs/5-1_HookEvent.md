# Hook Event Input/Output Structurl

## SessionStart

### Input Struction 

```
{}
```

### Output Struction 

```
{
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "Current branch: main",  
        "sessionTitle": "main",
    }
}
```

- additionalContext: assembling HADK Context Session
- initialUserMessage: the first user message of the session (only applicable in non-interactive mode -p)
- sessionTitle: set the session title
- watchPaths: the array of absolute paths to watch
- reloadSkills: a boolean value, when true, re-scan the skill directory


## UserPromptSubmit

### Input Struction 

```
{
  "prompt": "Tell me the news from MLB today"
}
```


### Output Struction 

```
{
  "decision": "block",
  "reason": "Explanation for decision",
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Additional context",
    "sessionTitle": "Session title"
  }
}
```

or ( if decision is allow)

```
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Additional context",
    "sessionTitle": "Session title"
  }
}

```

## PreToolUse

### Input Struction 

```
{
  "tool_name": "search_web2",
  "tool_input": {
    "query": "MLB news latest 2025"
  },
  "tool_use_id": ""
}
```


### Output Struction 

```
{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "Allowed by policy",
    }
}
```

- permissionDecision: allow | deny | ask
- permissionDecisionReason： the reason for the action
- allow: allow the tool use, permissionDecisionReason： the reason for allowing, sent to LLM, used to explain why allowing
- deny: prevent the tool use, permissionDecisionReason： the reason for denying, sent to LLM, used to explain why denying
- ask： ask the user whether to allow the tool use, permissionDecisionReason： the reason for asking, sent to LLM, used to explain why asking


## PostToolUse

### Input Struction 

```
{
  "tool_name": "search_web2",
  "tool_input": {
    "query": "MLB news latest 2025"
  },
  "tool_response": {
    "content": [
      {
        "type": "text",
        "text": "{\"msg\":\"\",\"responses\":[{\"score\":0.5786631,\"snippet\":\"The official standings for Major League Baseball including division and league standings for regular season, wild card, and playoffs.\",\"title\":\"2025 MLB Standings and Records: Regular Season\",\"url\":\"https://www.mlb.com/standings/2025\"},{\"score\":0.50886196,\"snippet\":\"... news, stats and scores! https ... New. 50K views · 33:15. Go to channel James Schiano · Is it Time to Panic\",\"title\":\"Previewing the 2025 MLB Winter Meetings! (Schwarber ... - YouTube\",\"url\":\"https://www.youtube.com/watch?v=pSeBofR9Vxw\"},{\"score\":0.4889428,\"snippet\":\"Latest News. Giants go from down 8 to ultimate grand slam walk-off winners! White Sox. Home Sweet Home on the South Side! Sox move into top Central\",\"title\":\"MLB.com | The Official Site of Major League Baseball\",\"url\":\"https://www.mlb.com\"}],\"status\":\"success\"}"
      }
    ],
    "isError": false
  },
  "tool_use_id": "",
  "duration_ms": 1477
}
```

### Output Struction 

```
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for HADK"
  }
}
```

- additionalContext: adding HADK Context Session to the session, used by HADK in subsequent processing


## PostToolUseFailure

### Input Struction 
```
* pending
```

### Output Struction 

```
{
    "hookSpecificOutput": {
        "hookEventName": "PostToolUseFailure",
        "additionalContext": "Additional information about the failure for HADK",
    }
}
```

- additionalContext: adding HADK Context Session to the session, used by HADK in subsequent processing


## Stop 

** OUT OF CONTROL FROM HADK

### Input Struction 

```
{}
```

### Output Struction 

```
{
  "decision": "block",
  "reason": "Condition not met, continue working",
  "hookSpecificOutput": {
    "additionalContext": "Non-error feedback for HADK"
  }
}
```

- decision: "block" : block Claude to stop (gotta go ahead)
- reason: when decision is "block" , tell HADK why you need to  go ahead
- hookSpecificOutput.additionalContext: 非错误反馈，对话继续但显示为 hook 反馈


or 

```
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Additional information for HADK"
  }
}
```

## SessionEnd

** OUT OF CONTROL FROM HADK

### Input Struction 

```
{}
```

### Output Struction 

```
{
  "hookSpecificOutput": {
    "hookEventName": "SessionEnd"
  }
}
```