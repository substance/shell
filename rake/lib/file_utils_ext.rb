require 'fileutils'

public
module Rake
  module FileUtilsExt
    alias_method :original_copy, :copy
    alias_method :original_mkdir, :mkdir

    def copy(source, target)
      if !File.exists?(source)
        raise "Can not copy: file/directory does not exist. #{source}"
      end

      if File.directory?(source)
        log.info "Copying directory #{source} => #{target} ..."
        FileUtils.cp_r(source, target)
      else
        log.info "Copying #{source} => #{target} ..."
        original_copy source, target
      end
    end

    def copy_glob(glob, target_dir)
      files = Dir.glob(glob)

      if files.empty?
        log.warn "copy_glob: no files found for #{glob}."
        return
      end

      if !File.directory?(target_dir)
        raise "copy_glob: target must be a directory."
      end

      files.each do |f|
        original_copy f, target_dir
      end
    end

    def mkdir(path)
      if File.exists?(path)
        if File.directory?(path)
          return
        else
          raise "mkdir: file already exists #{path}."
        end
      end
      original_mkdir path
    end
  end
end

