
netlogo-mode
=================

Major mode for editing NetLogo .nls and .nlogo files.

Current feature goals:

- [X] Indentation (works, but quite slow)
- [ ] Built-in auto-completion (see [tgolsson/company-netlogo](https://github.com/tgolsson/company-netlogo))
- [ ] Keyword and function auto-completion
  - Some sort of semantic analysis?

## Installation

Download `netlogo-mode.el` so it's on your load-path, and add `(require 'netlogo-mode)` to your init-file.

## Configuration

This mode has the following configuration parameters:

- `netlogo-indent-width` - *the number of spaces for each level of indents*

## Credits and contribution

This is a fork from the previous `netlogo-mode` repository, which is attributed to Tom Solberg (tgolsson) on github,
and which was a fork from the previous `netlogo-highlight` repositories, which are originally attributed to Anbor on the Netlogo mailing list.

Contributions are welcome, just make a pull request.
