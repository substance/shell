require 'fileutils'
require 'json'

private

def deep_merge(first, second)
  merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
  first.merge(second, &merger)
end

def adapt_package_config(app_dist_folder)
  puts "Preparing package.json..."

  package_config_file = File.join(APP_DIR, 'package.json')
  package_config_dist_file = File.join(app_dist_folder, 'package.json')

  json = File.read(package_config_file)
  config = JSON.parse(json)

  # overwrite with user specific package.json settings
  if CONFIG.key?(:package_json)
    config = deep_merge(config, CONFIG[:package_json])
  end

  # this is hard coded: set the 'name' property to the configured application name
  # E.g., this will influence the application menu
  config["name"] = CONFIG[:app_name]
  config["environment"] = "production"

  # finally write out the adapted package.json
  File.open package_config_dist_file, "w" do |f|
    f.print JSON.pretty_generate(config)
  end
end

# NOTE: bundling for linux is very similar to windows
# TODO: factor out the shared stuff and separate
if OS.windows?
  import "rake/bundle_win.rake"
  platform_specific_task = "bundle:win"
elsif OS.mac?
  import "rake/bundle_osx.rake"
  platform_specific_task = "bundle:osx"
elsif OS.linux?
  import "rake/bundle_linux.rake"
  platform_specific_task = "bundle:linux"
end

desc "Creates a platform specific application bundle ready for distribution."
task "bundle" => platform_specific_task
