module Rbnotes
  ##
  # A base class for each error class of rbnotes.
  #
  class Error < StandardError; end

  # :stopdoc:
  module ErrMsg
    NO_EDITOR = "No editor is available: %s"
    PROGRAM_ABORT = "External program was aborted: %s"
  end

  # :startdoc:

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
