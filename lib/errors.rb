# this is a collection of errors
class HttpError < RuntimeError; end
class BadVideoError < RuntimeError; end
class HostNotFoundError < RuntimeError; end
class AccessDeniedError < RuntimeError; end
class DownloadTimeoutError < RuntimeError; end
