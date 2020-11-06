module Rbnotes::Commands

  # Deletes a given note in the repository.  The timestamp string must
  # be a fully qualified one, like "20201016165130".  If no argument
  # was passed, it would try to read from the standard input.
  #
  # It does nothing to change the repository when the specified note
  # does not exist.

  class Delete < Command
    def description             # :nodoc:
      "Delete a note"
    end

    def execute(args, conf)
      stamp = Rbnotes::Utils.read_timestamp(args)

      repo = Textrepo.init(conf)
      begin
        repo.delete(stamp)
      rescue Textrepo::MissingTimestampError => e
        puts e.message
      rescue StandardError => e
        puts e.message
      else
        puts "Delete [%s]" % stamp.to_s
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} delete [TIMESTAMP]

Delete a given note.  TIMESTAMP must be a fully qualified one, such
"20201016165130" or "20201016165130_012" if it has a suffix.

Delete reads its argument from the standard input when no argument was
passed in the command line.
HELP
    end
  end
end
