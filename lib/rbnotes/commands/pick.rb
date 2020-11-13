module Rbnotes::Commands

  ##
  # Picks a timestamp with a picker program, like `fzf`.

  class Pick < Command

    def description             # :nodoc:
      "Pick a timestamp with a picker program"
    end

    def execute(args, conf)
      patterns = Rbnotes.utils.expand_keyword_in_args(args)
      @repo = Textrepo.init(conf)

      list = []
      Rbnotes.utils.find_notes(patterns, @repo).each { |timestamp|
        list << Rbnotes.utils.make_headline(timestamp, @repo.read(timestamp))
      }

      picker = conf[:picker]
      unless picker.nil?
        require 'open3'
        result = Open3.pipeline_rw(picker) { |stdin, stdout, _|
          stdin.puts list
          stdin.close
          stdout.read
        }
        puts result
      else
        puts list
      end
    end

    def help                    # :nodoc:
      puts <<HELP
usage:
    #{Rbnotes::NAME} pick

Pick a timestamp with a picker program, like `fzf`.  This command
refers the configuration setting of ":picker".  If no picker program
is specified, it will behave as same as "list" command.

HELP
    end
  end
end
