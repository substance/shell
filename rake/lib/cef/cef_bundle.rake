# Unfortunately the CEF binaries can not be downloaded programmatically,
# as they are password protected.
# So we have to download the binaries manually and apply the following tasks
# to create bundles that we provide via github download links.
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
directory @cef_dir do
  sh "git clone --depth 1 #{cef_repository} #{@cef_dir}"
end

namespace :prereq do
  desc "Creates a minimal CEF3 bundle."
  task :cef_bundle => [@cef_dir] do

    # Present a message if no archives are there
    if cef_client_archives.empty?
      log.warn "No CEF client archives found."
      log.warn "You have to download an archive for CEF #{CEF_VERSION} and put it into 'tmp/'"
      return
    end
  end
end

# For each found archive we setup a task chain to create a zip-bundle

def create_bundle(cef_archive)
  cef_client_dir = "tmp/#{File.basename(cef_archive, '.*')}"
  cef_bundle_dir = "#{cef_client_dir}_bundle"
  cef_bundle = "#{cef_client_dir}.zip"

  lib_folder = "#{cef_bundle_dir}/lib"
  resource_folder = "#{cef_bundle_dir}/resource"
  release_folder = "#{cef_client_dir}/Release"

  # Extract CEF archive
  directory cef_client_dir do
    log.info "Unpacking CEF client archive #{cef_archive}..."
    sh "7zr x -otmp/ #{cef_archive}"
  end

  # Create directories
  directory cef_bundle_dir
  directory resource_folder
  directory lib_folder

  platform_name = nil
  ["linux", "macosx", "windows"].each do |p|
    platform_name = p if cef_archive.include?(p)
  end

  file cef_bundle => [cef_client_dir, cef_bundle_dir, resource_folder, lib_folder] do
    copy "#{@cef_dir}/include", cef_bundle_dir
    copy "#{@cef_dir}/tests/cefclient", cef_bundle_dir

    case platform_name
    when "linux"
      copy "#{release_folder}/libffmpegsumo.so", lib_folder
      copy "#{release_folder}/lib/libcef.so", lib_folder
      copy "#{release_folder}/cef.pak", resource_folder
      copy "#{release_folder}/devtools_resources.pak", resource_folder
      copy "#{release_folder}/locales", resource_folder
    when "macosx"
      # TODO: this is rather lazy. Should copy only what is really necessary
      # Have to wait until I know what is actually needed to build a cef app.
      frameworks_folder = "#{release_folder}/cefclient.app/Contents/Frameworks"
      copy "#{frameworks_folder}", lib_folder
    else
      puts "Copy cef files is not implemented yet!"
    end

    # TODO: factor out some stuff from Rake's PackageTask into a light-weight helper
    # see https://github.com/jimweirich/rake/blob/master/lib/rake/packagetask.rb
    chdir(cef_bundle_dir) do
      sh %{zip -r ../#{File.basename(cef_bundle)} *}
    end
  end

end

cef_client_archives.each do |f|
  cef_client_dir = "tmp/#{File.basename(f, '.*')}"
  cef_bundle_dir = "#{cef_client_dir}_bundle"
  cef_bundle = "#{cef_client_dir}.zip"

  create_bundle(f)

  # Cleanup
  desc "Cleanup temporary files from CEF bundling."
  task "clean:cef_bundle" do
    clean cef_client_dir
    clean cef_bundle_dir
    clean cef_bundle
  end

  # Add task dependencies
  task "prereq:cef_bundle" => cef_bundle
  task "clean:all" => "clean:cef_bundle"
end
