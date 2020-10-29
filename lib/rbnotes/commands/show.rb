module Rbnotes
  class Commands::Show < Commands::Command
    def execute(args, conf)
      stamp = Rbnotes::Utils.read_timestamp(args)

      repo = Textrepo.init(conf)
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
    end
  end
end
