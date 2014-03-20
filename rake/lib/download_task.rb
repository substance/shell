require 'fileutils'

include Rake::DSL

private
class DownloadFile

  attr_reader :_path, :_url, :_binary

  def initialize(url)
    @_url = url
    @_path = nil
    @_binary = true
  end

  def url(url)
    @_url = url
  end

  def path(path)
    @_path = path
  end

  def binary(flag)
    @_binary = flag
  end

  def execute()
    parent_dir = File.dirname(@_path)
    if !File.exists?(parent_dir)
      FileUtils.mkdir_p(parent_dir)
    end

    LOGGER.info("Downloading file from: #{@_url}, to: #{@_path}")
    require 'open-uri'
    access = _binary ? 'wb' : 'w'
    open(_path, access) do |f|
      f << open(_url).read
    end

  end
end

public
def download(url, &block)
  task = DownloadFile.new(url)
  task.instance_eval(&block)

  file task._path do
    task.execute()
  end
end
