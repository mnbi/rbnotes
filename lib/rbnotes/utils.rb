require "singleton"
require "pathname"
require "tmpdir"
require "date"
require "io/console/size"

require "unicode/display_width"

module Rbnotes
  ##
  # Defines several utility methods those are intended to be used in
  # Rbnotes classes.
  #
  class Utils
    include Singleton

    ##
    # Finds a external editor program which is specified with the
    # argument, then returns the absolute path of the editor.  If the
    # specified editor was not found, then search default editors in
    # the command search paths (i.e. `ENV["PATH"]).  See also the
    # document for `find_program`.
    #
    # The default editors to search in the search paths are:
    #
    # 1. ENV["EDITOR"]
    # 2. "nano"
    # 3. "vi"
    #
    # When all the default editors were not found, returns `nil`.
    #
    def find_editor(preferred_editor)
      find_program([preferred_editor, ENV["EDITOR"], "nano", "vi"].compact)
    end

    ##
    # Finds a executable program in given names.  When the executable
    # was found, it stops searching then returns an absolute path of
    # the executable.
    #
    # The actual searching is done in 2 cases.  That is, a given name is:
    #
    # 1. an absolute path:
    #    returns the path itself if it exists and is executable.
    # 2. just a program name:
    #    searchs the name in the search paths (ENV["PATH"]);
    #    if it is found in a path, construct an absolute path from
    #    the name and the path, then returns the path.
    #
    # :call-seq:
    #   ["nano", "vi"]                 -> "/usr/bin/nano"
    #   ["vi", "/usr/local/bin/emacs"] -> "/usr/bin/vi"
    #   ["/usr/local/bin/emacs", "vi"] -> "/usr/bin/vi" (if emacs doesn't exist)
    #   ["/usr/local/bin/emacs", "vi"] -> "/usr/local/bin/emacs" (if exists)
    #
    def find_program(names)
      names.each { |name|
        pathname = Pathname.new(name)
        if pathname.absolute?
          return pathname.to_path if pathname.exist? && pathname.executable?
        else
          abs = search_in_path(name)
          return abs unless abs.nil?
        end
      }
      nil
    end

    ##
    # Executes the program with passing the given filename as argument.
    # The file will be created into `Dir.tmpdir`.
    #
    # If initial_content is not nil, it must be an array of strings
    # then it provides the initial content of a temporary file.
    #
    # :call-seq:
    #     "/usr/bin/nano", "20201021131300.md", nil -> "/somewhere/tmpdir/20201021131300.md"
    #     "/usr/bin/vi", "20201021131301.md", ["apple\n", "orange\n"] -> "/somewhere/tmpdir/20201021131301.md"
    #
    def run_with_tmpfile(prog, filename, initial_content = nil)
      tmpfile = File.expand_path(add_extension(filename), Dir.tmpdir)

      unless initial_content.nil?
        File.open(tmpfile, "w") {|f| f.print(initial_content.join("\n"))}
      end

      rc = system(prog, tmpfile)
      raise ProgramAbortError, [prog, tmpfile] unless rc
      tmpfile
    end

    ##
    # Generates a Textrepo::Timestamp object from a String which comes
    # from the command line arguments.  When no argument is given,
    # then reads from STDIN.
    #
    # :call-seq:
    #   read_timestamp(args) -> String

    def read_timestamp(args)
      str = args.shift || read_arg($stdin)
      Textrepo::Timestamp.parse_s(str)
    end

    ##
    # Generates multiple Textrepo::Timestamp objects from the command
    # line arguments.  When no argument is given, try to read from
    # STDIN.
    #
    # :call-seq:
    #   read_multiple_timestamps(args) -> [String]

    def read_multiple_timestamps(args)
      strings = args.size < 1 ? read_multiple_args($stdin) : args
      strings.map { |str| Textrepo::Timestamp.parse_s(str) }
    end

    ##
    # Parses the given arguments and expand keywords if found.  Each
    # of the arguments is assumed to represent a timestamp pattern (or
    # a keyword to be expand into several timestamp pattern).  Returns
    # an Array of timestamp partterns (each pattern is a String
    # object).
    #
    # A timestamp pattern looks like:
    #
    #   (a) full qualified timestamp (with suffix): "20201030160200"
    #   (b) year and date part: "20201030"
    #   (c) year and month part: "202010"
    #   (d) year part only: "2020"
    #   (e) date part only: "1030"
    #
    # KEYWORD:
    #
    #   - "today"      (or "to")
    #   - "yeasterday" (or "ye")
    #   - "this_week"  (or "tw")
    #   - "last_week"  (or "lw")
    #
    # :call-seq:
    #   expand_keyword_in_args(Array of Strings) -> Array of Strings

    def expand_keyword_in_args(args)
      return [nil] if args.empty?

      patterns = []
      while args.size > 0
        arg = args.shift
        if ["today", "to", "yesterday", "ye",
            "this_week", "tw", "last_week", "lw"].include?(arg)
          patterns.concat(Rbnotes.utils.expand_keyword(arg))
        else
          patterns << arg
        end
      end
      patterns.sort.uniq
    end

    ##
    # Expands a keyword to timestamp strings.
    #
    # :call-seq:
    #     expand_keyword(keyword as String) -> Array of timestamp Strings

    def expand_keyword(keyword)
      patterns = []
      case keyword
      when "today", "to"
        patterns << timestamp_pattern(date_of_today)
      when "yesterday", "ye"
        patterns << timestamp_pattern(date_of_yesterday)
      when "this_week", "tw"
        patterns.concat(dates_in_this_week.map { |d| timestamp_pattern(d) })
      when "last_week", "lw"
        patterns.concat(dates_in_last_week.map { |d| timestamp_pattern(d) })
      else
        raise UnknownKeywordError, keyword
      end
      patterns
    end

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

    def make_headline(timestamp, text)
      _, column = IO.console_size
      delimiter = ": "
      timestamp_width = timestamp.to_s.size
      subject_width = column - timestamp_width - delimiter.size - 1

      subject = remove_heading_markup(text[0])

      ts_part = "#{timestamp.to_s}    "[0..(timestamp_width - 1)]
      sj_part = truncate_str(subject, subject_width)

      ts_part + delimiter + sj_part
    end

    ##
    # Finds all notes those timestamps match to given patterns in the
    # given repository.  Returns an Array contains Timestamp objects.
    #
    # :call-seq:
    #     find_notes(Array of timestamp patterns, Textrepo::Repository)

    def find_notes(timestamp_patterns, repo)
      timestamp_patterns.map { |pat|
        repo.entries(pat)
      }.flatten.sort{ |a, b| b <=> a }.uniq
    end

    ##
    # Enumerates all timestamp patterns in a week which contains a
    # given timestamp as a day of the week.
    #
    # :call-seq:
    #     timestamp_patterns_in_week(timestamp) -> [Array of Strings]

    def timestamp_patterns_in_week(timestamp)
      dates_in_week(start_date_in_the_week(timestamp.time)).map { |date| timestamp_pattern(date) }
    end

    # :stopdoc:

    private

    ##
    # Reads an argument from the IO object.  Typically, it is intended
    # to be used with STDIN.
    #
    # :call-seq:
    #   read_arg(IO) -> String

    def read_arg(io)
      read_multiple_args(io)[0]
    end

    ##
    # Reads arguments from the IO object.  Typically, it is intended
    # to be used with STDIN.
    #
    # :call-seq:
    #   read_multiple_arg(IO) -> [String]

    def read_multiple_args(io)
      strings = io.readlines
      strings.map { |str|
        # assumes the reading line looks like:
        #
        #     foo bar baz ...
        #
        # then, only the first string is interested
        begin
          str.split(":")[0].rstrip
        rescue NoMethodError => _
          nil
        end
      }.compact
    end

    def search_in_path(name)
      search_paths = ENV["PATH"].split(":")
      found = search_paths.map { |path|
        abs = File.expand_path(name, path)
        FileTest.exist?(abs) ? abs : nil
      }
      found.compact[0]
    end

    def add_extension(basename)
      "#{basename}.md"
    end

    def timestamp_pattern(date)
      date.strftime("%Y%m%d")
    end

    def date_of_today
      date(Time.now)
    end

    def date_of_yesterday
      date(Time.now).prev_day
    end

    def date(time)
      Date.new(time.year, time.mon, time.day)
    end

    def dates_in_this_week
      dates_in_week(start_date_in_this_week)
    end

    def dates_in_last_week
      dates_in_week(start_date_in_last_week)
    end

    def start_date_in_this_week
      start_date_in_the_week(Time.now)
    end

    def start_date_in_last_week
      start_date_in_this_week.prev_day(7)
    end

    def start_date_in_the_week(time)
      parts = [:year, :mon, :day].map { |sym| time.send(sym) }
      Date.new(*parts).prev_day(wday(time))
    end

    def wday(time)
      (time.wday - 1) % 7
    end

    def dates_in_week(start_date)
      dates = [start_date]
      1.upto(6) { |i| dates << start_date.next_day(i) }
      dates
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
