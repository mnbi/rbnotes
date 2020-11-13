module Rbnotes::Commands

  ##
  # Shows the content of the note specified by the argument.  The
  # argument must be a string which can be converted into
  # Textrepo::Timestamp object.
  #
  # A string for Timestamp must be:
  #
  #     "20201106112600"     : year, date, time and sec
  #     "20201106112600_012" : with suffix
  #
  # If no argument is passed, reads the standard input for an argument.

  class Show < Command

    def description             # :nodoc:
      "Show the content of a note"
    end

    def execute(args, conf)
      stamp = Rbnotes.utils.read_timestamp(args)

      repo = Textrepo.init(conf)
      content = repo.read(stamp)

      pager = conf[:pager]
      unless pager.nil?
        require 'open3'
        Open3.pipeline_w(pager) { |stdin|
          stdin.puts content
          stdin.close
        }
      else
        puts content
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} show [TIMESTAMP]

Show the content of given note.  TIMESTAMP must be a fully qualified
one, such "20201016165130" or "20201016165130_012" if it has a suffix.

The command try to read its argument from the standard input when no
argument was passed in the command line.
HELP
    end
  end
end
