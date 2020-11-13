require "pathname"

module Rbnotes::Commands

  ##
  # Writes out a given note into a specified file.  The file will be
  # created in the current working directory unless an absolute path
  # is specified as a filename.
  #
  # When no argument was passed, would try to read a timestamp string
  # from the standard input.

  class Export < Command

    def description             # :nodoc:
      "Write out a note into a file"
    end

    #
    # :call-seq:
    #     execute([a String as timestring], Rbnotes::Conf or Hash) -> nil

    def execute(args, conf)
      stamp = Rbnotes.utils.read_timestamp(args)

      repo = Textrepo.init(conf)
      begin
        content = repo.read(stamp)
      rescue Textrepo::MissingTimestampError => _
        raise MissingTimestampError, stamp
      end

      pathname = Pathname.new(args.shift || "#{stamp}.md")
      pathname.parent.mkpath
      pathname.open("w"){ |f| f.puts content }
      puts "Export a note [%s] into a file [%s]" % [stamp, pathname]
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} export [TIMESTAMP [FILENAME]]

Write out a given note into a specified file.  TIMESTAMP must be a
fully qualified one, such "20201108141600", or "20201108141600_012" if
it has a suffix.  FILENAME is optional.  When it omitted, the filename
would be a timestamp string with ".md" as its extension, such
"20201108141600.md"

The file will be created into the current working directory unless an
absolute path is specified as FILENAME.

When no argument was passed, it would try to read a timestamp string
from the standard input.  Then, FILENAME would be regarded as omitted.
HELP
    end
  end
end
