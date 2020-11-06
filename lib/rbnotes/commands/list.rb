require "unicode/display_width"
require "io/console/size"

module Rbnotes::Commands

  ##
  # Defines `list` command for `rbnotes`.  See the document of execute
  # method to know about the behavior of this command.

  class List < Command

    def description             # :nodoc:
      "List notes"
    end

    ##
    # Shows a list of notes in the repository.  The only argument is
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
    #   "202011": specifies year and month
    #   - all Timestamps those have the same year and month would match
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

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} list [STAMP_PATTERN]

Show a list of notes.  When no arguments, make a list with all notes
in the repository.  When specified STAMP_PATTERN, only those match the
pattern are listed.

STAMP_PATTERN must be:

    (a) full qualified timestamp (with suffix): "20201030160200"
    (b) year and date part: "20201030"
    (c) year and month part: "202010"
    (d) year part only: "2020"
    (e) date part only: "1030"
HELP
    end

    # :stopdoc:

    private
    TIMESTAMP_STR_MAX_WIDTH = "yyyymoddhhmiss_sfx".size

    ##
    # Makes a headline with the timestamp and subject of the notes, it
    # looks like as follows:
    #
    #   |<------------------ console column size ------------------->|
    #   +-- timestamp ---+  +-  subject (the 1st line of each note) -+
    #   |                |  |                                        |
    #   20101010001000_123: I love Macintosh.                        [EOL]
    #   20100909090909_999: This is very very long long loooong subje[EOL]
    #                     ++
    #                      ^--- delimiter (2 characters)
    #
    # The subject part will truncate when it is long.

    def make_headline(timestamp)
      _, column = IO.console_size
      delimiter = ": "
      subject_width = column - TIMESTAMP_STR_MAX_WIDTH - delimiter.size - 1

      subject = remove_heading_markup(@repo.read(timestamp)[0])

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

    def remove_heading_markup(str)
      str.sub(/^#+ +/, '')
    end

    # :startdoc:
  end
end
