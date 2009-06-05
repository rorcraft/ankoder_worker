require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/downloader")

describe Downloader do
  remote_fixtures
  include Transcoder::Helper

  def download url,params={}, &block
    filename = "downloader_spec_testfile"
    # if file already exists, axel tries to resume instead of truncate.
    statefile= filename + '.st'
    file_path = File.join(Downloader::TEMP_FOLDER, filename)
    File.delete(file_path) if File.exists?(file_path)
    File.delete(statefile) if File.exists?(statefile)
    if params[:username] && params[:password]
      assert Downloader.download(:url=>url,:local_filename=>filename,
				 :username=>params[:username],
				 :password=>params[:password],&block)
    else
      assert Downloader.download(:url=>url, :local_filename=>filename, &block)
    end
    assert (exist=File.exists?(file_path))
    assert (File.size(file_path)==params[:size]) if params[:size]
    File.delete(file_path) if exist
  end

  it "should output ftp command" do
    cmd = Downloader.command('ftp://ftp.cse.cuhk.edu.hk/HOW_TO_SUBMIT', "29mb.mov")
    puts cmd
    cmd.should_not be_nil
  end

  it "should output http with auth command" do
    cmd = Downloader.command \
      "http://www.archive.org/download/EricZimmermanMyTestAVIfile.../test.avi",\
      'useless_file',\
      {:username=>'schneider',:password=>'AEBl4eOv'} 
    puts cmd
    cmd.should_not be_nil
  end

  it 'should output sftp command' do
    cmd=Downloader.command \
      'sftp://rorcraft@192.168.1.11/home/rorcraft/caiyufei/29mb.flv',\
      'big_useless_file'
    puts cmd
    cmd.should_not be_nil
  end

  it 'should output s3 command' do
    cmd = Downloader.command \
      's3://this.is.a.bucket/this.is.a.file', file='useless_file'
    path = File.join(Downloader::TEMP_FOLDER, file)
    puts cmd
    cmd.should_not be_nil
  end

  it 'should output s3 command in http syntax' do
    cmd = Downloader.command \
      'http://s3.amazonaws.com/this.is.a.bucket/this.is.a.file', \
      file='useless_file'
    path = File.join(Downloader::TEMP_FOLDER, file)
    puts cmd
    cmd.should_not be_nil
    assert_equal 'curl', cmd.slice(/\S+/)
  end

  it 'should output youtube command' do
    url = 'http://www.youtube.com/watch?v=9uDgJ9_H0gg'
    cmd = Downloader.command url, file='useless_file'
    cmd.should_not be_nil
    return unless cmd
    puts cmd
    cmd_url = cmd.slice(/http:\/\/\S+/)
    assert_not_equal cmd_url, url
  end

  it 'should output dailymotion command' do
    url='http://dailymotion.com/relevance/search/shortest+video+on+youtube/video/x3zqyf_shortest-video-ever-on-youtube_fun'
    cmd = Downloader.command url, file='useless_file'
    cmd.should_not be_nil
    return unless cmd
    puts cmd
    cmd_url = cmd.slice(/http:\/\/\S+/)
    assert_not_equal cmd_url, url
  end

  it "should download under http" do        
    download "http://www.4chan.org/"
  end

  it "should download under ftp" do
    download 'ftp://ftp.cse.cuhk.edu.hk/HOW_TO_SUBMIT'
  end

  it "should download under http with auth" do
    # this test need local rails application with basic authentication
    # username: user
    # password: password
    download 'http://localhost:3000/', \
      {:username=>'user',:password=>'password'}
  end

  it 'should download under ftp with auth' do
    download 'ftp://ftp.filekeeper.org/todo.txt', \
      {:username=>'schneider',:password=>'AEBl4eOv'}
  end

  it 'should download under sftp' do
    # This test fails when the machine specified in URL does not have the public
    # counterpart of the test-runner's private key.
    download 'sftp://rorcraft@192.168.1.11/home/rorcraft/.ssh/authorized_keys'
  end

  it 'should download under s3' do
    download 's3://this.is.a.bucket/this.is.a.file'
  end

  it 'should download under s3 in http syntax' do
    download 'http://s3.amazonaws.com/this.is.a.bucket/this.is.a.file'
  end

  it 'should download under private s3' do
    download 'http://s3.amazonaws.com/testVideo/kites.mp4'
  end

  it 'should download from third party under s3' do
    download 'http://s3.amazonaws.com/rex-ankodertest/kites.mp4'
  end

  it 'should show progress using curl under s3' do
    pass = false
    old_progress = nil
    download 's3://testVideo/WayneCooper.flv' do |progress|
      pass = true
      puts "Progress = #{progress}"
      assert progress_need_refresh?(old_progress, progress)
      old_progress = progress
    end
    assert pass
  end

  it 'should show progress using scp'

  it 'should show progress using axel' do
    pass = false
    old_progress =nil
    download \
      "http://www.archive.org/download/EricZimmermanMyTestAVIfile.../test.avi"\
      do |progress|
      pass = true
      puts "Progress = #{progress}"
      assert progress_need_refresh?(old_progress, progress)
      old_progress = progress
    end
    assert pass
  end

  it 'should show progress using curl' do
    pass = false
    old_progress =nil
    download \
      "http://www.archive.org/download/EricZimmermanMyTestAVIfile.../test.avi",\
      {:username=>'schneider',:password=>'AEBl4eOv'} \
      do |progress|
      pass = true
      puts "Progress = #{progress}"
      assert progress_need_refresh?(old_progress, progress)
      old_progress = progress
    end
    assert pass
  end

  it 'should download from youtube' do
    download 'http://youtube.com/watch?v=9uDgJ9_H0gg',\
      {:size => 29714}
  end

  it 'should download from dailymotion', {:size => 23442} do
    url='http://www.dailymotion.com/relevance/search/shortest+video+on+youtube/video/x3zqyf_shortest-video-ever-on-youtube_fun'
    download url
  end

  #it "should download from Metacafe (uncomment this)"

end
