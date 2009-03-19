# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rvideo}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Dahl (Slantwise Design)", "Seth Thomas Rasmussen", "Jeremy Green"]
  s.date = %q{2009-03-04}
  s.description = %q{TODO}
  s.email = %q{jgreen@webeprint.com}
  s.files = ["VERSION.yml", "lib/rvideo", "lib/rvideo/errors.rb", "lib/rvideo/version.rb", "lib/rvideo/transcoder.rb", "lib/rvideo/reporter", "lib/rvideo/reporter/views", "lib/rvideo/reporter/views/report.html.erb", "lib/rvideo/reporter/views/report.js", "lib/rvideo/reporter/views/index.html.erb", "lib/rvideo/reporter/views/report.css", "lib/rvideo/tools", "lib/rvideo/tools/mp4creator.rb", "lib/rvideo/tools/mplayer.rb", "lib/rvideo/tools/yamdi.rb", "lib/rvideo/tools/mencoder.rb", "lib/rvideo/tools/mp4box.rb", "lib/rvideo/tools/flvtool2.rb", "lib/rvideo/tools/ffmpeg2theora.rb", "lib/rvideo/tools/abstract_tool.rb", "lib/rvideo/tools/ffmpeg.rb", "lib/rvideo/inspector.rb", "lib/rvideo/string.rb", "lib/rvideo/reporter.rb", "lib/rvideo/float.rb", "lib/rvideo.rb", "spec/fixtures", "spec/fixtures/recipes.yml", "spec/fixtures/ffmpeg_builds.yml", "spec/fixtures/files.yml", "spec/fixtures/ffmpeg_results.yml", "spec/spec_helper.rb", "spec/spec.opts", "spec/integrations", "spec/integrations/recipes_spec.rb", "spec/integrations/rvideo_spec.rb", "spec/integrations/transcoder_integration_spec.rb", "spec/integrations/formats_spec.rb", "spec/integrations/inspection_spec.rb", "spec/integrations/transcoding_spec.rb", "spec/files", "spec/files/boat.avi", "spec/files/kites.mp4", "spec/support.rb", "spec/units", "spec/units/inspector_spec.rb", "spec/units/mplayer_spec.rb", "spec/units/string_spec.rb", "spec/units/mp4creator_spec.rb", "spec/units/abstract_tool_spec.rb", "spec/units/flvtool2_spec.rb", "spec/units/mp4box_spec.rb", "spec/units/ffmpeg_spec.rb", "spec/units/mencoder_spec.rb", "spec/units/transcoder_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jagthedrummer/rvideo}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
