class WorkerProcess < ActiveResource::Base
  RUNNING = :RUNNING
  KILLING = :KILLING
  DEAD    = :DEAD
  self.site = AR_SITE
end
