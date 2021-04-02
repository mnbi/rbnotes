module Rbnotes::Commands

  ##
  # Shows the content of the notes specified by arguments.  Each
  # argument must be a string which can be converted into
  # Textrepo::Timestamp object.
  #
  # A string for Textrepo::Timestamp must be:
  #
  #     "20201106112600"     : year, date, time and sec
  #     "20201106112600_012" : with suffix
  #
  # If no argument is passed, reads the standard input for arguments.
  # If a specified timestamp does not exist in the repository as a key,
  # Rbnotes::MissingTimestampError will occur.
  class Show < Command

    def description             # :nodoc:
      "Show the content of notes"
    end

    def execute(args, conf)
      stamps = Rbnotes.utils.read_multiple_timestamps(args)
      repo = Textrepo.init(conf)

      content = stamps.map { |stamp|
        begin
          text = repo.read(stamp)
        rescue Textrepo::MissingTimestampError => _
          raise Rbnotes::MissingTimestampError, stamp
        end

        [stamp, text]
      }.to_h

      pager = conf[:pager]
      unless pager.nil?
        puts_with_pager(pager, make_output(content))
      else
        puts make_output(content)
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} show [TIMESTAMP...]

Show the content of given notes.  TIMESTAMP must be a fully qualified
one, such "20201016165130" or "20201016165130_012" if it has a suffix.

The command try to read its argument from the standard input when no
argument was passed in the command line.
HELP
    end

    # :stopdoc:

    private

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
        ary = [make_heading(timestamp, [column, 72].min)]
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
