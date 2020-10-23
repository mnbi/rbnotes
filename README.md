# Rbnotes

[![Build Status](https://travis-ci.org/mnbi/rbnotes.svg?branch=main)](https://travis-ci.org/mnbi/rbnotes)

Rbnotes is a simple utility to write a note in the single repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbnotes, github: 'mnbi/rbnotes, branch: 'main'
```

And then execute:

    $ bundle install

## Usage

CAUTION: The following description contains features those are not
implemented yet.

General syntax is:

``` shell
rbnotes [global_opts] [command] [command_opts] [args]
```

### Commands

- import
  - imports existing files
- list
  - lists notes in the repository with their timestamps and subject
- show
  - shows the content of a note
- add
  - adds a new note to the repository using an external editor
- update
  - update the content of the specified note using an external editor
- delete
  - deletes the specified note form the repository

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mnbi/rbnotes.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
