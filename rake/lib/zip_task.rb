require 'zip'

include Rake::DSL

private

class ZipEntry
  def initialize(source)
    @_source = source
    @_target = nil
  end

  def self.process_file(zipfile, source, target)
    targetName = target || File.basename(source)
    puts "Adding file to zip archive: #{source}, #{target}"
    zipfile.add(targetName, source)
  end

  def as(target)
    @_target = target
  end

  def _zip(zipfile)
    if !File.exists?(@_source)
      raise "File or directory does not exist: #{@_source}"
    end

    if File.directory?(@_source)
      base = @_target || File.basename(@_source)
      spn = Pathname.new(@_source)
      self._sources().each do |f|
        pn = Pathname.new(f)
        relative = pn.relative_path_from(spn)
        ZipEntry.process_file(zipfile, f, File.join(base, relative))
      end
    else
      ZipEntry.process_file(zipfile, @_source, @_target)
    end
  end

  def _sources()
    if File.directory?(@_source)
      return Dir[File.join(@_source, '**', '**')]
    else
      return [@_source]
    end
  end
end

class ZipGlobEntry
  def initialize(glob)
    @_glob = glob
    @_target = nil
  end

  def into(target)
    @_target = target
  end

  def _zip(zip)
    self._sources().each do |source|
      targetName = @_target != nil ? File.join(@_target, source) : source
      ZipFileEntry.zip(zipfile, source, targetName)
    end
  end

  def _sources()
    return Dir[@_glob]
  end
end

class ZipTask

  attr_reader :_archive, :_entries, :_ignore_deps

  def initialize(archive)
    @_archive = archive
    @_entries = []
  end

  def add(path, &block)
    is_glob = path.include?('*')

    if is_glob
      globEntry = ZipGlobEntry.new(path)
      globEntry.instance_eval(&block) if block
      @_entries.push(globEntry)
    else
      entry = ZipEntry.new(path)
      entry.instance_eval(&block) if block
      @_entries.push(entry)
    end
  end

  def no_deps(flag)
    @_ignore_deps = flag
  end

  def _execute()
    Zip.continue_on_exists_proc = true
    Zip::File.open(@_archive, Zip::File::CREATE) do |zipfile|
      @_entries.each do |entry|
        entry._zip(zipfile)
      end
    end
  end

  def _sources()
    sources = []
    @_entries.each do |entry|
      sources += entry._sources()
    end
    return sources
  end
end


public

def zip(archive, &block)
  task = ZipTask.new(archive)
  task.instance_eval(&block) if block

  if task._ignore_deps
    file task._archive do
      task._execute()
    end
  else
    file task._archive => task._sources() do
      task._execute()
    end
  end
end

def unzip(archive, &block)
end
