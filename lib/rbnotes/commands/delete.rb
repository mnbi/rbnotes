# :markup: markdown

# Delete command deletes one note in the repository, which specified
# with a given timestamp string.  The timestamp string must be a fully
# qualified one, like "20201016165130".  The argument to specify a
# note is mandatory.  If no argument was passed, it would print help
# message and exit.
#
# It does nothing when the specified note does not exist except to
# print error message.

# :stopdoc: 

module Rbnotes
  class Commands::Delete < Commands::Command
    def execute(args, conf)
      stamp_str = args.shift
      unless stamp_str.nil?
        repo = Textrepo.init(conf)
        begin
          stamp = Textrepo::Timestamp.parse_s(stamp_str)
          repo.delete(stamp)
        rescue Textrepo::MissingTimestampError => e
          puts e.message
        rescue StandardError => e
          puts e.message
        else
          puts "Delete [%s]" % stamp.to_s
        end
      else
        super
      end
    end
  end
end
