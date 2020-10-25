require "forwardable"
require "yaml"

module Rbnotes
  ##
  # Holds the configuration settings.  Each value of setting can be
  # retrieved like a Hash object.  Here is some examples.
  #
  #   conf = Rbnotes.conf
  #   type = conf[:repository_type]
  #   name = conf[:repository_name]
  #   base = conf[:repository_base]

  class Conf
    extend Forwardable
    include Enumerable

    ##
    # Name of the file to store configuration settings.

    FILENAME_CONF = "config.yml"

    ##
    # Name of the directory indicates which belongs to "rbnotes".

    DIRNAME_RBNOTES = "rbnotes"

    ##
    # Name of the directory which is used to indicate to put
    # configuration files.  Many tools use this name as the role.

    DIRNAME_COMMON_CONF = ".config"

    def initialize(conf_path = nil)   # :nodoc:
      @conf_path = conf_path || File.join(base_path, FILENAME_CONF)

      @conf = {}
      if FileTest.exist?(@conf_path)
        yaml_str = File.open(@conf_path, "r") { |f| f.read }
        @conf = YAML.load(yaml_str)
      else
        @conf.merge(DEFAULT_VALUES)
      end
      self
    end

    def_delegators(:@conf,
                   :empyt?, :keys, :values,
                   :has_key?, :include?, :key?, :member?,
                   :length, :size,
                   :to_s,
                   :each, :each_pair)

    ##
    # Retrieves the value for the given key.
    #
    # :call-seq:
    #     self[sym] -> value

    def [](sym)
      mode = @conf[:run_mode] || :production
      value = @conf[sym] || DEFAULT_VALUES[sym]
      if [:repository_name].include?(sym)
        value += MODE_POSTFIX[mode]
      end
      value
    end

    # :stopdoc:

    def initialize_copy(_)
      @conf = @conf.dup
    end

    def freeze;  @conf.freeze;  super; end
    def taint;   @conf.taint;   super; end
    def untaint; @conf.untaint; super; end

    private
    DEFAULT_VALUES = {
      :repository_type => :file_system,
      :repository_name => "notes",
      :repository_base => "~",
    }

    MODE_POSTFIX = {
      :production => "",
      :development => "_deve",
      :test => "_test",
    }

    def base_path
      path = nil
      xdg, user = ["XDG_CONFIG_HOME", "HOME"].map{|n| ENV[n]}
      if xdg
        path = File.join(File.expand_path(xdg), DIRNAME_RBNOTES)
      else
        path = File.join(user, DIRNAME_COMMON_CONF, DIRNAME_RBNOTES)
      end
      return path
    end
  end

  # :startdoc:

  class << self
    ##
    # Gets the instance of Rbnotes::Conf.  An optional argument is to
    # specify the absolute path for the configuration file.
    #
    # :call-seq:
    #     conf(String) => Rbnotes::Conf

    def conf(conf_path = nil)
      Conf.new(conf_path)
    end
  end
end
