require 'fileutils'
require 'json'

private

CONFIG = @config
BUNDLE = File.join('dist', "#{@config[:app_name]}.app")
INFO_PLIST = File.join(BUNDLE, 'Contents', 'Info.plist')
ICONS_SOURCE_FILE = File.join(SHELL_CONFIG_DIR, 'resources', @config[:app_osx_icns])
ICONS_DIST_FILE = File.join(BUNDLE, 'Contents', 'Resources', @config[:app_osx_icns])
CREDITS_SOURCE_FILE = File.join(SHELL_CONFIG_DIR, 'resources', 'Credits.html')
CREDITS_DIST_FILE = File.join(BUNDLE, 'Contents', 'Resources', 'Credits.html')
APP_DIST = File.join(BUNDLE, 'Contents', 'Resources', 'app.nw')

if !File.exists?(ICONS_SOURCE_FILE)
  LOGGER.info "!!! Could not find icns file: #{ICONS_SOURCE_FILE}"
end

# Copy tmp/node-webkit.app to dist/<app-name>.app

task 'initialize:bundle:osx' do
  if File.exists?(BUNDLE)
    next
  end

  if !File.exists?('dist')
    FileUtils.mkdir_p('dist')
  end

  # copies the directory recursively
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'node-webkit.app'), BUNDLE)

  # remove the Info.plist to force re-generate
  FileUtils.rm INFO_PLIST

  FileUtils.rm File.join(BUNDLE, 'Contents', 'Resources', 'nw.icns')
end

# Generate dist/<app-name>.app/Contents/Info.plist from template

template INFO_PLIST do
  source "templates/Info.plist.erb"
  values 'config' => CONFIG
  mode   0644
end

# Copy the custom icons file into the bundle

file ICONS_DIST_FILE => ICONS_SOURCE_FILE do
  cp ICONS_SOURCE_FILE, ICONS_DIST_FILE
end

# Copy Credits.html if exist
file CREDITS_DIST_FILE => CREDITS_SOURCE_FILE do
  if File.exists?(CREDITS_SOURCE_FILE)
    cp CREDITS_SOURCE_FILE, CREDITS_DIST_FILE
  end
end


# Copy the app into the bundle or create a symbolic link
if ENV['env'] == 'development'
  task 'bundle:osx:app' do
    if File.exists?(APP_DIST)
      FileUtils.rm_rf APP_DIST
    end
    FileUtils.ln_s(APP_DIR, APP_DIST)
  end
else
  task 'bundle:osx:app' do
    if File.exists?(APP_DIST)
      FileUtils.rm_rf APP_DIST
    end
    FileUtils.copy_r(APP_DIR, APP_DIST)
  end
end

def deep_merge(first, second)
  merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
  first.merge(second, &merger)
end

task 'bundle:osx:package.json' do
  if ENV['env'] != 'development'
    puts "Preparing package.json..."

    package_config_file = File.join(APP_DIR, 'package.json')
    package_config_dist_file = File.join(APP_DIST, 'package.json')

    json = File.read(package_config_file)
    config = JSON.parse(json)

    # overwrite with user specific package.json settings
    if CONFIG.key?(:package_json)
      config = deep_merge(config, CONFIG[:package_json])
    end

    # this is hard coded: set the 'name' property to the configured application name
    # E.g., this will influence the application menu
    config["name"] = CONFIG[:app_name]

    # finally write out the adapted package.json
    File.open package_config_dist_file, "w" do |f|
      f.print JSON.pretty_generate(config)
    end
  end
end

################
# TODO: we could extend the package.json according to

task 'bundle:osx' => ['initialize:bundle:osx', INFO_PLIST, ICONS_DIST_FILE, CREDITS_DIST_FILE, 'bundle:osx:app', 'bundle:osx:package.json']


task 'clean:bundle:osx' do
  FileUtils.rm_rf BUNDLE
end

task 'clean' => 'clean:bundle:osx'
