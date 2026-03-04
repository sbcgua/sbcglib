# Sbcglib

Common ABAP classes and templates used in my and my company's developments (worth opensourcing).

## Content

TBD

Packages:

- `ERROR` contains exception classes used within the code and error-processing utils
- `EXAMPLES` contains demo programs
- `LOG` contains simple logging class and a view for it (depends on `VIEW` package)
- `MVR` - Maintenance View Re-generator, the tool (or rather library) to regenerate maintenance views and apply typical fixes e.g. size of fields and screen
- `TEMPLATES` contain boilerplate programs and objects to save new program initiation time
- `UTIL` contains misc utility classes like interaction with FS or drilldowns to typical business objects
- `VIEW` contains simple view class, built on SALV but simpler to call, and utillities for it (for field catalog)

## Installation

- Install via [abapGit](https://github.com/abapGit/abapGit).
- Consider installing "by package" (`Exclude path` setting) if you don't need all the code.
- Consider [ABAP Include Assembler](https://github.com/sbcgua/abap_include_assembler) if you want to integrate the code inside your codebase.

## Credits

- Maintained by Alexander Tsybulsky (SBCG LLC).
- Maintenance View Re-generator (`mvr` subpackage) may contain fragments derived from [abapGit](https://github.com/abapGit/abapGit)
