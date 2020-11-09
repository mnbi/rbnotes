module Rbnotes

  ##
  # This module defines all command classes of rbnotes.  Each command
  # class must be derived from Rbnotes::Commands::Command class.

  module Commands

    ##
    # The base class for a command class.

    class Command

      ##
      # Short description of each command.

      def description; nil; end

      ##
      # :call-seq:
      #   execute(Array, Hash) -> nil
      #
      #   - Array: arguments for each command
      #   - Hash : rbnotes configuration

      def execute(args, conf)
        Builtins.default_cmd.new.execute(args, conf)
      end

      ##
      # Shows the help message for the command.
      #

      def help
        Builtins::Usage.new.execute(nil, nil)
      end

    end

    # :stopdoc:

    # Built-in commands:
    # - repo: prints the absolute path of the repository.
    # - conf: prints all of the current configuration settings.
    # - stamp: converts given TIME_STR into a timestamp.
    # - time: converts given STAMP into a time string.
    module Builtins
      class Usage < Command

        def description
          "Print usage"
        end

        def execute(_, _)
          puts <<USAGE
Syntax:
  #{Rbnotes::NAME} [-c| --conf CONF_FILE] [command] [args]

Example usage:
  #{Rbnotes::NAME} add [-t STAMP_PATTERN]
  #{Rbnotes::NAME} delete [TIMESTAMP]
  #{Rbnotes::NAME} export [TIMESTAMP [FILENAME]]
  #{Rbnotes::NAME} import FILE
  #{Rbnotes::NAME} list [STAMP_PATTERN|KEYWORD]
  #{Rbnotes::NAME} search PATTERN [STAMP_PATTERN]
  #{Rbnotes::NAME} show [TIMESTAMP]
  #{Rbnotes::NAME} update [TIMESTAMP]

Further help for each command:
  #{Rbnotes::NAME} help commands
  #{Rbnotes::NAME} help [COMMAND]

Further information:
  https://github.com/mnbi/rbnotes/wiki

USAGE
        end

        def help
          puts <<HELP_USAGE
usage:
    #{Rbnotes::NAME} usage

Print a short example of usage.
HELP_USAGE
        end
      end

      class Version < Command
        def description
          "Print version"
        end

        def execute(_, _)
          rbnotes_version = "#{Rbnotes::NAME} #{Rbnotes::VERSION} (#{Rbnotes::RELEASE})"
          textrepo_version = "textrepo #{Textrepo::VERSION}"
          puts "#{rbnotes_version} [#{textrepo_version}]"
        end

        def help
          puts <<VERSION
usage:
    #{Rbnotes::NAME} version

Print version of #{Rbnotes::NAME} and release date.
VERSION
        end
      end

      class Repo < Command
        def description
          "Print repository path"
        end

        def execute(_, conf)
          name = conf[:repository_name]
          base = conf[:repository_base]
          type = conf[:repository_type]

          puts case type
               when :file_system
                 File.expand_path(name, base)
               else
                 File.join(base, name)
               end
        end

        def help
          puts <<REPO
usage:
    #{Rbnotes::NAME} repo

Print the path of the repository.  The type of the path entity depends
on what type is specified to the repository type in the configuration.
When ":file_system" is set to "repository_type", the path is a
directory which contains all note files.  The structure of the
directory depends on the implementation of `textrepo`.
REPO
        end
      end

      class Conf < Command
        def description
          "Print the current configuration"
        end

        def execute(_, conf)
          conf.keys.sort.each { |k|
            puts "#{k}=#{conf[k]}"
          }
        end

        def help
          puts <<CONF
usage:
    #{Rbnotes::NAME} conf

Print the current configuration values.
CONF
        end
      end

      require "time"

      class Stamp < Command
        def description
          "Convert a time string into a timestamp string"
        end

        def execute(args, _)
          time_str = args.shift
          unless time_str.nil?
            puts Textrepo::Timestamp.new(::Time.parse(time_str)).to_s
          else
            puts "not specified TIME_STR"
            super
          end
        end

        def help
          puts <<STAMP
usage:
    #{Rbnotes::NAME} stamp

Convert a given time string into a timestamp string.  The timestamp
string could be used as an argument of some rbnotes commands, such
"show".  Here is short example of conversion:

    "2020-11-06 16:51:15" -> "20201106165115"
    "2020-11-06"          -> "20201106000000"
    "20201106"            -> "20201106000000"
    "2020-11-06 16"       -> "20201106160000"
    "2020-11-06 16:51"    -> "20201106165100" 
STAMP
        end
      end

      class Time < Command
        def description
          "Convert a timestamp into a time string"
        end

        def execute(args, _)
          stamp = args.shift
          unless stamp.nil?
            puts ::Time.new(*Textrepo::Timestamp.split_stamp(stamp).map(&:to_i)).to_s
          else
            puts "not specified STAMP"
            super
          end
        end

        def help
          puts <<TIME
usage:
    #{Rbnotes::NAME} time

Convert a given timestamp string into a time string.  Here is short
example of conversion:

    "20201106165115" -> "2020-11-06 16:51:15 +0900"
    "202011061651"   -> "2020-11-06 16:51:00 +0900"
    "2020110616"     -> "2020-11-06 16:00:00 +0900"
    "20201106"       -> "2020-11-06 00:00:00 +0900"
TIME
        end
      end

      class << self
        def default_cmd_name
          "usage"
        end

        def default_cmd
          Usage
        end

        def command(name)
          begin
            const_defined?(name, false) ? const_get(name, false) : nil
          rescue NameError => _
            nil
          end
        end
      end
    end

    # :startdoc:

    class << self

      ##
      # Loads a class to perfom the command, then returns an instance
      # of the class.
      #
      # :call-seq:
      #   load("add")    -> Rbnotes::Commands::Add
      #   load("delete") -> Rbnotes::Commands::Delete
      #   load("export") -> Rbnotes::Commands::Export
      #   load("help")   -> Rbnotes::Commands::Help
      #   load("import") -> Rbnotes::Commnads::Import
      #   load("list")   -> Rbnotes::Commands::List
      #   load("search") -> Rbnotes::Commands::Search
      #   load("show")   -> Rbnotes::Commands::Show
      #   load("update") -> Rbnotes::Commands::Update

      def load(cmd_name)
        cmd_name ||= Builtins.default_cmd_name
        klass_name =  cmd_name.capitalize

        klass = Builtins.command(klass_name)
        if klass.nil?
          begin
            require_relative "commands/#{cmd_name}"
            klass = const_get(klass_name, false)
          rescue LoadError => _
            STDERR.puts "unknown command: #{cmd_name}"
            klass = Builtins.default_cmd
          end
        end
        klass.new
      end
    end

  end
end
