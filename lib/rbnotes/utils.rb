require "pathname"
require "tmpdir"

module Rbnotes
  ##
  # Defines several utility methods those are intended to be used in
  # Rbnotes classes.
  #
  module Utils

    ##
    # Finds a external editor program which is specified with the
    # argument, then returns the absolute path of the editor.  If the
    # specified editor was not found, then search default editors in
    # the command search paths (i.e. `ENV["PATH"]).  See also the
    # document for `find_program`.
    #
    # The default editors to search in the search paths are:
    #
    # 1. ENV["EDITOR"]
    # 2. "nano"
    # 3. "vi"
    #
    # When all the default editors were not found, returns `nil`.
    #
    def find_editor(preferred_editor)
      find_program([preferred_editor, ENV["EDITOR"], "nano", "vi"].compact)
    end
    module_function :find_editor

    ##
    # Finds a executable program in given names.  When the executable
    # was found, it stops searching then returns an absolute path of
    # the executable.
    #
    # The actual searching is done in 2 cases.  That is, a given name is:
    #
    # 1. an absolute path:
    #    returns the path itself if it exists and is executable.
    # 2. just a program name:
    #    searchs the name in the search paths (ENV["PATH"]);
    #    if it is found in a path, construct an absolute path from
    #    the name and the path, then returns the path.
    #
    # :call-seq:
    #   ["nano", "vi"]                 -> "/usr/bin/nano"
    #   ["vi", "/usr/local/bin/emacs"] -> "/usr/bin/vi"
    #   ["/usr/local/bin/emacs", "vi"] -> "/usr/bin/vi" (if emacs doesn't exist)
    #   ["/usr/local/bin/emacs", "vi"] -> "/usr/local/bin/emacs" (if exists)
    #
    def find_program(names)
      names.each { |name|
        pathname = Pathname.new(name)
        if pathname.absolute?
          return pathname.to_path if pathname.exist? && pathname.executable?
        else
          abs = search_in_path(name)
          return abs unless abs.nil?
        end
      }
      nil
    end
    module_function :find_program

    ##
    # Executes the program with passing the given filename as argument.
    # The file will be created into `Dir.tmpdir`.
    #
    # If initial_content is not nil, it must be an array of strings
    # then it provides the initial content of a temporary file.
    #
    # :call-seq:
    #     "/usr/bin/nano", "20201021131300.md", nil -> "/somewhere/tmpdir/20201021131300.md"
    #     "/usr/bin/vi", "20201021131301.md", ["apple\n", "orange\n"] -> "/somewhere/tmpdir/20201021131301.md"
    #
    def run_with_tmpfile(prog, filename, initial_content = nil)
      tmpfile = File.expand_path(add_extension(filename), Dir.tmpdir)

      unless initial_content.nil?
        File.open(tmpfile, "w") {|f| f.print(initial_content.join("\n"))}
      end

      rc = system(prog, tmpfile)
      raise ProgramAbortError, [prog, tmpfile] unless rc
      tmpfile
    end
    module_function :run_with_tmpfile

    ##
    # Generates a Textrepo::Timestamp object from a String which comes
    # from the command line arguments.  When no argument is given,
    # then reads from STDIN.
    #
    # :call-seq:
    #   read_timestamp(args) -> String

    def read_timestamp(args)
      str = args.shift || read_arg($stdin)
      Textrepo::Timestamp.parse_s(str)
    end
    module_function :read_timestamp

    ##
    # Reads an argument from the IO object.  Typically, it is intended
    # to be used with STDIN.
    #
    # :call-seq:
    #   read_arg(IO) -> String

    def read_arg(io)
      # assumes the reading line looks like:
      #
      #     foo bar baz ...
      #
      # then, only the first string is interested
      begin
        io.gets.split(" ")[0]
      rescue NoMethodError => _
        nil
      end
    end
    module_function :read_arg

    # :stopdoc:

    private
    def search_in_path(name)
      search_paths = ENV["PATH"].split(":")
      found = search_paths.map { |path|
        abs = File.expand_path(name, path)
        FileTest.exist?(abs) ? abs : nil
      }
      found.compact[0]
    end
    module_function :search_in_path

    def add_extension(basename)
      "#{basename}.md"
    end
    module_function :add_extension
  end
end
