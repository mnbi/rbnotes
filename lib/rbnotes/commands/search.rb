module Rbnotes::Commands

  ##
  # Searches a given pattern in notes those have timestamps match a
  # given timestamp pattern.  The first argument is a pattern to search.
  # It is a String object represents a portion of text or it may a
  # String represents a regular expression.  The second argument is
  # optional and it is a timestamp pattern to specify the search target.
  #
  # A pattern for search is mandatory.  If no pattern, raises
  # Rbnotes::MissingArgumentError.
  #
  # Example of PATTERN for search:
  #
  #   "rbnotes" (a word)
  #   "macOS Big Sur" (a few words)
  #   "2[0-9]{3}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])" (a regular expression)
  #
  # A timestamp pattern is optional.  If no timestamp pattern, all notes
  # in the repository would be target of search.
  #
  # See the document of `Rbnotes::Commands::List#execute` to know about
  # a timestamp pattern.

  class Search < Command

    def description             # :nodoc:
      "Search a given pattern in notes"
    end

    def execute(args, conf)
      @opts = {}
      parse_opts(args)

      pattern = args.shift
      raise MissingArgumentError, args if pattern.nil?

      timestamp_pattern = args.shift # `nil` is acceptable

      repo = Textrepo.init(conf)
      begin
        result = repo.search(pattern, timestamp_pattern)
      rescue Textrepo::InvalidSearchResultError => e
        puts e.message
      end
      print_search_result(result.map{ |e| SearchEntry.new(*e) })
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} search [OPTIONS] PATTERN [STAMP_PATTERN]

PATTERN is a word (or words) to search, it may also be a regular
expression.

OPTIONS:
    -s, --subject-only

An option "--subject-only" is acceptable.  It specifies to search in
only the subject of each note.  The subject means the first line of
the note text.

STAMP_PATTERN must be:

    (a) full qualified timestamp (with suffix): "20201030160200"
    (b) year and date part: "20201030"
    (c) year and month part: "202010"
    (d) year part only: "2020"
    (e) date part only: "1030"

HELP
    end

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-s", "--subject-only"
          @opts[:subject_only] = true
        else
          args.unshift(arg)
          break
        end
      end
    end

    # Each entry of search result is:
    #
    #   [<timestamp>, <line_number>, <matched_text>]
    #
    # The sort must be done in;
    #
    #   - descending order for <timestamp>,
    #   - ascending ordier for <line_number>.
    #

    SearchEntry = Struct.new(:timestamp, :line_number, :matched_text) {
      def timestamp_size
        timestamp.to_s.size
      end

      def line_number_digits_size
        line_number.to_s.size
      end
    }

    def print_search_result(entries)
      if @opts[:subject_only]
        entries.select!{|e| e.line_number == 1}
      end

      maxcol_stamp = entries.map(&:timestamp_size).max
      maxcol_num = entries.map(&:line_number_digits_size).max

      sort(entries).each { |e|
        stamp_display = "%- *s" % [maxcol_stamp, e.timestamp]
        num_display = "%*d" % [maxcol_num, e.line_number]

        if @opts[:subject_only]
          puts "#{stamp_display}: #{e.matched_text}"
        else
          puts "#{stamp_display}: #{num_display}: #{e.matched_text}"
        end
      }
    end

    def sort(search_result)
      search_result.sort { |a, b|
        stamp_comparison = (b.timestamp <=> a.timestamp)
        if stamp_comparison == 0
          a.line_number <=> b.line_number
        else
          stamp_comparison
        end
      }
    end

  end
end
