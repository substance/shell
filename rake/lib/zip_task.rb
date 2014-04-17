require 'zip'
require 'rubygems/package'
require 'fileutils'

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

class CreateZipTask

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

TAR_LONGLINK = '././@LongLink'

class ExtractZipTask

  attr_reader :_archive

  def initialize(archive)
    @_archive = archive
    @_destDir = nil;
  end

  def target_dir(path)
    @_destDir = path
  end

  def _extractZip()
    Zip::File.open(@_archive) do |zip_file|
      zip_file.each do |entry|

        dest_file = File.join(@_destDir, entry.name)
        parent_dir = File.dirname(dest_file)

        if !File.exists?(parent_dir)
          FileUtils.mkdir_p(parent_dir)
        end

        LOGGER.info "-- Extracting #{entry.name}"

        # overwrites existing files
        # TODO: maybe configurable?
        entry.extract(dest_file) { true }
      end
    end
  end

  def _extractTarGz()
    Gem::Package::TarReader.new( Zlib::GzipReader.open @_archive ) do |tar|
      dest = nil
      tar.each do |entry|
        if entry.full_name == TAR_LONGLINK
          dest = File.join(@_destDir, entry.read.strip)
          next
        end
        dest ||= File.join(@_destDir, entry.full_name)
        if entry.directory?
          File.delete(dest) if File.file?(dest)
          FileUtils.mkdir_p dest, :mode => entry.header.mode, :verbose => false
        elsif entry.file?
          FileUtils.rm_rf(dest) if File.directory?(dest)
          LOGGER.info "-- Extracting #{dest}"
          File.open dest, "wb" do |f|
            f.print entry.read
          end
          FileUtils.chmod entry.header.mode, dest, :verbose => false
        elsif entry.header.typeflag == '2' #Symlink!
          File.symlink entry.header.linkname, dest
        end
        dest = nil
      end
    end
  end

  def _execute()

    # create the destination dir if it doesn't exist
    if !File.exists?(@_destDir)
      FileUtils.mkdir_p(@_destDir)
    elsif !File.directory?(@_destDir)
      raise "Target is not a directory: #{@_destDir}"
    end

    if @_archive.end_with?('zip')
      self._extractZip()
    elsif @_archive.end_with?('tar.gz')
      self._extractTarGz()
    end

  end
end


public

def zip(archive, &block)
  task = CreateZipTask.new(archive)
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
  task = ExtractZipTask.new(archive)
  task.instance_eval(&block)

  file "unzip:#{task._archive}" => task._archive do
    task._execute()
  end
end
