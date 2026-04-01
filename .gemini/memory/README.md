# MWP Agent Memory

This directory stores cross-session persistent state for agents operating in this repository.

## Components

- **`knowledge.jsonl`**: The local Knowledge Graph. Managed automatically by the `@shaneholloman/mcp-knowledge-graph` server. Do not edit by hand.
- **`standing-decisions.md`**: Architectural choices and defaults that apply across all projects.
- **`client-context/`**: Short synopses for active Consultant engagements to quickly orient an agent at the start of a session.

Since agents are wiped clean at the end of each conversation task, they rely on this directory to remember what was decided yesterday.
