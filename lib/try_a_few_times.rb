class TryAFewTimes
  def self.do(how_many)
    success = false
    how_many.times do |i|
      begin
        yield(i)
        success = true
        break
      rescue
      end
    end
    raise $! unless success
  end
end
