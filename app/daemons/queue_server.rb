#!/usr/bin/env ruby
#FIXME: Can't get this to work, just use $queues manager start
#might consider this alternative if using our own message queue server - http://stompserver.rubyforge.org/

# Make sure stdout and stderr write out without delay for using with daemon like scripts
STDOUT.sync = true; STDOUT.flush
STDERR.sync = true; STDERR.flush

# Load Rails
RAILS_ROOT=File.expand_path(File.join(File.dirname(__FILE__), '..','..')) unless defined?(RAILS_ROOT)
# require File.join(RAILS_ROOT, 'config', 'environment')
require File.join(RAILS_ROOT,'vendor','gems','reliable-msg-1.1.0','lib','reliable-msg')

@qm = ReliableMsg::QueueManager.new  
@qm.start
