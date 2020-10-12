require "test_helper"

class RbnotesCommandsTest < Minitest::Test
  include RbnotesTestUtils      # defined in test_helper.rb
  def setup
    @conf = {
      :repository_type => :file_system,
      :repository_name => "sandbox/test_repo",
      :repository_base => File.expand_path(__dir__),
    }
  end

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

  # Builtins::Repo
  def test_that_builtin_repo_returns_path_of_the_repository
    expected = File.expand_path(@conf[:repository_name],
                                @conf[:repository_base])
    result = execute(:repo, [], @conf)

    assert_equal expected, result.chomp
  end

  # Builtins::Conf
  def test_that_builtin_conf_prints_the_conf
    result = execute(:conf, [], @conf).lines
    result.each { |line|
      k, v = line.split("=")
      assert_equal @conf[k.to_sym].to_s, v.chomp
    }
  end

  # Builtins::Stamp
  def test_that_builtin_stamp_can_convert_time_str
    time_str = "2020-01-01 00:00:00"
    time = Time.new(time_str)
    expected = time_str.tr("- :", "")
    result = execute(:stamp, [time.to_s], @conf)

    assert_equal expected, result.chomp
  end

  # Builtins::Time
  def test_that_builtin_time_can_convert_timestamp_str
    time_str = "2020-01-01 00:00:01"
    expected = Time.new(time_str)
    stamp_str = time_str.tr("- :", "")
    result = execute(:time, [stamp_str], @conf)

    assert_equal expected, Time.new(result.chomp)
  end

  def test_that_builtin_time_can_convert_timestamp_str_with_suffix
    time_str = "2020-01-01 00:00:02"
    expected = Time.new(time_str)
    stamp_str = time_str.tr("- :", "") + "_012"
    result = execute(:time, [stamp_str], @conf)

    assert_equal expected, Time.new(result.chomp)
  end
end
