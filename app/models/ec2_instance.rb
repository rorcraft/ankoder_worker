class Ec2Instance < ActiveResource::Base
  BOOTING = "BOOTING"
  RUNNING = "RUNNING"
  TERMINATED = "TERMINATED"
  self.site = AR_SITE
end
