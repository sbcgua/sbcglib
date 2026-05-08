# Useful AI dev prompts

## Cross check the docs

I'm writing AI-friendly documentation for a library in ABAP. Check the code in `src/xxx` folder (the code is serialized with abapGit) and the `xxx.spec.md` file respectfully. Does the spec serves as a good AI-friedly source for knowledge about this library part? What would you improve? Also check spelling and typos. When summarizing the content to be directly added to the file be concise (to optimize context window consumtion in the future).

Don't use table formatting - prefer bullet list style.

In addition, analyse methods of `ZCL_SBCGLIB_DRILLDOWN`, `ZCL_SBCGLIB_FS_UTILS` and `ZCL_SBCGLIB_UTILS` - add overview description for each method in the corresponding file section. Ask me question if the method objective is unclear
