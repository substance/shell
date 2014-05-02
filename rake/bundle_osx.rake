require 'fileutils'
require 'pathname'
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
  source "templates/osx/Info.plist.erb"
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

task 'bundle:osx:package.json' do
  if ENV['env'] != 'development'
    adapt_package_config(APP_DIST)
  end
end

task 'bundle:osx:prune' do
  if ENV['env'] != 'development'
    FileUtils.rm_rf Dir.glob(APP_DIST+"/**/.git")
  end
end

task 'bundle:archive:osx' do
  if ENV['env'] != 'development'
    Dir.chdir('dist') do
      sh "zip -r #{CONFIG[:osx_archive_name]} '#{File.basename(BUNDLE)}'"
    end
  end
end

task 'bundle:osx' => ['initialize:bundle:osx', INFO_PLIST, ICONS_DIST_FILE, CREDITS_DIST_FILE, 'bundle:osx:app', 'bundle:osx:package.json', 'bundle:osx:prune', 'bundle:archive:osx']

task 'clean:bundle:osx' do
  FileUtils.rm_rf BUNDLE
  FileUtils.rm_rf File.join('dist', CONFIG[:osx_archive_name])
end

task 'clean' => 'clean:bundle:osx'
