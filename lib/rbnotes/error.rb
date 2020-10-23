module Rbnotes
  ##
  # A base class for each error class of rbnotes.
  #
  class Error < StandardError; end

  # :stopdoc:
  module ErrMsg
    MISSING_ARGUMENT  = "missing argument: %s"
    MISSING_TIMESTAMP = "missing timestamp: %s"
    NO_EDITOR         = "No editor is available: %s"
    PROGRAM_ABORT     = "External program was aborted: %s"
  end

  # :startdoc:

  ##
  # An error raised if an essential argument was missing.
  #
  class MissingArgumentError < Error
    def initialize(args)
      super(ErrMsg::MISSING_ARGUMENT % args.to_s)
    end
  end

  ##
  # An error raised if a given timestamp was not found in the
  # repository.
  #
  class MissingTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::MISSING_TIMESTAMP % timestamp)
    end
  end

  ##
  # An error raised if no external editor is available to edit a note,
  # even "nano" or "vi".
  #
  class NoEditorError < Error
    def initialize(names)
      super(ErrMsg::NO_EDITOR % names.to_s)
    end
  end

  ##
  # An error raised when a external program such an editor was aborted
  # during its execution.
  class ProgramAbortError < Error
    def initialize(cmdline)
      super(ErrMsg::PROGRAM_ABORT % cmdline.join(" "))
    end
  end
end
