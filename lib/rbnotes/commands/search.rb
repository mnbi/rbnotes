# :markup: markdown

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
# Example of PATTERN:
#     ""rbnotes" (a word)
#     "macOS Big Sur" (a few words)
#     "2[0-9]{3}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])" (a regular expression)
#
# A timestamp pattern is optional.  If no timestamp pattern, all notes
# in the repository would be target of search.
#
# See the document of `Rbnotes::Commands::List#execute` to know about
# a timestamp pattern.

# :stopdoc: 

module Rbnotes
  class Commands::Search < Commands::Command
    def execute(args, conf)
      pattern = args.shift
      raise MissingArgumentError, args if pattern.nil?

      timestamp_pattern = args.shift # `nil` is acceptable

      repo = Textrepo.init(conf)
      begin
        result = repo.search(pattern, timestamp_pattern)
      rescue Textrepo::InvalidSearchResultError => e
        puts e.message
      else
        result.each { |stamp, num, match|
          puts "#{stamp}:#{num}:#{match}"
        }
      end
    end
  end
end
