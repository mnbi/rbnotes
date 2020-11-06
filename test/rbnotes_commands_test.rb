require "test_helper"

class RbnotesCommandsTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def test_that_it_can_load_a_command
    cmd = load_cmd(Rbnotes::Commands::Builtins.default_cmd_name)
    refute cmd.nil?
  end

  def test_that_it_has_some_builtins
    [:usage, :version, :repo, :conf, :stamp, :time].each { |name|
      klass_name = name.to_s.capitalize
      klass = Rbnotes::Commands::Builtins.const_get(klass_name, false)
      # klass.name will be like "Rbnotes::Commands::Builtins::Usage"
      assert_equal klass_name, klass.name.split("::")[-1]
    }
  end

  # Builtins::Usage
  def test_that_builtin_usage_message_contains_some_of_commands
    result = execute(:usage, [], CONF_RW)
    commands = [:add, :delete, :import, :list, :search, :show, :update]
    commands.each { |sym|
      assert result.include?(sym.to_s)
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
