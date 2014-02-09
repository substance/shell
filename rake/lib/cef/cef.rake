private
cef_lib = nil
download_url = nil

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
  cef_client_archive = "cef_binary_3.#{CEF_VERSION}_#{os}64_client.7z"
else
  cef_client_archive = "cef_binary_3.#{CEF_VERSION}_#{os}32_client.7z"
end

namespace :setup do

  directory "lib"

  file ["lib/#{cef_lib}"] do
  end

  desc "Downloads the CEF binaries for your platform."
  task :cef => [] do
  end
end
