module Rbnotes::Commands

  ##
  # Defines `list` command for `rbnotes`.  See the document of execute
  # method to know about the behavior of this command.

  class List < Command

    def description             # :nodoc:
      "List notes"
    end

    DEFAULT_BEHAVIOR = "today"  # :nodoc:

    ##
    # Shows a list of notes in the repository.  Arguments are
    # optional.  If several args are passed, each of them must be a
    # timestamp pattern or a keyword.
    #
    # Any order of timestamp patterns and keywords mixture is
    # acceptable.  The redundant patterns are just ignored.
    #
    # A timestamp pattern is a string which would match several
    # Timestamp objects.  A timestamp is an instance of
    # Textrepo::Timestamp class.
    #
    # A keyword must be one of them:
    #
    #   - "today"      (or "to")
    #   - "yeasterday" (or "ye")
    #   - "this_week"  (or "tw")
    #   - "last_week"  (or "lw")
    #   - "this_month" (or "tm")
    #   - "last_month" (or "lm")
    #
    # Here is several examples of timestamp patterns.
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
      @opts = {}
      parse_opts(args)

      if args.empty? and !@opts[:enum_week]
        default_behavior = conf[:list_default] || DEFAULT_BEHAVIOR
        args << default_behavior
      end

      utils = Rbnotes.utils
      patterns = utils.read_timestamp_patterns(args, enum_week: @opts[:enum_week])

      @repo = Textrepo.init(conf)
      notes = utils.find_notes(patterns, @repo)
      output = []
      if @opts[:verbose]
        collect_timestamps_by_date(notes).each { |date, timestamps|
          output << "#{date} (#{timestamps.size})"
          timestamps.each { |timestamp|
            pad = "  "
            output << utils.make_headline(timestamp,
                                          @repo.read(timestamp), pad)
          }
        }
      else
        notes.each { |timestamp|
          output << utils.make_headline(timestamp,
                                        @repo.read(timestamp))
        }
      end
      puts output
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} list [OPTIONS] [STAMP_PATTERN|KEYWORD]

Show a list of notes.  When no arguments, make a list with all notes
in the repository.  When specified STAMP_PATTERN, only those match the
pattern are listed.  Instead of STAMP_PATTERN, some KEYWORDs could be
used.

OPTIONS:
    -v, --verbose
    -w, --week

STAMP_PATTERN must be:

    (a) full qualified timestamp (with suffix): "20201030160200"
    (b) year and date part: "20201030"
    (c) year and month part: "202010"
    (d) year part only: "2020"
    (e) date part only: "1030"

KEYWORD:

    - "today"      (or "to")
    - "yeasterday" (or "ye")
    - "this_week"  (or "tw")
    - "last_week"  (or "lw")
    - "this_month" (or "tm")
    - "last_month" (or "lm")

An option "--verbose" is acceptable.  It specifies to counts number of
notes by each day, then put it with the date before notes.  It looks
like as follows:

    2021-04-19 (3)
      20210419134222: Foo
      20210419120235: Bar
      20210419110057: Baz
    2021-04-18 (1)
      20210418125353: Hoge
          :

When no STAMP_PATTERN or KEYWORD was specified, the behavior of this
command could be specified with a configuration setting,
":list_default:".  The value must be one of valid keywords.  If no
settings was also given, this command would behave like "today" was
specified as the setting.

An option "--week" is also acceptable.  It specifies to enumerate all
days of a week.  Typically, the option is used with a STAMP_PATTERN
which specifies a date, such "20201117", then it enumerates all days
of the week which contains "17th November 2020".

A STAMP_PATTERN other than (a) and (b) causes an error if it was used
with "--week" option.

When no STAMP_PATTERN was specified with "--week" option, the output
would be as same as the KEYWORD, "this_week" was specified.
HELP
    end

    # :stopdoc:

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-w", "--week"
          @opts[:enum_week] = true
        when "-v", "--verbose"
          @opts[:verbose] = true
        else
          args.unshift(arg)
          break
        end
      end
    end

    def collect_timestamps_by_date(timestamps)
      result = {}
      timestamps.map { |ts|
        [ts.strftime("%Y-%m-%d"), ts]
      }.reduce(result) { |r, pair|
        date, stamp = pair
        r[date] ||= []
        r[date] << stamp
        r
      }
      result
    end

    # :startdoc:

  end
end
