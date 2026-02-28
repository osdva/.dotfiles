---
description: Research a topic on the web using the browser subagent and return sourced findings
---
Use the subagent tool in single mode with:
- agent: "browser"
- task: "Research: $@"
- agentScope: "project"

Ask the browser agent to:
1. Prefer primary sources.
2. Validate key claims with at least 2 independent sources when possible.
3. Return:
   - Brief summary (3-8 bullets)
   - Sources (URLs)
   - Caveats/uncertainties
