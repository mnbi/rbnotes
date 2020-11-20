module Rbnotes::Commands

  ##
  # Updates the content of the note associated with given timestamp.
  #
  # Reads its argument from the standard input when no argument was
  # passed in the command line.
  #
  # The timestamp associated with the note will be updated to new one,
  # which is generated while the command exection.
  #
  # When "-k" (or "--keep") option is specified, the timestamp will
  # remain unchanged.
  #
  # Actual modification is done interactively by the external editor.
  #
  # The editor program will be searched as same as add command.  If
  # none of editors is available, the execution fails.

  class Update < Command

    def description             # :nodoc:
      "Update the content of a note"
    end

    ##
    # The 1st and only one argument is the timestamp to speficy the
    # note to update.
    #
    # :call-seq:
    #     "20201020112233" -> "20201021123400"

    def execute(args, conf)
      @opts = {}
      while args.size > 0
        arg = args.shift
        case arg
        when "-k", "--keep"
          @opts[:keep_timestamp] = true
        else
          args.unshift(arg)
          break
        end
      end

      target_stamp = Rbnotes.utils.read_timestamp(args)
      editor = Rbnotes.utils.find_editor(conf[:editor])
      repo = Textrepo.init(conf)

      text = nil
      begin
        text = repo.read(target_stamp)
      rescue Textrepo::MissingTimestampError => _
        raise Rbnotes::MissingTimestampError, target_stamp
      end

      tmpfile = Rbnotes.utils.run_with_tmpfile(editor, target_stamp.to_s, text)
      text = File.readlines(tmpfile, :chomp => true)

      unless text.empty?
        keep = @opts[:keep_timestamp] || false
        newstamp = nil
        begin
          newstamp = repo.update(target_stamp, text, keep)
        rescue StandardError => e
          puts e.message
        else
          if keep
            puts "Update the note content, the timestamp unchanged [%s]" % newstamp
          else
            puts "Update the note [%s -> %s]" % [target_stamp, newstamp] unless target_stamp == newstamp
          end
        ensure
          # Don't forget to remove the temporary file.
          File.delete(tmpfile)
        end
      else
        puts "Nothing is updated, since the specified content is empty."
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} update [-k|--keep] [TIMESTAMP]

Updates the content of the note associated with given timestamp.

Reads its argument from the standard input when no argument was passed
in the command line.

The timestamp associated with the note will be updated to new one,
which is generated while the command exection.

When "-k" (or "--keep") option is specified, the timestamp will remain
unchanged.

Actual modification is done interactively by the external editor.  The
editor program will be searched as same as add command.  If none of
editors is available, the execution fails.
HELP
    end
  end
end
