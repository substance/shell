# We patch the built-in require to allow require-js style requires on directories.
# Such a directory must provide an `index.rb` file.

module Kernel
  alias_method :original_require, :require

  def require(path)
    return original_require path
  rescue LoadError => e
    if File.exist?(path + "/index.rb")
        return original_require path + "/index"
    end
    raise e
  end
end
