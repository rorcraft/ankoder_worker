class Ec2Instance < ActiveResource::Base
  BOOTING = "BOOTING"
  RUNNING = "RUNNING"
  TERMINATED = "TERMINATED"
  self.site = AR_SITE

  def escape_primary_key(string)
    string.gsub(/\./,"*").gsub(/\//,"\\")
  end
end
