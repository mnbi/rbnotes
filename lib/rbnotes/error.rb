module Rbnotes
  ##
  # A base class for each error class of rbnotes.

  class Error < StandardError; end

  # :stopdoc:

  module ErrMsg
    MISSING_ARGUMENT  = "missing argument: %s"
    MISSING_TIMESTAMP = "missing timestamp: %s"
    NO_EDITOR         = "no editor is available: %s"
    PROGRAM_ABORT     = "external program was aborted: %s"
    UNKNOWN_KEYWORD   = "unknown keyword: %s"
    INVALID_TIMESTAMP_PATTERN = "invalid timestamp pattern: %s"
    NO_CONF_FILE      = "no configuration file: %s"
    NO_TEMPLATE_FILE  = "no template file: %s"
    INVALID_TIMESTAMP_PATTERN_AS_DATE = "invalid timestamp pattern as date: %s"
  end

  # :startdoc:

  ##
  # An error raised if an essential argument was missing.

  class MissingArgumentError < Error
    def initialize(args)
      super(ErrMsg::MISSING_ARGUMENT % args.to_s)
    end
  end

  ##
  # An error raised if a given timestamp was not found in the
  # repository.

  class MissingTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::MISSING_TIMESTAMP % timestamp)
    end
  end

  ##
  # An error raised if no external editor is available to edit a note,
  # even "nano" or "vi".

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

  ##
  # An eeror raised when an unknown keyword was specified as a
  # timestamp string pattern.

  class UnknownKeywordError < Error
    def initialize(keyword)
      super(ErrMsg::UNKNOWN_KEYWORD % keyword)
    end
  end

  ##
  # An error raised when an invalid timestamp pattern was specified.

  class InvalidTimestampPatternError < Error
    def initialize(pattern)
      super(ErrMsg::INVALID_TIMESTAMP_PATTERN % pattern)
    end
  end

  ##
  # An error raised when the specified configuration file does not
  # exist.

  class NoConfFileError < Error
    def initialize(filename)
      super(ErrMsg::NO_CONF_FILE % filename)
    end
  end

  ##
  # An error raised when no arguments is spcified.

  class NoArgumentError < Error
    def initialize
      super
    end
  end

  ##
  # An error raised when the specified template files does not exist.
  #
  class NoTemplateFileError < Error
    def initialize(filepath)
      super(ErrMsg::NO_TEMPLATE_FILE % filepath)
    end
  end

  ##
  # An error raised when the specified pattern cannot be converted
  # into a date.
  #
  class InvalidTimestampPatternAsDateError < Error
    def initialize(pattern)
      super(ErrMsg::INVALID_TIMESTAMP_PATTERN_AS_DATE % pattern)
    end
  end

end
