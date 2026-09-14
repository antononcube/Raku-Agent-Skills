# Raku-Agent-Skills

Repository with AI-agent skills for Raku programming.

The skills follow the guidelines of [agentskills.io](https://agentskills.io).

---

## Skills

- [raku-h2o-client-data-manipulation](./skills/raku-h2o-client-data-manipulation) : data wrangling with ["Math::NumberTheory"](https://github.com/antononcube/Raku-H2O-Client)
- [raku-javascript-d3-plots-and-charts](./skills/raku-javascript-d3-plots-and-charts) : plots and charts with ["JavaScript::D3"](https://github.com/antononcube/Raku-JavaScript-D3)
- [raku-literature-search-arxiv](./skills/raku-literature-search-arxiv) : arXiv literature search with Raku ecosystem packages.
- [raku-llm-graph-making](./skills/raku-llm-graph-making) : creation of LLM-graphs provided by ["LLM::Graph"](https://github.com/antononcube/Raku-LLM-Graph)
- [raku-number-theory-computations](./skills/raku-number-theory-computations) : number theory computations with ["Math::NumberTheory"](https://github.com/antononcube/Raku-Math-NumberTheory)

### Coming soon...

- [raku-llm-pipelines](./skills/raku-llm-pipelines) : LLM pipelines created with ["LLM::Functions"](https://github.com/antononcube/Raku-LLM-Functions) and ["LLM::Functions"](https://github.com/antononcube/Raku-LLM-Prompts). 
- [raku-graph-creation-and-plottung](./skills/raku-graph-creation-and-plotting) : Graphs (networks) creation and plotting with ["Graph"](["LLM::Functions"](https://github.com/antononcube/Raku-Graph) and ["JavaScript::D3"](["LLM::Functions"](https://github.com/antononcube/Raku-JavaScript-D3). 
- [raku-gui-making](./skills/raku-gui-making) : *most likely to be based on ["GUI::Wings](https://github.com/ash/raku-modules/tree/main/GUI-Wings)*.

---

## Making skills

Skills can be manually (human mentally) made or with the use of AI-agents. 
See agentskills.io's [specification](https://agentskills.io/specification), [best practices](https://agentskills.io/skill-creation/best-practices), and [evaluation guidelines](https://agentskills.io/skill-creation/evaluating-skills).

The package ["LLM::Resources"](https://github.com/antononcube/Raku-LLM-Resources), [AAp7], provides class `LLM::Resources::AgentSkillValidator` and the CLI script `agent-skill-validation`. 

--- 

## References

### Articles, blog posts

[AS1] agentskills.io, ["Specification"](https://agentskills.io/specification).

### Packages

[AAp1] Anton Antonov,
[H2O::Client, Raku package](https://github.com/antononcube/Raku-H2O-Client),
(2025-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Graph, Raku package](https://github.com/antononcube/Raku-Graph),
(2024-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[JavaScript::D3, Raku package](https://github.com/antononcube/Raku-JavaScript-D3),
(2021-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[LLM::Functions, Raku package](https://github.com/antononcube/Raku-LLM-Functions),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[LLM::Graph, Raku package](https://github.com/antononcube/Raku-LLM-Graph),
(2025-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[LLM::Prompts, Raku package](https://github.com/antononcube/Raku-LLM-Prompts),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[LLM::Resources, Raku package](https://github.com/antononcube/Raku-LLM-Resources),
(2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp8] Anton Antonov,
[Math::NumberTheory, Raku package](https://github.com/antononcube/Raku-Math-NumberTheory),
(2025-2026),
[GitHub/antononcube](https://github.com/antononcube).