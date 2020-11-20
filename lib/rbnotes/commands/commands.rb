module Rbnotes::Commands
  ##
  # Prints all command names into a single line.  When `-d` (or
  # `--deve-commands`) was specified, development commands (such
  # `conf`) would be also printed in addition to general commands.

  class Commands < Command

    def description             # :nodoc:
      "Print all command names into a single line"
    end

    def execute(args, conf)
      @opts = {}
      while args.size > 0
        arg = args.shift
        case arg.to_s
        when ""                 # no options
          break
        when "-d", "--deve-commands"
          @opts[:print_deve_commands] = true
        else                    # invalid options or args
          args.unshift(arg)
          raise ArgumentError, "invalid option or argument: %s" % args.join(" ")
        end
      end

      puts commands(@opts[:print_deve_commands]).join(" ")
    end

    def help
      puts <<HELP
usage:
    #{Rbnotes::NAME} [-d|--deve-commands]

Print all command names into a single line.  If "-d" option (or
"--deve-commands") is specified, commands for development purpose are
also printed.

HELP
      print_commands
    end

    # :stopdoc:
    private

    ##
    # Enumerates all command names.
    #
    # :call-seq:
    #     commands(builtins = false) -> [Array of Strings]

    def commands(include_builtins = false)
      names = external_commands.map { |cmd| cmd.to_s.downcase }
      names += builtin_commands.map { |cmd| cmd.to_s.downcase } if include_builtins
      names
    end

    def external_commands
      Dir.glob("*.rb", :base => __dir__) { |rb|
        require_relative rb
      }
      Rbnotes::Commands.constants.difference([:Builtins, :Command]).sort
    end

    def builtin_commands
      Rbnotes::Commands::Builtins.constants.sort
    end

    def print_commands
      Dir.glob("*.rb", :base => __dir__) { |rb|
        require_relative rb
      }
      puts "#{Rbnotes::NAME.capitalize} Commands:"
      print_commands_desc(external_commands)
      puts
      puts "for development purpose"
      print_builtins_desc(builtin_commands)
    end

    def print_commands_desc(commands)
      print_desc(Rbnotes::Commands, commands)
    end

    def print_builtins_desc(builtins)
      print_desc(Rbnotes::Commands::Builtins, builtins)
    end

    class CmdNames
      attr_reader :symbol, :name, :size
      def initialize(cmd)
        @symbol = cmd
        @name = cmd.to_s.downcase
        @size = name.size
      end
    end

    def print_desc(mod, commands)
      cmds = commands.map { |cmd| CmdNames.new(cmd) }
      name_part_size = cmds.map(&:size).max + 2
      cmds.map { |cmd|
        puts "#{spaces(4)}#{name_part(cmd.name, name_part_size)} #{desc_part(cmd.symbol, mod)}"
      }
    end

    def name_part(name, size)
      "#{name}#{spaces(size)}"[0, size]
    end

    def desc_part(symbol, mod)
      mod.const_get(symbol, false).new.description
    end

    def spaces(size)
      Array.new(size, " ").join
    end

    # :startdoc:

  end
end
