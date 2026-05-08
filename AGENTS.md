# Notes for AI agents

The code is serialized with abapGit.

## Code structure

This library is a collection of tools, each in its own abap package (thus, own subdir under `src`).

- `ERRORS` - exception classes used within the code
- `EXAMPLES` - demo programs
- `LOG` - a logging class and a view for it (depends on `VIEW` package)
- `MVR` - Maintenance View Re-generator, the tool to regenerate maintenance views and apply typical fixes e.g. size of fields and screen
- `TEMPLATES` - boilerplate programs and objects to save new program initiation time
- `UTIL` - misc utility classes
- `VIEW` - convenient view wrapper class, built on SALV and utillities for it

More detailed information about the content and functionality of each sub-package is available (where relevant) in `docs` dir, named as `<package>.spec.md`. E.g. `docs/errors.spec.md` for `errors` package. Read the relevant file when reusing a sub-package or changing its code. If changing the code - update the docs accordingly.
