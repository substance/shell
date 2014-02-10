
private

# extracts the platform from the bundle name
def _platform_name(bundle_name)
  ["linux", "macosx", "windows"].each do |p|
    return p if bundle_name.include?(p)
  end
  raise "Unsupported platform."
end

def create_linux_bundle(cef_bundle, cef_dir, cef_client_dir)
  release_folder = "#{cef_client_dir}/Release"

  zip cef_bundle do

    # ignore the dependencies as the dependent files
    # are not declared as output of another task (-> extracted from archive...)
    no_deps true

    add "#{cef_dir}/include" do
      as "cef/include"
    end

    add "#{cef_dir}/tests/cefclient" do
      as "cef/cefclient"
    end

    add "#{cef_dir}/tests/cefclient" do
      as "cef/cefclient"
    end

    add "#{release_folder}/libffmpegsumo.so" do
      as "cef/lib/libffmpegsumo.so"
    end

    add "#{release_folder}/lib/libcef.so" do
      as "cef/lib/libcef.so"
    end

    add "#{release_folder}/cef.pak" do
      as "cef/resource/cef.pak"
    end

    add "#{release_folder}/devtools_resources.pak" do
      as "cef/resource/devtools_resources.pak"
    end

    add "#{release_folder}/locales" do
      as "cef/resource/locales"
    end

  end
end

public
def createCefBundle(cef_bundle, cef_dir, cef_client_dir)
  platform_name = _platform_name(cef_bundle)
  case platform_name
  when "linux"
    create_linux_bundle(cef_bundle, cef_dir, cef_client_dir)
  when "macosx"
    raise "Not implemented"
  when "windows"
    raise "Not implemented"
  end

  # Add a dependency to trigger extraction of the client archive
  task cef_bundle => cef_client_dir
end
