namespace :setup do

  desc "Setup hello_world project using gyp."
  task :hello_world => ['setup:gyp'] do
    gyp ['gyp/hello_world.gyp', '--depth=.', '-f make', '--generator-output=./build/makefiles']
  end

end
