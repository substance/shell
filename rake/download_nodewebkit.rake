
if OS.windows?
  raise "Not yet implemented"
elsif OS.mac?
  node_webkit_url = 'https://github.com/oliver----/node-webkit/releases/download/0.1/node-webkit.app.tar.gz
'
  downloaded_archive = File.join('tmp', 'node-webkit.app.tar.gz')
end

target_dir = File.join('tmp', 'node-webkit')

download node_webkit_url do
  path downloaded_archive
  binary true
end

unzip downloaded_archive do
  target_dir target_dir
end

desc "Downloads node-webkit for your platform."
task "download:node-webkit" => "unzip:#{downloaded_archive}" do
  # HACK: we need to fix file permissions as ruby zip does not respect those
  if OS.mac?
    contents = File.join(target_dir, 'node-webkit.app', 'Contents')
    File.chmod(0755, File.join(contents, 'MacOS', 'node-webkit'))
    File.chmod(0755, File.join(contents, 'Frameworks', 'node-webkit Helper.app', 'Contents', 'MacOS', 'node-webkit Helper'))
  end
end

task 'setup' => 'download:node-webkit'

task 'clean:download:node-webkit' do
  FileUtils.rm_f downloaded_archive
  FileUtils.rm_rf target_dir
end

task 'clean:all' => 'clean:download:node-webkit'
