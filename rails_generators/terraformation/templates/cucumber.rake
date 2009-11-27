# Find vendored gem or plugin of cucumber
vendored_cucumber_dir = Dir["#{RAILS_ROOT}/vendor/{gems,plugins}/cucumber*"].first
$LOAD_PATH.unshift("#{vendored_cucumber_dir}/lib") unless vendored_cucumber_dir.nil?

unless ARGV.any? {|a| a =~ /^gems/}

begin
  require 'cucumber/rake/task'

  # Use vendored cucumber binary if possible. If it's not vendored,
  # Cucumber::Rake::Task will automatically use installed gem's cucumber binary
  vendored_cucumber_binary = "#{vendored_cucumber_dir}/bin/cucumber" unless vendored_cucumber_dir.nil?

  namespace :cucumber do
    Cucumber::Rake::Task.new({:ok => 'db:test:prepare'}, 'Run features that should pass') do |t|
      t.binary = vendored_cucumber_binary
      t.fork = true # You may get faster startup if you set this to false
      t.cucumber_opts = "--tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
    end

    Cucumber::Rake::Task.new({:wip => 'db:test:prepare'}, 'Run features that are being worked on') do |t|
      t.binary = vendored_cucumber_binary
      t.fork = true # You may get faster startup if you set this to false
      t.cucumber_opts = "--tags @wip:2 --wip --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
    end

    desc 'Run all features'
    task :all => [:ok, :wip]
  end
  desc 'Alias for cucumber:ok'
  task :cucumber => 'cucumber:ok'

  task :default => :cucumber

  task :features => :cucumber do
    STDERR.puts "*** The 'features' task is deprecated. See rake -T cucumber ***"
  end
rescue LoadError
  desc 'cucumber rake task not available (cucumber not installed)'
  task :cucumber do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end

end
