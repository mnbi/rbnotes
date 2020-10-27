require "unicode/display_width"
require "io/console/size"

module Rbnotes
  ##
  # Defines `list` command for `rbnotes`.  See the document of execute
  # method to know about the behavior of this command.

  class Commands::List < Commands::Command

    ##
    # Shows the list of notes in the repository.  The only argument is
    # optional.  If it passed, it must be an timestamp pattern.  A
    # timestamp is an instance of Textrepo::Timestamp class.  A
    # timestamp pattern is a string which would match several
    # Timestamp objects.
    #
    # Here is
    # several examples of timestamp patterns.
    #
    #   "20201027093600_012": a complete string to represent a timestamp
    #   - this pattern would match exactly one Timestamp object
    #
    #   "20201027": specifies year and date
    #   - all Timestamps those have the same year and date would match
    #
    #   "2020": specifies year only
    #   - all Timestamps those have the same year would match
    #
    #   "1027": specifies date only
    #   - all Timestamps those have the same date would match, even if
    #     they have the different year.
    #
    # :call-seq:
    #     execute(Array, Rbnotes::Conf or Hash) -> nil

    def execute(args, conf)
      pattern = args.shift      # `nil` is acceptable

      @repo = Textrepo.init(conf)
      # newer stamp shoud be above
      stamps = @repo.entries(pattern).sort{|a, b| b <=> a}
      stamps.each { |timestamp|
        puts make_headline(timestamp)
      }
    end

    # :stopdoc:

    private
    TIMESTAMP_STR_MAX_WIDTH = "yyyymoddhhmiss_sfx".size

    ##
    # Makes a headline with the timestamp and subject of the notes, it
    # looks like as follows:
    #
    #   |<------------------ console column size --------------------->|
    #   +-- timestamp ---+  +--- subject (the 1st line of each note) --+
    #   |                |  |                                          |
    #   20101010001000_123: # I love Macintosh.                        [EOL]
    #   20100909090909_999: # This is very very long long loooong subje[EOL]
    #                     ++
    #                      ^--- delimiter (2 characters)
    #
    # The subject part will truncate when it is long.

    def make_headline(timestamp)
      _, column = IO.console_size
      delimiter = ": "
      subject_width = column - TIMESTAMP_STR_MAX_WIDTH - delimiter.size - 1

      subject = @repo.read(timestamp)[0]
      prefix = '# '
      subject = prefix + subject.lstrip if subject[0, 2] != prefix

      ts_part = "#{timestamp.to_s}    "[0..(TIMESTAMP_STR_MAX_WIDTH - 1)] 
      sj_part = truncate_str(subject, subject_width)

      ts_part + delimiter + sj_part
    end

    def truncate_str(str, size)
      count = 0
      result = ""
      str.each_char { |c|
        count += Unicode::DisplayWidth.of(c)
        break if count > size
        result << c
      }
      result
    end

    # :startdoc:
  end
end
