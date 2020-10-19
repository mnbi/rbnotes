# -*- coding: utf-8 -*-

module Rbnotes::Commands
  ##
  # Adds a new note to the repository.  A new timestamp is generated
  # at the execution time, then it is attached to the note.  If the
  # timestamp has already existed in the repository, the command
  # fails.
  #
  # This command starts the external editor program to prepare text to
  # store.  The editor program will be searched in the following order:
  #
  # 1. conf[:editor] (conf is the 1st arg of execute method)
  # 2. ENV["EDITOR"]
  # 3. "nano"
  # 4. "vi"
  #
  # If none of the above editor is available, the command fails.
  #
  class Add < Command
    include ::Rbnotes::Utils

    def execute(args, conf)
      newstamp = Textrepo::Timestamp.new(Time.now)

      candidates = [conf[:editor], ENV["EDITOR"], "nano", "vi"].compact
      editor = find_program(candidates)
      raise Rbnotes::NoEditorError, candidates if editor.nil?

      tmpfile = run_with_tmpfile(editor, newstamp.to_s)
      text = File.readlines(tmpfile)

      repo = Textrepo.init(conf)
      begin
        repo.create(newstamp, text)
      rescue Textrepo::DuplicateTimestampError => e
        puts e.message
        puts "Just wait a second, then retry."
      rescue Textrepo::EmptyTextError => e
        puts e.message
      rescue StandardError => e
        puts e.message
      else
        puts "Add a note [%s]" % newstamp.to_s
      ensure
        # Don't forget to remove the temporary file.
        File.delete(tmpfile)
      end
    end
  end
end
