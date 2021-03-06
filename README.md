# Rbnotes

[![Build Status](https://travis-ci.org/mnbi/rbnotes.svg?branch=main)](https://travis-ci.org/mnbi/rbnotes)

Rbnotes is a simple utility to write a note in the single repository.

This document provides the basic information to use rbnotes.
You may find more useful information in [Wiki pages](https://github.com/mnbi/rbnotes/wiki).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbnotes'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rbnotes

## Usage

General syntax is:

``` shell
rbnotes [global_opts] [command] [command_opts] [args]
```

### Global options

- "-c CONF_FILE", "--conf"
  - specifies a configuration file

### Commands

- import
  - imports existing files
- list
  - lists notes in the repository with their timestamps and subject
- search
  - search a word (or words) in the repository
- show
  - shows the content of a note
- add
  - adds a new note to the repository using an external editor
- update
  - update the content of the specified note using an external editor
- delete
  - deletes the specified note form the repository

### Configuration file

The `rbnotes` command reads the configuration file during its startup.
This section describes the specification of the configuration file.

#### Location

Searches the configuration file in the following order:

1. `$XDG_CONFIG_HOME/rbnotes/config.yml`
2. `$HOME/.config/rbnotes/config.yml`

None of them is found, then the default configuration is used.

The global option "-c CONF_FILE" will override the location.

#### Content

The format of the configuration file must be written in YAML.

The configuration of `rbnotes` is represented as a Hash object in the
program code.  So, each line of the configuration YAML looks like:

> name: value

Name must be written as Ruby's symbol, such `:repository_type`.  On
the other hand, value will be written in 2 types.  Some are Ruby's
symbols, the others are strings surrounded with double/single
quotations.

A real example:

``` yaml
---
:run_mode: :production
:repository_type: :file_system
:repository_name: "notes"
:repository_base: "~"
:pager: "bat -l md"
:editor: "/usr/local/bin/emacsclient"
```

The content is identical to `conf/config.yml`.

#### Variables

##### :run-mode (mandatory)

- :production (default)
- :development
- :test

The run-mode affects to behavior of `rbnotes`, such logging
information, the location of the repository, ..., etc.

##### :repository_type (mandatory)

- :file_system (default)

This value depends on classes those derived from
`Textrepo::Repository` of `textrepo`.  Currently (`textrepo` 0.4.x),
Textrepo::FileSystemRepository is the only one class usable for
`rbnotes`.

##### :repository_name (mandatory)

User can set an arbitrary string as this value.  However, the value
will be used as a part of the repository location in the file system.
Some characters in the string may cause a problem.

In addition to this, the run-mode affects the actual value when it is
used in the program.

| original | :production | :development | :test      |
|:------   |:------------|:-------------|:-----------|
| notes    | notes       | notes_dev    | notes_test |

##### :repository_base (mandatory)

This value is used as a base directory of the repository.  That is,
the values constructs the root path of the repository with
the `:repository_name` value.  It would be:

> :repository_base/:repository_name

The value is recommended to be an absolute path in the production
time, since relative path will be expanded with the current working
directory.  However, in the development and testing time, the relative
path may be useful.  See `conf/config_deve.yml` or
`conf/config_test.yml`.

The short-hand notation of the home directory ("~") is usable.

##### Miscellaneous variables (optional)

- :pager : specify a pager program
- :editor : specify a editor program
- :searcher: specify a program to perform search
- :searcher_options: specify options to pass to the searcher program

Be careful to set `:searcher` and `:searcher_options`. The searcher
program must be expected to behave equivalent to `grep` with `-inRE`.
At least, its output must be the same format and it must runs
recursively to a directory.

If your favorite searcher is one of the followings, see the default
options which `textrepo` sets for those searchers.  In most cases, you
don't have to set `:searcher_options` for them.

| searcher | default options in `textrepo`                      |
|:---------|:---------------------------------------------------|
| `grep`   | `["-i", "-n", "-H", "-R", "-E"]`                   |
| `egrep`  | `["-i", "-n", "-H", "-R"]`                         |
| `ggrep`  | `["-i", "-n", "-H", "-R", "-E"]`                   |
| `gegrep` | `["-i", "-n", "-H", "-R"]`                         |
| `rg`     | `["-S", "-n", "--no-heading", "--color", "never"]` |

Those searcher names are used in macOS (with Homebrew).  Any other OS
might use different names.

- `grep` and `egrep` -> BSD grep (macOS default)
- `ggrep` and `gegrep` -> GNU grep
- `rg` -> ripgrep

If the name is different, `:searcher_options` should be set with the
same value.  For example, if you system use the name `gnugrep` as GNU
grep, and you want to use it as the searcher (that is, set `gnugrep`
to `:searcher`), you should set `:searcher_options` value with `["-i",
"-n", "-R", "-E"]`.

##### Default values for mandatory variables

All mandatory variables have their default values.  Here is the list
of them:

| variable         | default value |
|:-----------------|:--------------|
| :run_mode        | :production   |
| :repository_type | :file_system  |
| :repository_name | "notes"       |
| :repository_base | "~"           |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mnbi/rbnotes.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
