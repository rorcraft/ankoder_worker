# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

%w( video profile job ).each do |model|
  eval %{
    def #{model}(name)
        path = File.join(RAILS_ROOT, "spec", "remote_fixtures", "#{model}s", "\#\{name\}.xml")
        return nil unless File.exists?(path)
        File.read path
    end    
    
  }
end

def videos(name)
    case name
    when :kites then Video.find(1)
    else nil
    end
end

def jobs(name)
    case name
    when :kites_to_flv then Job.find(1)
    when :kites_to_wmv then Job.find(2)
    when :kites_to_divx then Job.find(3)
    when :kites_to_mov then Job.find(4)
    when :kites_to_rm then Job.find(5)
    else nil
    end
#     args = name.to_s.split "_"
#     _video = args[0]
#     _profile = args[2]
#     _j = Job.new :id => rand(12345)
#     _j.original_file_id =  videos(_video.to_sym).id
#     _j.profile_id = profiles(_profile.to_sym).id
#     _j
end

def profiles(name)  
    case name
    when :flv then Profile.find(1)
    when :wmv then Profile.find(2)
    when :divx then Profile.find(3)
    when :mov then Profile.find(4)
    when :rm then Profile.find(5)
#     when :flv320x240 then Profile.find(2)
    else nil
    end
end
  
def remote_fixtures
  require 'active_resource/http_mock'
  # @kites  = { :id => 1, :name => 'Kites.mp4' }.to_xml(:root => 'video')

  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/videos/1.xml", {}, video(:kites)
    mock.get "/jobs/1.xml", {}, job(:kites_to_flv)    
    mock.get "/jobs/2.xml", {}, job(:kites_to_wmv)    
    mock.get "/jobs/3.xml", {}, job(:kites_to_divx)    
    mock.get "/jobs/4.xml", {}, job(:kites_to_mov)    
    mock.get "/jobs/5.xml", {}, job(:kites_to_rm)    
    mock.get "/profiles/1.xml", {}, profile(:flv)
    mock.get "/profiles/2.xml", {}, profile(:wmv)
    mock.get "/profiles/3.xml", {}, profile(:divx)
    mock.get "/profiles/4.xml", {}, profile(:mov)
    mock.get "/profiles/5.xml", {}, profile(:rm)
#     mock.get "/profiles/2.xml", {}, profile(:flv320x240)
    # mock.get "/tools/1/users/0.xml", {}, nil, 404
    # mock.get "/tools/1/users/.xml", {}, nil, 404
  end
end
  
