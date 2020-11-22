module Rbnotes::Commands
  ##
  # Shows statistics.

  class Statistics < Command

    def description             # :nodoc:
      "Show statistics values"
    end

    def execute(args, conf)
      @opts = {}

      repo = Textrepo.init(conf)
      puts repo.entries.size
    end

    def help
      puts <<HELP
usage:
    #{Rbnotes::NAME} statistics

Show statistics.
HELP
    end

  end
end
