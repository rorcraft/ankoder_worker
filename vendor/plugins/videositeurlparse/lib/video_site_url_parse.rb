require 'rexml/document'
require 'open-uri'

module VideoSiteUrlParse
  include REXML

  def curl_path
    defined?(CURL) ? CURL : "/usr/bin/curl"
  end

  # get the flv download address from the url
  def parse_video_url(url)
    url_video = case url.downcase
                when /^http:\/\/(www\.)?youtube\.com/
                  parse_youtube(url)
                # when /tudou/
                #   parse_tudou(url)
                when /^http:\/\/(www\.)?dailymotion\.com/
                  parse_dailymotion(url)
                # when /metacafe/
                #   parse_metacafe(url)
                else
                  url
                end
    url_video
  end


  def site_url(url)
    url =~ /(http\:\/\/(.*)\.com\/).*/
      puts $1
    $1
  end

  def video_id(url)
    url =~ /.*\?.*?=(.*?)\&.*/
      puts $1
    $1
  end

  # mp4
  #request# GET http://www.youtube.com/get_video?video_id=Sex4w4h7Tqk&t=vjVQa1PpcFNJPzyA7gOYrRM6W1vsCckhpKDdwfMJUqQ=&fmt=18
  # flv
  #request# GET http://www.youtube.com/get_video?video_id=Sex4w4h7Tqk&t=vjVQa1PpcFNJPzyA7gOYrRM6W1vsCckhpKDdwfMJUqQ=  
  def parse_youtube(url)
    source = `#{curl_path} "http://kej.tw/flvretriever/" -d "videoUrl=#{url}" -A "foo"`
    raise "Cannot parse youtube URL" unless(source =~ /<textarea id="outputfield">([^<]+)<\/textarea>/)
    $1
  end
  
  #no longer works
  def parse_tudou(url)
     tudou = "http://51hot.tudou.com/flv"
     url =~ /(\/programs\/view\/|\/program\/)(.*)\/?/     
     video_id = $1
     video_id += "/" unless video_id[-1,1] == "/"
     flv_url = nil
     if url =~ /hd\.tudou\.com/
        open "http://hd.tudou.com/program/#{video_id}" do |f|
          f.each_line do |line|
            if line =~ /\s+iid\s*=\s*(\d+);?/
                iid = $1
                # GET /m4v/021/160/235/21160235.m4v?18000&key=c4ac2906800cb47f0798cc49c380382733ddaf
                open("http://www.tudou.com/player/v.php?id=#{iid}") do |f2|
                  f2.each_line do |line2|
                    line2 =~ /<f w='10'>(.*?)<\/f>/
                    flv_url = $1
                    break
                  end
                end
             end
          end
        end
     else
       open("http://www.tudou.com/programs/view/#{video_id}") do |f|
         f.each_line do |line|
           if line =~ /var\s+iid\s*=\s*(\d+);?/
             iid = $1
             open("http://www.tudou.com/player/v.php?id=#{iid}") do |f2|
                f2.each_line do |line2|
                  line2 =~ /<f w='10'>(.*?)<\/f>/
                  flv_url = $1
                  break
                end
              end
             # doc = Document.new(open("http://www.tudou.com/player/v.php?id=#{iid}"))
             # flv_url = doc.root.elements[1].text.strip
             # puts flv_url
             break
           end
         end
       end
     end
     flv_url
  end

  # url example:
  # http://www.dailymotion.com/video/x44lvd_rates-of-exchange-like-a-renegade_music
  # /us/featured/cluster/tech/video/x6zoga_good-ecogym_travel
  def parse_dailymotion(url)
    str = `curl -L '#{url}'`.match(%r!addVariable\("video", "(.*)"\);!).to_a[1].split("%40%40")[0]
    "http://www.dailymotion.com#{CGI.unescape str}"
  end
  
  
  # Untested
  def parse_metacafe(url)
    metacafe = "http://v.mccont.com/ItemFiles/%5BFrom%20www.metacafe.com%5D%20"
    url =~ /\/watch\/(.*?)\/(.*?)\/?/
    video_id = $1
    video_id += "/" unless video_id[-1,1] == "/"
    flv_url = nil
    open("http://www.metacafe.com/watch/#{video_id}") do |f|
      f.each_line do |line|
        if line =~ /%5D%20(.*?)\.flv","gdaKey"\:"(.*?)"/
          flv_url = "#{metacafe}#{$1}.flv?_gda_=#{$2}"
        end
      end
    end
    flv_url
  end
  
  def youtube_url_to_mp4(url)
    url + "&fmt=18"
  end
  
end
