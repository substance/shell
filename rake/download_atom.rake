
if OS.windows?
  atom_url = 'https://github.com/atom/atom-shell/releases/download/v0.13.3/atom-shell-v0.13.3-win32-ia32.zip'
  downloaded_archive = File.join('tmp', 'atom-shell-v0.13.3-win32-ia32.zip')
elsif OS.mac?
  atom_url = 'https://github.com/atom/atom-shell/releases/download/v0.13.3/atom-shell-v0.13.3-darwin-x64.zip'
  downloaded_archive = File.join('tmp', 'atom-shell-v0.13.3-darwin-x64.zip')
elsif OS.linux?
  atom_url = 'https://github.com/atom/atom-shell/releases/download/v0.13.3/atom-shell-v0.13.3-linux-x64.zip'
  downloaded_archive = File.join('tmp', 'atom-shell-v0.13.3-linux-x64.zip')
end

target_dir = File.join('tmp', 'atom-shell')

download atom_url do
  path downloaded_archive
  binary true
end

unzip downloaded_archive do
  target_dir target_dir
end

desc "Downloads atom-shell for your platform."
task "download:atom-shell" => "unzip:#{downloaded_archive}" do
  # HACK: we need to fix file permissions as ruby zip does not respect those
  if OS.mac?
    contents = File.join(target_dir, 'Atom.app', 'Contents')
    File.chmod(0755, File.join(contents, 'MacOS', 'Atom'))
    File.chmod(0755, File.join(contents, 'Frameworks', 'Atom Helper.app', 'Contents', 'MacOS', 'Atom Helper'))
  end
end

task 'setup' => 'download:atom-shell'

task 'clean:download:atom-shell' do
  FileUtils.rm_f downloaded_archive
  FileUtils.rm_rf target_dir
end

task 'clean:all' => 'clean:download:atom-shell'
