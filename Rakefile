require "./rake/lib/basics"

APP_DIR = File.join(File.dirname(__FILE__), 'app')
SHELL_CONFIG_DIR = File.join(APP_DIR, 'config')

LOGGER.formatter = proc do |serverity, time, progname, msg|
  "--#{msg}\n"
end

# Configuration
# -------------

@config = {}
config_file = File.join(SHELL_CONFIG_DIR, 'config.rb')

if (File.exists? config_file)
  require config_file
else
  LOGGER.info "Could not find configuration: #{config_file}"
end

desc 'Download everything necessary for building and bundling'
task 'setup'


import "rake/download_atom.rake"
import "rake/bundle.rake"
