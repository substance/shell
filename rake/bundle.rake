private

if OS.windows?
  import "rake/bundle_win.rake"
  platform_specific_task = "bundle:win"
elsif OS.mac?
  import "rake/bundle_osx.rake"
  platform_specific_task = "bundle:osx"
end

desc "Creates a platform specific application bundle ready for distribution."
task "bundle" => platform_specific_task