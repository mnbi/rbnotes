module Rbnotes::Commands
  ##
  # Shows statistics.

  class Statistics < Command

    def description             # :nodoc:
      "Show statistics values"
    end

    def execute(args, conf)
      @opts = {}
      parse_opts(args)

      report = :total
      if @opts[:yearly]
        report = :yearly
      elsif @opts[:monthly]
        report = :monthly
      end

      stats = Rbnotes::Statistics.new(conf)
      case report
      when :yearly
        stats.yearly_report
      when :monthly
        stats.monthly_report
      else
        stats.total_report
      end
    end

    def help
      puts <<HELP
usage:
    #{Rbnotes::NAME} statistics ([-y|--yearly]|[-m|--monthly])

option:
    -y, --yearly  : print yearly report
    -m, --monthly : print monthly report

Show statistics.

In the version #{Rbnotes::VERSION}, only number of notes is supported.
HELP
    end

    # :stopdoc:

    private

    def parse_opts(args)
      while args.size > 0
        arg = args.shift
        case arg
        when "-y", "--yearly"
          @opts[:yearly] = true
          @opts[:monthly] = false
          break
        when "-m", "--monthly"
          @opts[:yearly] = false
          @opts[:monthly] = true
          break
        else
          args.unshift(arg)
          raise ArgumentError, "invalid option or argument: %s" % args.join(" ")
        end
      end
    end

    # :startdoc:

  end
end
