module Rbnotes::Commands

  ##
  # Shows the content of the notes specified by arguments.  Arguments
  # should be timestamp patterns or keywords.  See the document for
  # the `list` command to know about such arguments.
  #
  # Accepts an option with `-n NUMBER` (or `--num-of-lines`), to show
  # the first NUMBER lines of the content of each note.
  #
  # If no argument is passed, reads the standard input for arguments.
  # If a specified timestamp does not exist in the repository as a key,
  # Rbnotes::MissingTimestampError will occur.
  class Show < Command

    def description             # :nodoc:
      "Show the content of notes"
    end

    def execute(args, conf)
      @opts = {}
      parse_opts(args)

      repo = Textrepo.init(conf)
      stamps = read_timestamps(args, repo)
      return if stamps.empty?

      content = stamps.map { |stamp|
        begin
          text = repo.read(stamp)
        rescue Textrepo::MissingTimestampError => _
          raise Rbnotes::MissingTimestampError, stamp
        end

        lines = text.size
        if @opts[:num_of_lines].to_i > 0
          lines = [@opts[:num_of_lines], lines].min
        end

        [stamp, text[0, lines]]
      }.to_h

      pager = conf[:pager]
      unless pager.nil? or @opts[:raw]
        puts_with_pager(pager, make_output(content))
      else
        puts make_output(content)
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} show [OPTIONS] [STAMP_PATTERN|KEYWORD...]

Show the content of given notes.  It accepts timestamp patterns and
keywords like the `list` (or `pick`) command.  See the help for the
`list` command to know more about stamp patterns and keywords.

OPTIONS:
    -n, --num-of-lines NUMBER
    -r, --raw

Accept an option with `-n NUMBER` (or `--num-of-lines`), to show the
first NUMBER lines of the content of each note.

Also accepts `-r` (or `--raw`) option to specify to use "raw" output,
which means no use any pager, no apply to any process to make output.
The behavior is intended to be used within a pipeline.

The command try to read its argument from the standard input when no
argument was passed in the command line.
HELP
    end

    # :stopdoc:

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-n", "--num-of-lines"
          num_of_lines = args.shift
          raise ArgumentError, "missing number: %s" % args.unshift(arg) if num_of_lines.nil?

          num_of_lines = num_of_lines.to_i
          raise ArgumentError, "illegal number (must be greater than 0): %d" % num_of_lines unless num_of_lines > 0

          @opts[:num_of_lines] = num_of_lines
        when "-r", "--raw"
          @opts[:raw] = true
        else
          args.unshift(arg)
          break
        end
      end
    end

    def read_timestamps(args, repo)
      utils = Rbnotes.utils
      if args.empty?
        stamps = utils.read_multiple_timestamps(args)
      else
        patterns = utils.read_timestamp_patterns(args)
        stamps = utils.find_notes(patterns, repo)
      end
      stamps
    end

    def puts_with_pager(pager, output)
      require "open3"
      Open3.pipeline_w(pager) { |stdin|
        stdin.puts output
        stdin.close
      }
    end

    require "io/console/size"

    def make_output(content)
      if content.size <= 1
        return content.values[0]
      end

      _, column = IO.console_size
      output = content.map { |timestamp, text|
        ary = [make_heading(timestamp, column - 10)]
        ary.concat(text)
        ary
      }

      output = insert_delimiter(output, "")
      output.flatten
    end

    def make_heading(timestamp, column)
      stamp_str = timestamp.to_s
      length = column - (stamp_str.size + 2)
      "#{stamp_str} #{Array.new(length, '-').join}"
    end

    def insert_delimiter(ary, delimiter = "")
      result = []
      ary.each { |e|
        result << e
        result << delimiter
      }
      result.delete_at(-1)
      result
    end

    # :startdoc:

  end
end
