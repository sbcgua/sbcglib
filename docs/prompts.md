# Useful AI dev prompts

## Cross check the docs

I'm writing AI-friendly documentation for a library in ABAP. Check the code in the `src/xxx` folder and the `xxx.spec.md` file. The code is serialized with abapGit. Does the spec serve as a good AI-friendly source of knowledge about this library part? What would you improve? Also check spelling and typos. When summarizing the content to be directly added to the file, be concise to optimize future context-window consumption.

Don't use table formatting - prefer bullet list style.

In addition, analyse methods of `ZCL_SBCGLIB_DRILLDOWN`, `ZCL_SBCGLIB_FS_UTILS` and `ZCL_SBCGLIB_UTILS` - add overview description for each method in the corresponding file section. Ask me question if the method objective is unclear

## Agent docs

The project is a open sourced shared library in ABAP language, common classes and components that can be used in other projects as utilities or templates. I'm working on documentation for this library and, importantly, I want the documentation to be AI agent friedly, so that an agent can quickly get the idea how to reuse the components in the context of another project, without analizing the code too deeply. At the same time the documentation should remain friedly to a human as well. My idea is to polish current documenation in terms of considency, improve and augment with certain agent friently notes if necessary. And then, create a skill (or maybe a set of skills) that is dedicted purely for agents. Such skills will be copied to the context of another project and serve as a guide on how to use the components in this library. As the development is in ABAP, it means that the "another project" will not have direct access to the code of sbcglib, it will rather "find it" later in the real SAP system. So such a skill will become a compass on  how to use the sbcglib components. If we decide (during work on this task) to compose several skills, then there should be a master skill (or maybe just a readmy file) hinting when to use each skill and how to apply it. So let's start the analysis:

1) observe the current documentation, ask me questions if anything is unclear or needs a decision, check if the docs are consistent, suggest improvements to it for the purpose of consistency and frienliness to agents yet keeping human as a main user
2) after that, let discuss and decide about the structure of the agent docs
3) and then distill the agent docs and skills (place them into docs/skills folder)

**Further answers:**

General comments:

- let's currenly leave the `MVR` aside. It relative narrow tool, it probably needs some refactoring, so I'd wait for a real case of reusage first.
- `EXAMPLES` - these are simple and readable programs, I don't think they need docs for the moment. Let's also omit for now.
- front section with summary - a good idea. Can you help with that or you want me to add it? What do you need from me to add it yourself?
- fix the typos yourself please
- skills: agree with your structure suggestion (yet omit `mvr` for now)

1) `log->is_empty` - already fixed, check the staged source
2) MVR - in general let's omit or mark as unstable yet (and exclude from skills for now)
3) let's polish the human docs first. and then build skills on top. Importantly! Assume that the skills will be copied to the a target project WITHOUT the rest of the docs, so the references that you suggested should contain enough infromation to be used without the orginal docs. And yes, they should be concise and optimized for agents.

Let's polish the human docs first, then let me review it and confirm the skills creation as the second phase.
