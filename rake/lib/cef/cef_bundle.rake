# Unfortunately the CEF binaries can not be downloaded programmatically,
# as they are password protected.
# So we have to download the binaries manually and apply the following tasks
# to create bundles that we will host ourselves.
require File.join(File.dirname(__FILE__), "cef_bundle")

private

@cef_dir = "tmp/cef-1650"
cef_repository = "https://bitbucket.org/chromiumembedded/branches-1650-cef3.git"
cef_client_archives = Dir['tmp/cef_binary_3.*_client.7z']

# locations of the cef libraries within the cef client release folder
cef_libs = {
  "linux" => ["lib/", "libffmpegsumo.so"],
  "macosx" => ["lib/libcef.dylib", "libffmpegsumo.dylib"],
  "windows" => ["lib/libcef.dll", "libffmpegsumo.dll"]
}

# Tasks
# ----

# Clone CEF repository
Git.clone cef_repository do
  path @cef_dir
  depth 1
end

desc "Creates a minimal CEF3 bundle."
task 'prereq:cef_bundle' => [@cef_dir] do

  # Present a message if no archives are there
  if cef_client_archives.empty?
    log.warn "No CEF client archives found."
    log.warn "You have to download an archive for CEF #{CEF_VERSION} and put it into 'tmp/'"
    return
  end
end

cef_client_archives.each do |cef_archive|
  cef_client_dir = "tmp/#{File.basename(cef_archive, '.*')}"
  cef_bundle = "#{cef_client_dir}.zip"

  # Extract CEF archive
  directory cef_client_dir do
    log.info "Unpacking CEF client archive #{cef_archive}..."
    sh "7zr x -otmp/ #{cef_archive}"
  end

  createCefBundle(cef_bundle, @cef_dir, cef_client_dir)

  # Cleanup
  desc "Cleanup temporary files from CEF bundling."
  task "clean:cef_bundle" do
    clean cef_client_dir
    clean cef_bundle
  end

  # Add task dependencies
  task "prereq:cef_bundle" => cef_bundle
  task "clean:all" => "clean:cef_bundle"
end
