module Rbnotes::Commands

  ##
  # Picks a timestamp with a picker program, like `fzf`.

  class Pick < Command

    def description             # :nodoc:
      "Pick a timestamp with a picker program"
    end

    def execute(args, conf)
      @opts = {}
      parse_opts(args)

      utils = Rbnotes.utils
      patterns = utils.read_timestamp_patterns(args, enum_week: @opts[:enum_week])

      @repo = Textrepo.init(conf)

      list = []
      utils.find_notes(patterns, @repo).each { |timestamp|
        list << utils.make_headline(timestamp, @repo.read(timestamp))
      }

      picker = conf[:picker]
      unless picker.nil?
        picker_opts = conf[:picker_option]
        cmds = [picker]
        cmds.concat(picker_opts.split) unless picker_opts.nil?

        require 'open3'
        result = Open3.pipeline_rw(cmds) { |stdin, stdout, _|
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

    # :stopdoc:

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-w", "--week"
          @opts[:enum_week] = true
        else
          args.unshift(arg)
          break
        end
      end
    end

    # :startdoc:

  end
end
