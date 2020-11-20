module Rbnotes::Commands

  ##
  # Shows help message for the command which specifies with the
  # argument.

  class Help < Command

    def description             # :nodoc:
      "Print help of each command"
    end

    ##
    # :call-seq:
    #     execute(["add"], Rbnotes::Conf or Hash) -> nil
    #     execute(["delete"], Rbnotes::Conf or Hash) -> nil

    def execute(args, conf)
      cmd_name = args.shift
      case cmd_name
      when nil
        self.help
      else
        Commands.load(cmd_name).help
      end
    end

    def help                    # :nodoc:
      puts <<HELP
#{Rbnotes::NAME.capitalize} is a simple tool to write a note into a single repository.

When creates a new note, a timestamp is attached to the note.  #{Rbnotes::NAME.capitalize}
manages notes with those timestamps, such update, delete, ...etc.

Timestamp is a series of digits which represents year, date, and time.
It looks like "20201106121100", means "2020-11-06 12:11:00".  It is
generated in the local time.

usage:
    #{Rbnotes::NAME} [option] [command] [args]

option:
    -c, --conf [CONF_FILE] : specifiy the configuration file
    -v, --version          : print version
    -h, --help             : show this message

    CONF_FILE must be written in YAML.  To know about details of the
    configuration file, see README.md or Wiki page.

Further help:
    #{Rbnotes::NAME} help commands
    #{Rbnotes::NAME} help COMMAND
    #{Rbnotes::NAME} usage

Further information:
    https://github.com/mnbi/rbnotes/wiki
HELP
    end

  end
end
