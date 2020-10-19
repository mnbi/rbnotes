# -*- coding: utf-8 -*-

require "pathname"
require "tmpdir"

module Rbnotes
  ##
  # Defines several utility methods those are intended to be used in
  # Rbnotes classes.
  #
  module Utils

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
    def run_with_tmpfile(prog, filename)
      tmpfile = File.expand_path(add_extension(filename), Dir.tmpdir)
      rc = system(prog, tmpfile)
      raise ProgramAbortError, [prog, tmpfile] unless rc
      tmpfile
    end
    module_function :run_with_tmpfile

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
