module Rbnotes
  ##
  # Calculates statistics of the repository.
  class Statistics
    include Enumerable

    def initialize(conf)
      @repo = Textrepo.init(conf)
      @values = construct_values(@repo)
    end

    def total_report
      puts @repo.entries.size
    end

    def yearly_report
      self.each_year { |year, monthly_values|
        num_of_notes = monthly_values.map { |_mon, values| values.size }.sum
        puts "#{year}: #{num_of_notes}"
      }
    end

    def monthly_report
      self.each { |year, mon, values|
        num_of_notes = values.size
        puts "#{year}/#{mon}: #{num_of_notes}"
      }
    end

    def each(&block)
      if block.nil?
        @values.map { |year, monthly_values|
          monthly_values.each { |mon, values|
            [year, mon, values]
          }
        }.to_enum(:each)
      else
        @values.each { |year, monthly_values|
          monthly_values.each { |mon, values|
            yield [year, mon, values]
          }
        }
      end
    end

    def years
      @values.keys
    end

    def months(year)
      @values[year] || []
    end

    def each_year(&block)
      if block.nil?
        @values.map { |year, monthly_values|
          [year, monthly_values]
        }.to_enum(:each)
      else
        @values.each { |year, monthly_values|
          yield [year, monthly_values]
        }
      end
    end

    private

    def construct_values(repo)
      values = {}
      repo.each { |timestamp, text|
        value = StatisticValue.new(timestamp, text)
        y = value.year
        m = value.mon
        values[y] ||= {}
        values[y][m] ||= []

        values[y][m] << value
      }
      values
    end

    class StatisticValue

      attr_reader :lines

      def initialize(timestamp, text)
        @timestamp = timestamp
        @lines = text.size
      end

      def year
        @timestamp[:year]
      end

      def mon
        @timestamp[:mon]
      end
    end

  end
end
