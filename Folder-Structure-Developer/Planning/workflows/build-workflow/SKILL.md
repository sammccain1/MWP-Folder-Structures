# Build - The Hard-Gated Protocol

## Why This Exists

The previous build skill described excellent principles - and the AI kept skipping them. The skills were read, "understood," and then ignored during execution. 

The result: visual shells that took 15-30 rounds to fix, missing features that competitors offer, edge cases discovered by the user instead of AI.

The root cause was not bad content. The skills contain the right knowledge. The root cause was no enforcement. Every phase was described as internal thinking, the AI was supposed to do but nobody checked.

This rewrite changes the model:

> Every phase produces a visible deliverable you see before the next phase starts. If the deliverable isn't produced the phase isn't complete.

## The One Rule

If you have not shown the user the Phase 1 deliverable, **you are not allowed to write code. Period. No Exceptions.** Not even for quick builds.

----------------------------------------------------------------------------------------------------------------

## Phase 0: CLASSIFY (10 seconds, always)

Identify the project type. Say it out loud in one time:

    "This is a [utility | skeuomorphic simulation | visual/generative | game/interacitve | machine-learning/data-science | hybrid | other]. The primary skills are [list 2-3]."

Read the relevant skills **NOW**. Not later. Not "I'll apply them during build."

----------------------------------------------------------------------------------------------------------------

## Phase 0.5: PROMPT SCAN (always visible)

Before writing the project brief, scan the request for gaps. Don't silently compensate - surface what's missing.

    PROMPT SCAN:

    You said: "[user prompt]"

    Gaps I'm filling with assumptions:
    1. [category]: [missing] -> I'll assume [X]
    2. [category]: [missing] -> I'll assume [X]

    Anything I should assume differently?

Gap categories to check:

    * Output - what form does the result/deliverable take?
    * Audience - who's this for?
    * Scope - full app or quick utility?
    * Data/Content - real data, sample, or generated?
    * Interaction model - static, interactive, real-time?
    * Success criteria - what makes this "done"?

Fixing the input beats fixing the output. Self-correction loops on vague prompts just rubber-stamp themselves. 

----------------------------------------------------------------------------------------------------------------

## Phase 1: BRIEF (mandatory visible deliverable)

Produce and present this:

    PROJECT BRIEF: [App Name] or [Feature Name] or [Utility Name]

    TYPE: [from Phase 0]
    AUDIENCE: [who would search for this?] 
    OUTCOME: [what success looks like for the user]
    SEARCH INTENT: [what someone types into Google]

    DOMAIN PRINCIPLES (3-5):
    1. [fundamental truth about this domain]
    2. [fundamental truth]
    3. [fundamental truth]
    
    WHAT COMPETITORS OFFER:
    - [Top 3 and their key features]
    - [Table-stakes feature we MUST have]
    - [What WE offer that they don't]

    5 FEATURES USERS EXPECT (not in the request):
    1. [feature] - [why they'll expect that]
    2. [feature] - [why they'll expect that]
    3. [feature] - [why they'll expect that]
    4. [feature] - [why they'll expect that]
    5. [feature] - [why they'll expect that]

    SCOPE: [EXPAND/ HOLD / REDUCE]
    SIGNATURE ELEMENT: [the most memorable/standout feature]

    3 DEFAULTS I'M REJECTING:
    1. [obvious choice] - [why not]
    2. ...

**GATE: Do not proceed until the human has seen and approved the brief.**

----------------------------------------------------------------------------------------------------------------

## Phase 2: PLAN (mandatory visible deliverable)

Produce and present this:

    SYSTEM PLAN: [App Name]

    STATES:
    - [state] : [what the user sees, what they can do]
    - [state] : [what the user sees, what they can do]
    - [state] : [what the user sees, what they can do]

    KEY TRANSITIONS:
    - [trigger] -> [from state] -> [to state] - failure: [what if]

    INTERACTION MAP:
    - [every interactive element and what it does]
    - [conflict check: overlapping elements?]

    LAKES (doing now):
    - [bounded task that ships complete in v1]

    OCEANS (flagging, not attempting):
    - [unbounded task] - [why out of scope]

    NEEDS FROM HUMAN:
    - [data, URLs, assests, or decisions needed]

**GATE: Do not write code the human has seen and approved the plan.**

----------------------------------------------------------------------------------------------------------------

## Phase 2.5 DIRECTION CHECK (UI-heavy builds)

Why: AI assumed an aesthetic direction and coded the entire app before validating. A 30-second direction check saves a 3-hour rebuild cycle.

    DIRECTION CHECK: [App Name]

    VIBE: [one sentence - what does this feel like?]
    LAYOUT: [primary layout approach]
    PALETTE:
        60%: [environment color]
        30%: [structure color]
        10%: [accent color]
    REFERENCE: [1-2 apps this should feel like]
    ANTI-REFRENCE: [1-2 things this should NOT look like]

Better to iterate on 6 lines of direction than 600 lines of CSS.

**GATE: DO NOT WRITE CSS until direction is confirmed.**

----------------------------------------------------------------------------------------------------------------

## PHASE 3 BUILD

Now you write code. Non-negotiable rules:

    1. Every state from the Phase 2 gets built. Not "happy path now, errors later."

    2. SEO from the start. Full meta stack in first deliverable.

    3. No fabricated data. If you need real URLs or resources stop and ask. 

    4. Apply the design system **NOW.** Not "I'll polish later." 

    5. Test every interaction manually. 
        Turn it on, turn it off, turn it on again.
        Drag everything draggable.
        Click everything clickable twice.
        What happens with nothing loaded?

        -Reference {project-directory}/.gemini/skills/test-driven/SKILL.md for test-driven development patterns.
        - Reference {project-directory}/.gemini/skills/e2e-testing/SKILL.md for playwright testing patterns.

----------------------------------------------------------------------------------------------------------------

