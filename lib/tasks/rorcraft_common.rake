desc "Look for TODO and FIXME tags in the code"
task :todo do
  FileList["**/*.rb"].egrep /#.*(FIXME|TODO|TBD)/
end