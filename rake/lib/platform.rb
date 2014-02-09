module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end

  def OS.x64?
    (/x86_64/ =~ RUBY_PLATFORM) != nil
  end

  def OS.name
    if OS.windows?
      return "windows"
    elsif OS.mac?
      return "macosx"
    elsif OS.linux?
      return "linux"
    else
      return "unix"
    end
  end
end
