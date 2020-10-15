require "test_helper"

class RbnotesCommandsTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def test_that_it_can_load_a_command
    cmd = load_cmd(Rbnotes::Commands::DEFAULT_CMD_NAME)
    refute cmd.nil?
  end

  def test_that_it_has_some_builtins
    [:help, :version, :repo, :conf, :stamp, :time].each { |name|
      klass_name = name.to_s.capitalize
      klass = Rbnotes::Commands::Builtins.const_get(klass_name, false)
      # klass.name will be like "Rbnotes::Commands::Builtins::Help"
      assert_equal klass_name, klass.name.split("::")[-1]
    }
  end

  # Builtins::Help
  def test_that_builtin_help_message_contains_abou_all_of_builtins
    result = execute(:help, [], CONF_RW)
    builtins = Rbnotes::Commands::Builtins.constants.map { |sym|
      obj = Rbnotes::Commands::Builtins.const_get(sym)
      if obj.instance_of?(Class) &&
         obj.superclass == Rbnotes::Commands::Command
        obj.to_s.split("::")[-1]
      else
        nil
      end
    }.compact

    builtins.each { |sym|
      assert result.include?(sym.to_s.downcase)
    }
  end

  # Builtins::Repo
  def test_that_builtin_repo_returns_path_of_the_repository
    expected = repo_path(CONF_RW)
    result = execute(:repo, [], CONF_RW)

    assert_equal expected, result.chomp
  end

  # Builtins::Conf
  def test_that_builtin_conf_prints_the_conf
    result = execute(:conf, [], CONF_RW).lines
    result.each { |line|
      k, v = line.split("=")
      assert_equal CONF_RW[k.to_sym].to_s, v.chomp
    }
  end

  # Builtins::Stamp
  def test_that_builtin_stamp_can_convert_time_str
    time_str = "2020-01-01 00:00:00"
    time = Time.new(time_str)
    expected = time_str.tr("- :", "")
    result = execute(:stamp, [time.to_s], CONF_RW)

    assert_equal expected, result.chomp
  end

  # Builtins::Time
  def test_that_builtin_time_can_convert_timestamp_str
    time_str = "2020-01-01 00:00:01"
    expected = Time.new(time_str)
    stamp_str = time_str.tr("- :", "")
    result = execute(:time, [stamp_str], CONF_RW)

    assert_equal expected, Time.new(result.chomp)
  end

  def test_that_builtin_time_can_convert_timestamp_str_with_suffix
    time_str = "2020-01-01 00:00:02"
    expected = Time.new(time_str)
    stamp_str = time_str.tr("- :", "") + "_012"
    result = execute(:time, [stamp_str], CONF_RW)

    assert_equal expected, Time.new(result.chomp)
  end
end
