private

cef_dir = "third_party/cef"
cef_repository = "https://bitbucket.org/chromiumembedded/branches-1650-cef3.git"

os = nil
if OS.linux?
  os = "linux"
elsif OS.mac?
  os = "macosx"
elsif OS.windows?
  os = "windows"
else
  raise RuntimeError, "Unsupported platform"
end
if OS.x64?
  cef_bundle = "cef_binary_3.#{CEF_VERSION}_#{os}64_minimal.zip"
else
  cef_bundle = "cef_binary_3.#{CEF_VERSION}_#{os}32_minimal.zip"
end

download_url = nil

namespace :setup do

  download download_url do
    path "tmp/#{cef_bundle}"
  end

  file "tmp/cef_bundle" do

  end

  desc "Downloads the CEF binaries for your platform."
  task :cef => [cef_dir] do
  end
end
