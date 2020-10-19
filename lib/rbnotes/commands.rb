module Rbnotes
  ##
  # This module defines all command classes of rbnotes.  Each command
  # class must be derived from Rbnotes::Commands::Command class.
  module Commands
    ##
    # The base class for a command class.
    class Command
      ##
      # :call-seq:
      #   Array, Hash -> nil
      #   - Array: arguments for each command
      #   - Hash : rbnotes configuration
      #
      def execute(args, conf)
        Builtins::DEFAULT_CMD.new.execute(args, conf)
      end
    end

    # :stopdoc:

    # Built-in commands:
    # - repo: prints the absolute path of the repository.
    # - conf: prints all of the current configuration settings.
    # - stamp: converts given TIME_STR into a timestamp.
    # - time: converts given STAMP into a time string.
    module Builtins
      class Help < Command
        def execute(_, _)
          puts <<USAGE
usage: rbnotes [command] [args]

command:
    import FILE     : import a FILE into the repository
    list NUM        : list NUM notes
    show STAMP      : show the note specified with STAMP
    delete STAMP    : delete the note specified with STAMP

    conf            : print the current configuraitons
    repo            : print the repository path
    stamp  TIME_STR : convert TIME_STR into a timestamp
    time   STAMP    : convert STAMP into a time string
    version         : print version
    help            : show help
USAGE
        end
      end

      class Version < Command
        def execute(_, _)
          rbnotes_version = "rbnotes #{Rbnotes::VERSION} (#{Rbnotes::RELEASE})"
          textrepo_version = "textrepo #{Textrepo::VERSION}"
          puts "#{rbnotes_version} [#{textrepo_version}]"
        end
      end

      class Repo < Command
        def execute(_, conf)
          name = conf[:repository_name]
          base = conf[:repository_base]
          type = conf[:repository_type]

          puts case type
               when :file_system
                 "#{base}/#{name}"
               else
                 "#{base}/#{name}"
               end
        end
      end

      class Conf < Command
        def execute(_, conf)
          conf.keys.sort.each { |k|
            puts "#{k}=#{conf[k]}"
          }
        end
      end

      require "time"

      class Stamp < Command
        def execute(args, _)
          time_str = args.shift
          unless time_str.nil?
            puts Textrepo::Timestamp.new(::Time.parse(time_str)).to_s
          else
            puts "not specified TIME_STR"
            super
          end
        end
      end

      class Time < Command
        def execute(args, _)
          stamp = args.shift
          unless stamp.nil?
            puts ::Time.new(*Textrepo::Timestamp.split_stamp(stamp).map(&:to_i)).to_s
          else
            puts "not specified STAMP"
            super
          end
        end
      end

      DEFAULT_CMD = Help
    end

    DEFAULT_CMD_NAME = "help"

    # :startdoc:

    class << self
      ##
      # Loads a class to perfom the command, then returns an instance
      # of the class.
      #
      # :call-seq:
      #   "import" -> an object of Rbnotes::Commnads::Import
      #   "list"   -> an object of Rbnotes::Commands::List
      #   "show"   -> an object of Rbnotes::Commands::Show
      #
      def load(cmd_name)
        cmd_name ||= DEFAULT_CMD_NAME
        klass_name =  cmd_name.capitalize

        klass = nil
        if Builtins.const_defined?(klass_name, false)
          klass = Builtins::const_get(klass_name, false)
        else
          begin
            require_relative "commands/#{cmd_name}"
            klass = const_get(klass_name, false)
          rescue LoadError => _
            STDERR.puts "unknown command: #{cmd_name}"
            klass = Builtins::DEFAULT_CMD
          end
        end
        klass.new
      end
    end

  end
end
