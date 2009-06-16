class ErrorDetector

  @app
  @protocol
  @local_file_path

  def initialize app, protocol, local_file_path=nil
    @app = app
    @protocol = protocol
    @xml_received = false
    @local_file_path = local_file_path
  end

  def check_for_error line

    case @app
    when 'curl'
      case line
      when /curl: \(6\) Couldn't resolve host/
        raise HostNotFoundError.new
      when /curl: \(67\) Access denied: 530/
        raise AccessDeniedError.new
      end
    when 'axel'
      case line
      when /Unable to connect to server/
        raise HostNotFoundError.new
      when /^530/
        raise AccessDeniedError.new
      end
    when 'scp'
      case line
      when /ssh: Could not resolve hostname/
        raise HostNotFoundError.new
      when /Permission denied/
        raise AccessDeniedError.new
      end
    end

    case @protocol
    when 'http', 's3'
      if line =~ %r[HTTP/\d\.\d\s+(\d+)]
        raise HttpError.new($1) unless $1[0] == '3'[0] || $1[0] == '2'[0]
      end
    end

  end

end
