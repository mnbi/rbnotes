module Rbnotes::Commands

  ##
  # Defines `list` command for `rbnotes`.  See the document of execute
  # method to know about the behavior of this command.

  class List < Command

    def description             # :nodoc:
      "List notes"
    end

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
    # - "today"      (or "to")
    # - "yeasterday" (or "ye")
    # - "this_week"  (or "tw")
    # - "last_week"  (or "lw")
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
      patterns = Rbnotes.utils.expand_keyword_in_args(args)
      @repo = Textrepo.init(conf)
      # newer stamp shoud be above
      Rbnotes.utils.find_notes(patterns, @repo).each { |timestamp|
        puts Rbnotes.utils.make_headline(timestamp, @repo.read(timestamp))
      }
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} list [STAMP_PATTERN|KEYWORD]

Show a list of notes.  When no arguments, make a list with all notes
in the repository.  When specified STAMP_PATTERN, only those match the
pattern are listed.  Instead of STAMP_PATTERN, some KEYWORDs could be
used.

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

HELP
    end

  end
end
