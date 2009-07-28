every 10.minutes do
  command File.expand_path(File.join(File.dirname(__FILE__),"../script/maintain_file_system"))
end
