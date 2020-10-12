module Rbnotes
  module Commands
    class Command
      def execute(args, conf)
        Builtins::DEFAULT_CMD.new.execute(args, conf)
      end
    end

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

    class << self
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
