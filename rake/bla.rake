template "out.txt" do
  source "templates/dummy.erb"
  values :name => "Oliver",
         :bla => "blupp"
  mode   0644
end

desc "This is a test task."
task :bla => ["out.txt"] do
  sh "echo 'After this there should be out.txt.'"
end
