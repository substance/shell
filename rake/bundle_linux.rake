require 'fileutils'
require 'json'
require 'template_task'
#require 'date'

private

CONFIG = @config

APP_DIST = File.join('dist', 'package_root', 'usr', 'share', CONFIG[:app_exe]);
DEBIAN_FOLDER = File.join('dist', 'package_root', 'DEBIAN')

# create directories
task 'bundle:prepare:linux' do
  if !File.exists?(APP_DIST)
    FileUtils.mkdir_p(APP_DIST)
  end
  if !File.exists?(DEBIAN_FOLDER)
    FileUtils.mkdir_p(DEBIAN_FOLDER)
  end
end
task 'bundle:prepare' => 'bundle:prepare:linux'

# - copy node-webkit
# NOTE: nw is renamed using the application executable name
task 'bundle:nw:linux' do
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'nw'), File.join(APP_DIST, CONFIG[:app_exe]))
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'nw.pak'), APP_DIST)
  FileUtils.copy_r(File.join('tmp', 'node-webkit', 'libffmpegsumo.so'), APP_DIST)

  # fix permissions for executables
  File.chmod(0755, File.join(APP_DIST, CONFIG[:app_exe]))
  File.chmod(0755, File.join(APP_DIST, 'libffmpegsumo.so'))
end

# - copy the app into dist
task 'bundle:app:linux' do
  FileUtils.copy_r( Dir.glob(File.join(APP_DIR, '*')), APP_DIST )
  FileUtils.copy_r( File.join(APP_DIR, 'config', 'resources', 'icons'), APP_DIST )
  FileUtils.copy_r( File.join(APP_DIR, 'config', 'linux', 'mime'), APP_DIST )
end

task 'bundle:package.json:linux' do
  adapt_package_config(APP_DIST)
end
task 'bundle:package.json' => 'bundle:package.json:linux'

task 'bundle:prune:linux' do
  log.info "Removing git folders..."
  FileUtils.rm_rf Dir.glob(APP_DIST+'/**/.git')
  FileUtils.rm_rf File.join(APP_DIST, 'config')
end

deb_config_reqs = []

deb_control_file = File.join(DEBIAN_FOLDER, 'control')
deb_config_reqs.push(deb_control_file)

task deb_control_file do
  dist_size = `du -s dist/package_root`
  dist_size = dist_size.split(" ")[0]
  dist_date = Date.today.rfc2822
  
  TemplateTask::create deb_control_file do
    source  File.join('templates', 'linux', 'DEBIAN', "control.erb")
    values  'config' => CONFIG,
            'dist_size' => dist_size,
            'dist_date' => dist_date
    mode    0644
  end
end

[
  ['postinst', 0755],
  ['prerm', 0755]
].each do |f, mode|
  config_file = File.join(DEBIAN_FOLDER, f)
  deb_config_reqs.push(config_file)

  template config_file do
    source  File.join('templates', 'linux', 'DEBIAN', "#{f}.erb")
    values  'config' => CONFIG
    mode    mode
  end
end

desktop_file = File.join(APP_DIST, "#{CONFIG[:app_exe]}.desktop")
deb_config_reqs.push(desktop_file)

template desktop_file do
  source  File.join('templates', 'linux', 'app.desktop.erb')
  values  'config' => CONFIG
  mode    0644
end

Rake::Task[desktop_file].enhance do
  sh "desktop-file-validate #{desktop_file}"
end

task 'bundle:installer:linux' => deb_config_reqs do
  log.info "Creating debian package..."
  Dir.chdir 'dist' do
    sh "fakeroot dpkg-deb --build package_root"
    FileUtils.mv('package_root.deb', CONFIG[:deb_file_name])
  end
end

task 'bundle:linux' => [
  'bundle:prepare:linux',
  'bundle:nw:linux',
  'bundle:app:linux',
  'bundle:package.json:linux',
  'bundle:prune:linux',
  'bundle:installer:linux'
]

task 'clean:bundle:linux' do
  FileUtils.rm_rf Dir.glob(File.join('dist', "*"))
end
task 'clean' => 'clean:bundle:linux'
