require 'fileutils'
require 'json'

private

CONFIG = @config


# There is no bunlding for development under windows.
# Just run node-webkit.exe from within the app directory

# For the release bundle do:

# - prune
# - adapt project.json
# - run inno-setup
#   - copy all recursively
#   - register application for .sdf files
#   - is there something like candidates for 'Open with...'?

# - copy 'nw.exe', 'nw.pak' and 'icudt.dll' into dist folder
task 'bundle:nw:win' do
  if !File.exists?('dist')
    FileUtils.mkdir_p('dist')
  end
  # copies the directory recursively
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'nw.exe'), File.join('dist', CONFIG[:app_exe]+'.exe'))
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'nw.pak'), 'dist')
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'icudt.dll'), 'dist')
end

# - copy the app into dist
task 'bundle:app:win' do
  FileUtils.copy_r( Dir.glob(File.join(APP_DIR, '*')) , 'dist')
end

task 'bundle:package.json:win' do
  adapt_package_config('dist')
end
task 'bundle:package.json' => 'bundle:package.json:win'


task 'bundle:prune:win' do
  log.info "Removing git folders..."
  FileUtils.rm_rf Dir.glob(File.join('dist/**/.git'))
end

task 'bundle:win' => ['bundle:nw:win', 'bundle:app:win', 'bundle:package.json:win', 'bundle:prune:win']

task 'clean:bundle:win' do
  FileUtils.rm_rf Dir.glob(File.join('dist', "*"))
end

task 'clean' => 'clean:bundle:win'
