module Rbnotes::Commands
  ##
  # Shows statistics.

  class Statistics < Command

    def description             # :nodoc:
      "Show statistics values"
    end

    def execute(args, conf)
      report = :total
      while args.size > 0
        arg = args.shift
        case arg
        when "-y", "--yearly"
          report = :yearly
          break
        when "-m", "--monthly"
          report = :monthly
          break
        else
          args.unshift(arg)
          raise ArgumentError, "invalid option or argument: %s" % args.join(" ")
        end
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

  end
end
