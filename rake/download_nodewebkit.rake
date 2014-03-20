if OS.windows?
  node_webkit_url = 'http://dl.node-webkit.org/v0.9.2/node-webkit-v0.9.2-win-ia32.zip'
elsif OS.mac?
  node_webkit_url = 'http://dl.node-webkit.org/v0.9.2/node-webkit-v0.9.2-osx-ia32.zip'
end

downloaded_zip = File.join('tmp', 'node-webkit.zip')
target_dir = File.join('tmp', 'node-webkit')

download node_webkit_url do
  path downloaded_zip
  binary true
end

unzip downloaded_zip do
  target_dir target_dir
end

desc "Downloads node-webkit for your platform."
task "download:node-webkit" => "unzip:#{downloaded_zip}" do
  # HACK: we need to fix file permissions as ruby zip does not respect those
  if OS.mac?
    contents = File.join(target_dir, 'node-webkit.app', 'Contents')
    File.chmod(0755, File.join(contents, 'MacOS', 'node-webkit'))
    File.chmod(0755, File.join(contents, 'Frameworks', 'node-webkit Helper.app', 'Contents', 'MacOS', 'node-webkit Helper'))
  end
end

task 'setup' => 'download:node-webkit'

task 'clean:download:node-webkit' do
  FileUtils.rm_f downloaded_zip
  FileUtils.rm_rf target_dir
end

task 'clean:all' => 'clean:download:node-webkit'
