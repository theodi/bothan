class DateWrangler
  def initialize left, right
    @left = left
    @right = right
  end

  def finish
    @finish ||= @right.to_seconds
  end

  def start
    @start ||= @left.to_seconds
  end

  def to
    @to ||= if @right.is_duration?
      from + finish
    else
      @right.to_datetime
    end
  end

  def from
    @from ||= if @left.is_duration?
      to - start
    else
      @left.to_datetime
    end
  end

  def errors
    {
      from: @left,
      to: @right
    }.each_pair do |method, attribute|
      begin
        self.send(method)
      rescue ArgumentError => ae
        accrue_failures "'#{attribute}' is not a valid ISO8601 date/time." if ae.message == 'invalid date'
      rescue ISO8601::Errors::UnknownPattern
        accrue_failures "'#{attribute}' is not a valid ISO8601 duration."
      end
    end

    unless @failures
      unless[from, to].include? nil
        unless from < to
          accrue_failures "'from' date must be before 'to' date."
        end
      end
    end

    @failures.uniq if @failures
  end

  def accrue_failures failure
    begin
      @failures.push failure
    rescue NameError
      @failures = [failure]
    end
  end
end

class String
  def is_duration?
    !self.match(/^P/).nil?
  end

  def to_seconds
    ISO8601::Duration.new(self).to_seconds.seconds
  end

  def to_datetime
    return nil if self == '*'
    DateTime.parse self
  end
end
