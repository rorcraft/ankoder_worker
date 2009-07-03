class Ec2Instance < ActiveResource::Base
  BOOTING = "BOOTING"
  RUNNING = "RUNNING"
  TERMINATED = "TERMINATED"
  self.site = AR_SITE

  set_primary_key :escaped_hostname

  def self.escape_primary_key(string)
    string.gsub(/\./,"*").gsub(/\//,"\\")
  end

  def new?
    false # thou canst not create.
  end

  def id
    escaped_hostname
  end
end
