#!/usr/bin/env ruby
# Make sure stdout and stderr write out without delay for using with daemon like scripts
STDOUT.sync = true; STDOUT.flush
STDERR.sync = true; STDERR.flush

#script/poller [start|stop|run] -- [development|test|production] 

unless ENV['RAILS_ENV']
  rails_mode = ARGV.first || "development"
  unless ["development", "test", "production"].include?(rails_mode)
    raise "Unknown rails environment '#{rails_mode}'.  (Choose 'development', 'test' or 'production')"
  end
  ENV['RAILS_ENV'] = rails_mode
end

# Load Rails
RAILS_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..','..','..'))
load File.join(RAILS_ROOT, 'config', 'environment.rb')

# Load ActiveMessaging processors
ActiveMessaging::load_processors

# Start it up!
ActiveMessaging::start
