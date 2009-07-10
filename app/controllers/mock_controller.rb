require "json"

class MockController < ApplicationController
  include Spawn
  before_filter :parse_params

  def parse_params
    @msg = (JSON.parse(params["message"]) rescue "gotcha")
  end

  def index
    render :text => @msg.inspect
  end

  def kill
    render :text => "OK"
  end

  def transcode
    render :text => (rand*10000).ceil
    spawn do
      begin
        job = Job.find @msg["job_id"]
        job.set_status(Job::PROCESSING)
        one_third_sleeping_time = (
          job.original_file.size.to_i/\
          1024.0/1024.0/700.0*3600.0*rand
        ).ceil
        (1 + one_third_sleeping_time).times do |i|
          sleep 3
          job.convert_progress = i*100/one_third_sleeping_time
          job.save
        end
        job.set_status(Job::COMPLETED)
      rescue
        logger.debug $!.to_yaml
        logger.debug $!.backtrace.to_yaml
      ensure
        me = WorkerProcess.find(@msg["worker_process_id"])
        me.destroy
      end
    end
  end
end
