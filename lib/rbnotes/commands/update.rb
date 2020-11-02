module Rbnotes::Commands
  ##
  # Updates the content of the note associated with given timestamp.
  # Actual modification is done interactively by the external editor.
  # The timestamp associated with the note will be updated to new one,
  # which is generated while the command exection.
  #
  # A timestamp string must be specified as the only argument.  It
  # must exactly match to the one of the target note in the
  # repository.  When the given timestamp was not found, the command
  # fails.
  #
  # Timestamp which is associated to the target note will be newly
  # generated with the command execution time.  That is, the timestamp
  # before the command exection will be obsolete.
  #
  # This command starts the external editor program to edit the
  # content of the note.  The editor program will be searched as same
  # as add command.
  #
  # If none of editors is available, the command fails.

  class Update < Command
    include ::Rbnotes::Utils

    ##
    # The 1st and only one argument is the timestamp to speficy the
    # note to update.  Returns the new timestamp which is associated
    # to the note updated.
    #
    # :call-seq:
    #     "20201020112233" -> "20201021123400"

    def execute(args, conf)
      target_stamp = Rbnotes::Utils.read_timestamp(args)
      editor = find_editor(conf[:editor])
      repo = Textrepo.init(conf)

      text = nil
      begin
        text = repo.read(target_stamp)
      rescue Textrepo::MissingTimestampError => _
        raise Rbnotes::MissingTimestampError, target_stamp
      end

      tmpfile = run_with_tmpfile(editor, target_stamp.to_s, text)
      text = File.readlines(tmpfile, :chomp => true)

      unless text.empty?
        newstamp = nil
        begin
          newstamp = repo.update(target_stamp, text)
        rescue StandardError => e
          puts e.message
        else
          puts "Update the note [%s -> %s]" % [target_stamp, newstamp] unless target_stamp == newstamp
        ensure
          # Don't forget to remove the temporary file.
          File.delete(tmpfile)
        end
      else
        puts "Nothing is updated, since the specified content is empty."
      end
    end
  end
end
