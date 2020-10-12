require "io/console/size"

module Rbnotes
  class Commands::List < Commands::Command
    def execute(args, conf)
      @row, @column = IO.console_size
      max = (args.shift || @row - 3).to_i

      @repo = Textrepo.init(conf)
      notes = @repo.notes.sort{|a, b| b <=> a}
      notes[0, max].each { |timestamp_str|
        puts make_headline(timestamp_str)
      }
    end

    private
    TIMESTAMP_STR_MAX_WIDTH = "yyyymoddhhmiss_sfx".size
    # Makes a headline with the timestamp and subject of the notes, it
    # looks like as follows:
    #
    # |<------------------ console column size --------------------->|
    # +-- timestamp ---+  +--- subject (the 1st line of each note) --+
    # |                |  |                                          |
    # 20101010001000_123: # I love Macintosh.                        [EOL]
    # 20100909090909_999: # This is very very long long loooong subje[EOL]
    #                   ++
    #                    ^--- delimiter (2 characters)
    #
    # The subject part will truncate when it is long.
    def make_headline(timestamp_str)

      delimiter = ": "
      subject_width = @column - TIMESTAMP_STR_MAX_WIDTH - delimiter.size - 1

      subject = @repo.read(Textrepo::Timestamp.parse_s(timestamp_str))[0]
      prefix = '# '
      subject = prefix + subject.lstrip if subject[0, 2] != prefix

      ts_part = "#{timestamp_str}    "[0..(TIMESTAMP_STR_MAX_WIDTH - 1)] 
      sj_part = truncate_str(subject, subject_width)

      ts_part + delimiter + sj_part
    end

    def truncate_str(str, size)
      count = 0
      result = ""
      str.each_char { |c|
        # TODO: fix
        # This code is ugly.  It assumes that each non-ascii character
        # always occupy the width of 2 ascii characters in a terminal.
        # I am not sure the assumption is appropriate or not.
        count += c.ascii_only? ? 1 : 2
        break if count > size
        result << c
      }
      result
    end
  end
end
