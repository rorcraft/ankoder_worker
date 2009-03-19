namespace :spec do
  desc "Run Unit Specs"
  Spec::Rake::SpecTask.new("units") do |t| 
    t.spec_files = FileList['spec/units/**/*.rb']
    t.spec_opts = %w( --color )
  end

  desc "Run Integration Specs"
  Spec::Rake::SpecTask.new("integrations") do |t| 
    t.spec_files = FileList['spec/integrations/**/*.rb']
    t.spec_opts = %w( --color )
  end
end

desc "Run unit and integration specs"
task :spec => ["spec:units", "spec:integrations"]

# Echo defines the :default task to run the :test task
task :test => :spec
