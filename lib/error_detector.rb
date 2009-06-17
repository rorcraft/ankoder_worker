class ErrorDetector

  SAFE_HTTP_CODES = %w[
    100 101 102 200 201 202 203 204 205 206
    207 226 300 301 302 303 304 305 306 307
  ]

  @app
  @protocol

  def initialize app, protocol
    @app = app
    @protocol = protocol
    @xml_received = false
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
      when /Permission denied/, /Host key verification failed/
        raise AccessDeniedError.new
      end
    end

    case @protocol
    when 'http', 's3'
      if line =~ %r[HTTP/\d\.\d\s+(\d+)]
        raise HttpError.new($1) unless SAFE_HTTP_CODES.include? $1
      end
    end

  end

end
