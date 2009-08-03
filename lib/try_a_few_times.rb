class TryAFewTimes
  def self.do(how_many)
    how_many.times do |i|
      begin
        yield(i)
        break
      rescue
        raise $! if i+1 >= how_many
      end
    end
  end
end
