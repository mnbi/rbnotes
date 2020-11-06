require "textrepo"

module Rbnotes
  NAME = File.basename($PROGRAM_NAME) # :nodoc:

  require_relative "rbnotes/version"
  require_relative "rbnotes/error"
  require_relative "rbnotes/conf"
  require_relative "rbnotes/utils"
  require_relative "rbnotes/commands"
end
