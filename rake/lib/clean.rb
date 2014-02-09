require 'fileutils'

desc "Cleans build related files."
task "clean"

desc "Cleans everything. Also things that are not cleaned by default, e.g., downloaded files."
task "clean:all" => :clean

public

# A helper for cleaning files and directory.
# -----
# It does nothing if the given path does not exist,
# and removes directories recursively (as `rm -rf`)

def clean(path)
  return if !File.exists?(path)

  if File.directory?(path)
    log.info "Deleting directory #{path}..."
    FileUtils.rm_r(path)
  else
    log.info "Deleting file #{path}..."
    File.delete(path)
  end
end
