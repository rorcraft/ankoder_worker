class ErrorDetector

  HOST_NOT_FOUND = 'host not found'
  ACCESS_DENIED = 'access denied'

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
        raise HOST_NOT_FOUND
      when /curl: \(67\) Access denied: 530/
        raise ACCESS_DENIED
      end
    when 'axel'
      case line
      when /Unable to connect to server/
        raise HOST_NOT_FOUND
      when /^530/
        raise ACCESS_DENIED
      end
    when 'scp'
      case line
      when /ssh: Could not resolve hostname/
        raise HOST_NOT_FOUND
      when /Permission denied/
        raise ACCESS_DENIED
      end
    end

    case @protocol
    when 'http', 's3'
      if line =~ %r[HTTP/\d\.\d\s+(\d+)]
        raise $1
      end
    end

  end

end
