require 'bothan/extensions/string'

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

  # TODO - to and from handling the * or nil fields for a default view

  def to
    @to ||= if @right.is_duration?
      from + finish
    else
      @right.to_datetime || DateTime.now
    end
  end

  def from
    @from ||= if @left.is_duration?
      if to.nil?
        DateTime.now - start
      else
        to - start
      end
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

    check_ordering

    @failures.uniq if @failures
  end

  def check_ordering
    unless @failures
      unless[from, to].include? nil
        unless from < to
          accrue_failures "'from' date must be before 'to' date."
        end
      end
    end
  end

  def accrue_failures failure
    begin
      @failures.push failure
    rescue NameError
      @failures = [failure]
    end
  end
end
