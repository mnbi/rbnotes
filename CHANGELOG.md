# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
- (nothing to record here)

## [0.4.20] - 2022-12-03
### Added
- Add a new keyword, `recent`. (#131)

## [0.4.19] - 2021-05-24
### Added
- Add an option to search in only the subject of each note. (#128)

### Modified
- Update copyright year in `LICENSE`. (#127)

### Fixed
- Fix #129: add description about the keyword, "all."

## [0.4.18] - 2021-04-29
### Added
- Use ERB to generate the initial content of a new note from the
  template file (`add`) (#125)

### Fixed
- Add info about template feature of `add`: (#124)
  - update help text of `add`,
  - update `README.md`.
- Add description about `ugrep` to `README.md`. (#122)
- Fix issue #118: help text of `list` is wrong.
- Fix issue #119: a test for `Rbnotes::Utils` may fails.
  - fix the test.

## [0.4.17] - 2021-04-21
### Added
- Change for the `show` command to accept keywords. (#84)
- Add `-r` option to the `show` command. (#110)
  - which specifies to enable "raw" output mode.

### Fixed
- Update the help text for the `list` command. (#112, #113)
- Remove trailing spaces. (#108)
- Fix minor bugs:
  - remove redundant use of an instance variable,
  - change the behavior to exit when no notes found in the repo,
    - `pick` and `show`
  - change delimiter line size according to terminal column.
    - `show`

## [0.4.16] - 2021-04-17
### Added
- Add a new configuration setting to change the default behavior of
  the `list` (and `pick`) command. (#109)

## [0.4.15] - 2021-04-15
### Added
- Enable to use delimiters within a timestamp string. (#104)

### Fixed
- Fix issue #105: `list` ignores the 2nd arg when specified `-w`
  option.

## [0.4.14] - 2021-04-10
### Added
- Add `-n` option to `show` command. (#102)

### Fixed
- Fix issue #100: modify to catch Textrepo::MissingTimestampError.

## [0.4.13] - 2021-03-30
### Changed
- Use GitHub/Actions instead of Travis-CI.
- Add `--week` option to `pick` command. (#88)

### Fixed
- Fix issue #98: remove redundant args
  (Rbnotes::Utils.read_multiple_timestamps). (#98)
- Update `textrepo`. -> 0.5.8 (#97)

## [0.4.12] - 2020-12-18
### Changed
- Make clear the spec of `list` command args. (#94)
- Add a feature to use a template file for `add` command. (#87)
- Add new keywords for `list` command. (#90)
  - `this_month` and `last_month`
- Add a new option, `verbose` for `list` command. (#76)

### Fixed
- Fix issue #80: suppress unnecessary error message.

## [0.4.11] - 2020-12-07
### Added
- Add a new command `statistics`. (#73)
  - limited features
- Add a completion file for `zsh`.
  - a new file `etc/zsh/_rbnotes`

### Changed
- Add a new option for `import` to use `mtime`. (#82)
- Add a feature to show multiple notes at once. (#79)

### Fixed
- Fix issue #77: no error with a non-existing config file.

## [0.4.10] - 2020-11-20
### Added
- Add a new command `commands` to show all command names. (#71)

### Fixed
- Fix issue #69: crashes with invalid timestamp pattern.

## [0.4.9] - 2020-11-17
### Added
- Add a new option `--week` to the `list` command. (#67)

## [0.4.8] - 2020-11-16
### Fixed
- Fix issue #65: messy output of the `search` command.

## [0.4.7] - 2020-11-15
### Changed
- Beautify output of the `search` command. (#63)

### Fixed
- Fix issue #61: `list` command fails in pipeline.

## [0.4.6] - 2020-11-13
### Added
- Add a new command `pick` to select a note with picker program. (#59)

## [0.4.5] - 2020-11-12
### Changed
- Add a feature to accept multiple args for `list`. (#57)

### Fixed
- Fix issue #54: Notes list does not sort correctly.

## [0.4.4] - 2020-11-09
### Changed
- Add a feature to use a keyword as an argument for `list`. (#47)

## [0.4.3] - 2020-11-08
### Added
- Add a new command `export` to write out a note into a file. (#51)
- Add individual help for each command. (#42)

### Fixed
- Fix issue #48: `add` fails without modification.

## [0.4.2] - 2020-11-05
### Changed
- Add a feature to keep the timestamp in `update` command. (#44)

### Fixed
- Fix issue #45: hanging up of `add` command.

## [0.4.1] - 2020-11-04
### Changed
- Add a feature to accept a timestamp in `add` command. (#34)

## [0.4.0] - 2020-11-03
### Added
- Add a new command `search` to perform full text search. (#33)

## [0.3.1] - 2020-10-30
### Added
- Add a feature to specify configuration file in the command
  line. (#21)

## [0.3.0] - 2020-10-29
### Changed
- Add feature to read argument from the standard input. (#27)

## [0.2.2] - 2020-10-27
### Changed
- Add a feature to accept a timestamp pattern in `list` command. (#22)

## [0.2.1] - 2020-10-25
### Added
- Add a feature to load the configuration from an external file.
  - Add a description about the configuration file in README.md.

## [0.2.0] - 2020-10-23
### Added
- Add more commands (add/update/delete).
  - Add and update commands use a external editor to edit a note.
  - Delete command remove the specified note from the repository.
- Add a new task into `Rakefile` to generate RI docs.
  - The intention of the task is to verify RI docs.

### Changed
- Refactor some tests.

## [0.1.3] - 2020-10-15
### Changed
- Add help text for the `conf` command.

## [0.1.2] - 2020-10-15
### Changed
- Adapt the API change in `textrepo` (0.4.0).

## [0.1.0] - 2020-10-12
### Added
- Import files those are part of `examples` in the `textrepo` gem.
  - All commands in the example version works fine.
  - Wrote tests for all commands.
- All files those are generated by `bundler`.
- Add CHANGELOG.md to start recording changes.
