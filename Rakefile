require 'rubygems'
require 'rake'
task :gemspec do
gemspec = Dir.new(".").find{|f| f =~ /.*gemspec/}
load gemspec
end
task :test do
	sh 'ruby test_*.rb'
end

task :package => [:gemspec] do
  sh "gem build #{gemspec}"
end

task :install => [:package] do
  sh "sudo gem install #{SPEC.name}-#{SPEC.version.version}.gem"
end

task :push => [:package] do
  sh "gem push #{SPEC.name}-#{SPEC.version.version}.gem"
end
task :commit do
  sh "git add -A"
  sh "git commit -m '#{ENV['m'] || "update..."}'"
end
task :deploy do
  sh "git push heroku master"
end

task :git do
  sh "git push origin master"
end
