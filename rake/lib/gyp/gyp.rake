private

MODIFIED_GYP = File.dirname(__FILE__) + "/modified-gyp"
GYP ="tools/gyp/gyp-wrapper"

namespace :setup do

  # clone the gyp github repository
  directory "tools/gyp" do
    directory "tools"
    # TODO: hopefully, this works on all platforms
    sh "git clone --depth 1 https://github.com/svn2github/gyp.git tools/gyp"
  end

  # place the wrapper for gyp which allows using gyp without installation
  file GYP => MODIFIED_GYP do
    puts "Copying gyp wrapper..."
    cp MODIFIED_GYP, GYP
    File.chmod(0755, GYP)
  end

  # register a task 'setup:gyp'
  desc "Downloads and prepares gyp."
  task :gyp => ["tools/gyp", GYP]
end

# Add a dependency to the setup task
task :setup => 'setup:gyp'


# API for gyp related tasks
# -----
public

# TODO elaborate
def gyp(args)
  sh "#{GYP} #{args.join(' ')}"
end
