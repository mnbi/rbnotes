module Rbnotes::Commands

  require "erb"

  ##
  # Adds a new note to the repository.  If no options, a new timestamp
  # is generated at the execution time, then it is attached to the
  # note.  If the timestamp has already existed in the repository, the
  # command fails.
  #
  # Accepts an option with `-t STAMP_PATTERN` (or `--timestamp`), a
  # timestamp is generated according to `STAMP_PATTERN`.
  #
  # STAMP_PATTERN could be one of followings:
  #
  #   "20201104172230_078" : full qualified timestamp string
  #   "20201104172230"     : full qualified timestamp string (no suffix)
  #   "202011041722"       : year, date and time (omit second part)
  #   "11041722"           : date and time (omit year and second part)
  #
  # Also accepts an option with `-f FILENAME` (or `--template-file`)
  # to specify a template file which will be the initial content of a
  # new note.
  #
  # This command starts the external editor program to prepare text to
  # store.  The editor program will be searched in the following order:
  #
  #   1. conf[:editor] (conf is the 1st arg of execute method)
  #   2. ENV["EDITOR"]
  #   3. "nano"
  #   4. "vi"
  #
  # If none of the above editor is available, the command fails.
  #
  # TEMPLATE FILE:
  #
  # This command search a file as its template which will be the initial
  # conent of a new note when an option or a setting in the configuration
  # file (`:template`) is specified a template file.
  #
  # Or, even if neither an option nor a setting about a template file is
  # specified, it always searches the default directory to read a template
  # file.  The directory is:
  #
  #   - $XDG_CONIFG_HOME/rbnotes/templates (if $XDG_CONFIG_HOME is defined)
  # or
  #   - $HOME/.config/rbnotes/templates
  #
  # If a file, `default.md` exists in the above directory, it will used as
  # a template.
  #
  # A template file can be written in ERB syntax.  See ERB manual to know
  # about how to mix ruby code and text content in ERB syntax.

  class Add < Command

    def description             # :nodoc:
      "Add a new note"
    end

    def execute(args, conf)
      @opts = {}
      parse_opts(args)

      stamp = @opts[:timestamp] || Textrepo::Timestamp.new(Time.now)

      candidates = [conf[:editor], ENV["EDITOR"], "nano", "vi"].compact
      editor = Rbnotes.utils.find_program(candidates)
      raise Rbnotes::NoEditorError, candidates if editor.nil?

      template = read_template(conf)
      tmpfile = Rbnotes.utils.run_with_tmpfile(editor, stamp.to_s, template)

      unless FileTest.exist?(tmpfile)
        puts "Cancel adding, since nothing to store"
        return
      end

      text = File.readlines(tmpfile)

      repo = Textrepo.init(conf)
      begin
        repo.create(stamp, text)
      rescue Textrepo::DuplicateTimestampError => e
        puts e.message
        puts "Just wait a second, then retry."
      rescue Textrepo::EmptyTextError => e
        puts e.message
      rescue StandardError => e
        puts e.message
      else
        puts "Add a note [%s]" % stamp.to_s
      ensure
        # Don't forget to remove the temporary file.
        File.delete(tmpfile)
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} add [(-t|--timestamp) STAMP_PATTERN]

Add a new note to the repository.  If no options, a new timestamp is
generated at the execution time, then it is attached to the note.

OPTIONS:
    -t, --timestamp STAMP_PATTERN
    -f, --template-file FILENAME

Accept an option with `-t STAMP_PATTERN` (or `--timestamp`), a
timestamp of a new note is generated according to `STAMP_PATTERN`.

Also accepts an option with `-f FILENAME` (or `--template-file`) to
specify a template file which will be the initial content of a new
note.  See below section more about a template file.

STAMP_PATTERN could be:

    "20201104172230_078" : full qualified timestamp string
    "20201104172230"     : full qualified timestamp string (no suffix)
    "202011041722"       : year, date and time (omit second part)
    "11041722"           : date and time (omit year and second part)

EDITOR:

This command starts the external editor program to prepare text to
store.  The editor program will be searched in the following order:

    1. configuration setting of ":editor"
    2. ENV["EDITOR"]
    3. "nano"
    4. "vi"

If none of the above editor is available, the execution fails.

TEMPLATE FILE:

This command search a file as its template which will be the initial
conent of a new note when an option or a setting in the configuration
file (`:template`) is specified a template file.

Or, even if neither an option nor a setting about a template file is
specified, it always searches the default directory to read a template
file.  The directory is:

- $XDG_CONIFG_HOME/rbnotes/templates (if $XDG_CONFIG_HOME is defined)

or

- $HOME/.config/rbnotes/templates

If a file, `default.md` exists in the above directory, it will used as
a template.

A template file can be written in ERB syntax.  See ERB manual to know
about how to mix ruby code and text content in ERB syntax.

HELP
    end

    # :stopdoc:

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-t", "--timestamp"
          stamp_str = args.shift
          raise ArgumentError, "missing timestamp: %s" % args.unshift(arg) if stamp_str.nil?
          stamp_str = complement_timestamp_pattern(stamp_str)
          @opts[:timestamp] = Textrepo::Timestamp.parse_s(stamp_str)
        when "-f", "--template-file"
          template_path = args.shift
          @opts[:template] = template_path
        else
          args.unshift(arg)
          break
        end
      end
    end

    def complement_timestamp_pattern(pattern)
      stamp_str = nil
      case pattern.to_s.size
      when "yyyymoddhhmiss_lll".size, "yyyymoddhhmiss".size
        stamp_str = pattern.dup
      when "yyyymoddhhmi".size  # omit sec part
        stamp_str = "#{pattern}00"
      when "moddhhmi".size      # omit year and sec part
        stamp_str = "#{Time.now.year}#{pattern}00"
      else
        raise Textrepo::InvalidTimestampStringError, pattern
      end
      stamp_str
    end

    def read_template(conf)
      template = nil
      template_path = @opts[:template] || conf[:template]

      if template_path
        raise Rbnotes::NoTemplateFileError, template_path unless FileTest.exist?(template_path)
      else
        template_path = default_template_file(conf)
        return nil unless FileTest.exist?(template_path)
      end

      erb_source = File.read(template_path)
      if erb_source and !erb_source.empty?
        erb = ERB.new(erb_source)
        template = erb.result.split("\n")
      end

      template
    end

    def default_template_file(conf)
      dir = File.join(conf[:config_home], "templates")
      File.expand_path("default.md", dir)
    end

  end
end
