require "test_helper"
require "yaml"

class RbnotesConfTest < Minitest::Test

  SANDBOX_DIR = File.expand_path("sandbox", __dir__)

  CONF_BASE = {
    :repository_type => :file_system,
    :repository_name => "notes",
    :repository_base => SANDBOX_DIR,
  }

  CONF_PROD_PATH = File.expand_path("conf_prod.yml", SANDBOX_DIR)
  CONF_DEVE_PATH = File.expand_path("conf_deve.yml", SANDBOX_DIR)
  CONF_TEST_PATH = File.expand_path("conf_test.yml", SANDBOX_DIR)

  def test_it_can_get_an_instance_via_rbnotes
    conf = Rbnotes.conf
    refute_nil conf
    assert_instance_of Rbnotes::Conf, conf
  end

  def test_it_can_load_conf_from_the_specified_file
    prepare_conf_file

    {
      :development => CONF_DEVE_PATH,
      :production  => CONF_PROD_PATH,
      :test        => CONF_TEST_PATH,
    }.each_pair { |mode, path|
      conf = Rbnotes.conf(path)
      refute_nil conf
      assert_equal mode, conf[:run_mode]
    }
  end

  def test_it_can_load_conf_from_xdg_config_home
    xdg_orig = ENV["XDG_CONFIG_HOME"]

    prepare_xdg_conf
    ENV["XDG_CONFIG_HOME"] = SANDBOX_DIR
    conf = Rbnotes.conf
    assert_equal :test, conf[:run_mode]
    assert_equal SANDBOX_DIR, conf[:repository_base]

    ENV["XDG_CONFIG_HOME"] = xdg_orig if xdg_orig
  end

  def test_it_can_load_conf_when_xdg_config_home_is_unset
    xdg_orig = ENV["XDG_CONFIG_HOME"]
    home_orig = ENV["HOME"]

    prepare_default_conf
    ENV.delete("XDG_CONFIG_HOME")
    ENV["HOME"] = SANDBOX_DIR
    conf = Rbnotes::conf
    assert_equal :test, conf[:run_mode]
    assert_equal SANDBOX_DIR, conf[:repository_base]

    ENV["HOME"] = home_orig if home_orig
    ENV["XDG_CONFIG_HOME"] = xdg_orig if xdg_orig
  end

  def test_it_has_default_conf_when_no_conf_file_exists
    xdg_orig = ENV["XDG_CONFIG_HOME"]
    home_orig = ENV["HOME"]

    xdg_path = File.join(SANDBOX_DIR, "rbnotes", "config.yml")
    default_path = File.join(SANDBOX_DIR, ".config", "rbnotes", "config.yml")
    File.delete(xdg_path) if FileTest.exist?(xdg_path)
    File.delete(default_path) if FileTest.exist?(default_path)

    ENV.delete("XDG_CONFIG_HOME")
    ENV["HOME"] = SANDBOX_DIR
    conf = Rbnotes::conf
    assert_equal :file_system, conf[:repository_type]
    assert_equal "notes", conf[:repository_name]
    assert_equal SANDBOX_DIR, File.expand_path(conf[:repository_base])

    ENV["HOME"] = home_orig if home_orig
    ENV["XDG_CONFIG_HOME"] = xdg_orig if xdg_orig
  end

  def test_it_generate_repository_name_suitable_to_run_mode
    prepare_conf_file

    conf = Rbnotes.conf(CONF_TEST_PATH)
    assert conf[:repository_name].end_with?("_test")
  end

  # [issue #77]
  def test_it_fails_when_the_specified_conf_file_does_not_exist
    assert_raises(Rbnotes::NoConfFileError) {
      Rbnotes.conf("conf_hoge.yml")
    }
  end

  def test_it_holds_config_file_path
    prepare_conf_file
    conf = Rbnotes.conf(CONF_TEST_PATH)
    assert_equal CONF_TEST_PATH, conf[:path]
  end

  def test_it_holds_config_home
    conf = Rbnotes.conf
    refute_nil conf[:config_home]
  end

  def test_it_holds_config_home_when_xdg_config_home_available
    xdg_orig = ENV["XDG_CONFIG_HOME"]

    prepare_xdg_conf
    ENV["XDG_CONFIG_HOME"] = SANDBOX_DIR
    conf = Rbnotes.conf

    assert_equal File.join(ENV["XDG_CONFIG_HOME"], "rbnotes"), conf[:config_home]

    ENV["XDG_CONFIG_HOME"] = xdg_orig if xdg_orig
  end

  def test_it_holds_config_home_when_xdg_config_home_unavailable
    xdg_orig = ENV["XDG_CONFIG_HOME"]
    home_orig = ENV["HOME"]

    prepare_default_conf
    ENV.delete("XDG_CONFIG_HOME")
    ENV["HOME"] = SANDBOX_DIR
    conf = Rbnotes::conf

    expected = File.join(ENV["HOME"], ".config", "rbnotes")
    assert_equal expected, conf[:config_home]

    ENV["HOME"] = home_orig if home_orig
    ENV["XDG_CONFIG_HOME"] = xdg_orig if xdg_orig
  end

  private
  def prepare_conf_file
    conf_prod = CONF_BASE.dup
    conf_deve = CONF_BASE.dup
    conf_test = CONF_BASE.dup

    conf_prod[:run_mode] = :production
    conf_deve[:run_mode] = :development
    conf_test[:run_mode] = :test

    write_conf_file(conf_prod, CONF_PROD_PATH)
    write_conf_file(conf_deve, CONF_DEVE_PATH)
    write_conf_file(conf_test, CONF_TEST_PATH)
  end

  def write_conf_file(conf, path)
    yaml_str = YAML.dump(conf)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "w") { |f| f.puts(yaml_str) } unless FileTest.exist?(path)
  end

  def prepare_xdg_conf
    xdg_path = File.join(SANDBOX_DIR, "rbnotes", "config.yml")
    prepare_conf(xdg_path)
  end

  def prepare_default_conf
    default_path = File.join(SANDBOX_DIR, ".config", "rbnotes", "config.yml")
    prepare_conf(default_path)
  end

  def prepare_conf(path)
    conf = CONF_BASE.dup
    conf[:run_mode] = :test
    write_conf_file(conf, path) unless File.exist?(path)
  end
end
