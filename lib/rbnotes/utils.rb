require "singleton"
require "pathname"
require "tmpdir"
require "date"
require "io/console/size"

require "unicode/display_width"

module Rbnotes

  class << self

    ##
    # Retrieves the singleton instance of Rbnotes::Utils class.
    # Typical usage is as follows:
    #
    #   Rbnotes.utils.find_editor("emacsclient")
    #
    def utils
      Utils.instance
    end
  end

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
      raise NoArgumentError if str.nil?
      Textrepo::Timestamp.parse_s(str)
    end

    ##
    # Generates multiple Textrepo::Timestamp objects from the command
    # line arguments.  When no argument is given, try to read from
    # STDIN.
    #
    # When multiple strings those point the identical time are
    # included the arguments (passed or read form STDIN), the
    # redundant strings will be removed.
    #
    # The order of the arguments will be preserved into the return
    # value, even if the redundant strings were removed.
    #
    # :call-seq:
    #   read_multiple_timestamps(args) -> [String]

    def read_multiple_timestamps(args)
      strings = args.size < 1 ? read_multiple_args($stdin) : args
      raise NoArgumentError if (strings.nil? || strings.empty?)
      strings.uniq.map { |str| Textrepo::Timestamp.parse_s(str) }
    end

    ##
    # Reads timestamp patterns in an array of arguments.  It supports
    # keywords expansion and enumeration of week.  The function is
    # intended to be used from Commands::List#execute and
    # Commands::Pick#execute.
    #
    def read_timestamp_patterns(args, enum_week: false)
      patterns = nil
      if enum_week
        patterns = []
        while args.size > 0
          arg = args.shift
          begin
            patterns.concat(timestamp_patterns_in_week(arg.dup))
          rescue InvalidTimestampPatternAsDateError => _e
            raise InvalidTimestampPatternAsDateError, args.unshift(arg)
          end
        end
      else
        patterns = expand_keyword_in_args(args)
      end
      patterns
    end

    ##
    # Enumerates all timestamp patterns in a week which contains a
    # given timestamp as a day of the week.
    #
    # The argument must be one of the followings:
    #   - "yyyymodd" (eg. "20201220")
    #   - "yymoddhhmiss" (eg. "20201220120048")
    #   - "yymoddhhmiss_sfx" (eg. "20201220120048_012")
    #   - "modd" (eg. "1220") (assums in the current year)
    #   - nil (assumes today)
    #
    # :call-seq:
    #     timestamp_patterns_in_week(String) -> [Array of Strings]
    #
    def timestamp_patterns_in_week(arg)
      date_str = arg || Textrepo::Timestamp.now[0, 8]

      case date_str.size
      when "yyyymodd".size
        # nothing to do
      when "yyyymoddhhmiss".size, "yyyymoddhhmiss_sfx".size
        date_str = date_str[0, 8]
      when "modd".size
        this_year = Time.now.year.to_s
        date_str = "#{this_year}#{date_str}"
      else
        raise InvalidTimestampPatternAsDateError, arg
      end

      begin
        date = Date.parse(date_str)
      rescue Date::Error => _e
        raise InvalidTimestampPatternAsDateError, arg
      end

      dates_in_week(date).map { |date| timestamp_pattern(date) }
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
    #   - "this_month" (or "tm")
    #   - "last_month" (or "lm")
    #
    # :call-seq:
    #   expand_keyword_in_args(Array of Strings) -> Array of Strings
    #
    def expand_keyword_in_args(args)
      return [nil] if args.empty?

      patterns = []
      while args.size > 0
        arg = args.shift
        if KEYWORDS.include?(arg)
          patterns.concat(expand_keyword(arg))
        else
          patterns << arg
        end
      end
      patterns.sort.uniq
    end

    ##
    # Makes a headline with the timestamp and subject of the notes, it
    # looks like as follows:
    #
    #   |<--------------- console column size -------------------->|
    #   |   |+-- timestamp ---+  +-subject (the 1st line of note) -+
    #   |                     |  |                                 |
    #   |   |20101010001000_123: I love Macintosh.                 [EOL]
    #   |   |20100909090909_999: This is very very long looong subj[EOL]
    #   |<->|                 |  |
    #     ^--- pad             ++
    #                          ^--- delimiter (2 characters)
    #
    # The subject part will truncate when it is long.

    def make_headline(timestamp, text, pad = nil)
      _, column = IO.console_size
      delimiter = ": "
      timestamp_width = timestamp.to_s.size
      subject_width = column - timestamp_width - delimiter.size - 1
      subject_width -= pad.size unless pad.nil?

      subject = remove_heading_markup(text[0])

      ts_part = "#{timestamp.to_s}    "[0..(timestamp_width - 1)]
      ts_part.prepend(pad) unless pad.nil?
      sj_part = truncate_str(subject, subject_width)

      ts_part + delimiter + sj_part
    end

    ##
    # Finds all notes those timestamps match to given patterns in the
    # given repository.  Returns an Array contains Timestamp objects.
    # The returned Array is sorted by Timestamp.
    #
    # :call-seq:
    #     find_notes(Array of timestamp patterns, Textrepo::Repository)

    def find_notes(timestamp_patterns, repo)
      timestamp_patterns.map { |pat|
        repo.entries(pat)
      }.flatten.sort{ |a, b| b <=> a }.uniq
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

    ##
    # Expands a keyword to timestamp strings.
    #
    # :call-seq:
    #     expand_keyword(keyword as String) -> Array of timestamp Strings
    #
    def expand_keyword(keyword)
      patterns = []
      case keyword
      when "today", "to"
        patterns << timestamp_pattern(Date.today)
      when "yesterday", "ye"
        patterns << timestamp_pattern(Date.today.prev_day)
      when "this_week", "tw"
        patterns.concat(dates_in_this_week.map { |d| timestamp_pattern(d) })
      when "last_week", "lw"
        patterns.concat(dates_in_last_week.map { |d| timestamp_pattern(d) })
      when "this_month", "tm"
        patterns.concat(dates_in_this_month.map { |d| timestamp_pattern(d) })
      when "last_month", "lm"
        patterns.concat(dates_in_last_month.map { |d| timestamp_pattern(d) })
      else
        raise UnknownKeywordError, keyword
      end
      patterns
    end

    KEYWORDS = %w(
      today to yesterday ye
      this_week tw last_week lw
      this_month tm last_month lm
    )

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

    def date(time)
      Date.new(time.year, time.mon, time.day)
    end

    def dates_in_this_week
      dates_in_week(Date.today)
    end

    def dates_in_last_week
      dates_in_week(Date.today.prev_day(7))
    end

    def dates_in_week(date)
      start_date = start_date_of_week(date)
      dates = [start_date]
      1.upto(6) { |i| dates << start_date.next_day(i) }
      dates
    end

    def start_date_of_week(date)
      # week day in monday start calendar
      date.prev_day((date.wday - 1) % 7)
    end

    def first_date_of_this_month
      today = Time.now
      date(Time.new(today.year, today.mon, 1))
    end

    def dates_in_this_month
      dates_in_month(first_date_of_this_month)
    end

    def dates_in_last_month
      dates_in_month(first_date_of_this_month.prev_month)
    end

    def dates_in_month(first_date)
      days = days_in_month(first_date.mon, leap: first_date.leap?)
      dates = [first_date]
      1.upto(days - 1) { |i| dates << first_date.next_day(i) }
      dates
    end

    DAYS = {
      #             1   2   3   4   5   6   7   8   9  10  11  12
      #            Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
      false => [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
      true  => [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    }

    def days_in_month(mon, leap: false)
      DAYS[leap][mon]
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
