require "fileutils"

SAMPLE_TEXT_DIR = File.expand_path('text', __dir__)
repo_path = File.expand_path('test_repo', __dir__)
FileUtils.mkdir_p(repo_path)

files = Dir.entries(SAMPLE_TEXT_DIR).filter_map { |e|
  e = File.expand_path(e, SAMPLE_TEXT_DIR)
  e if FileTest.file?(e)
}

def copy_text(texts, repo_path, ye, mo, da, ho, mi, se, sfx)
  stamps = []
  1.upto([texts.size, 60].min) { |i|
    stamps << Time.new(ye, mo, da, ho, mi, se + (i - 1))
  }

  texts.each { |abspath|
    next if FileTest.empty?(abspath)
    t = stamps.shift
    dirname = File.expand_path(t.strftime("%Y/%m"), repo_path)
    basename = t.strftime("%Y%m%d%H%M%S")

    dest = "#{dirname}/#{basename}#{File.extname(abspath)}"
    dest_with_suffix =
      "#{dirname}/#{basename}_#{"%03u" % sfx}#{File.extname(abspath)}"

    FileUtils.mkdir_p(dirname)
    [dest, dest_with_suffix].map { |d|
      FileUtils.copy_file(abspath, d) unless FileTest.exist?(d) && FileUtils.cmp(abspath, d)
    }
  }
end

#                            yyyy  mo  dd  hh  mi  ss  sfx
copy_text(files, repo_path, *[2020, 10, 12, 0,  50, 0,  89])
copy_text(files, repo_path, *[2019, 10, 12, 0,  50, 0,  89])
copy_text(files, repo_path, *[2020,  9, 12, 0,  50, 0,  89])
