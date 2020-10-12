module Rbnotes
  class Commands::Show < Commands::Command
    def execute(args, conf)
      stamp_str = args.shift
      unless stamp_str.nil?
        repo = Textrepo.init(conf)
        stamp = Textrepo::Timestamp.parse_s(stamp_str)
        content = repo.read(stamp)

        pager = conf[:pager]
        unless pager.nil?
          require 'open3'
          Open3.pipeline_w(pager) { |stdin|
            stdin.puts content
            stdin.close
          }
        else
          puts content
        end
      else
        super
      end
    end
  end
end
