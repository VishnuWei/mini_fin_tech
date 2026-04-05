# AI Usage

## Tools used

- ChatGPT / Codex for app scaffolding, architecture acceleration, and UI implementation

## Where AI helped

- generating the initial Flutter project structure and Riverpod state flow
- drafting recommendation-engine heuristics and insight phrasing
- accelerating dashboard and form UI composition

## Two places AI output needed correction

1. An initial approach suggested a monolithic state file. I split it into feature folders plus dedicated model and service layers to keep the app easier to explain and extend.
2. An early recommendation formula over-weighted income and under-reacted to discretionary spending spikes. I revised it so unusual weekly spend and goal distance more directly affect the final weekly suggestion.

## One decision that was mine

I chose to model offline handling as local-first writes plus explicit sync state and retry controls in the UI. That gives a realistic mobile product experience for the take-home while keeping the frontend independently demoable before backend integration.
