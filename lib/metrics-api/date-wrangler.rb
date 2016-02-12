#start_date = DateTime.parse(params[:from]) rescue nil
#end_date = DateTime.parse(params[:to]) rescue nil
#
#if params[:from].is_duration?
#  start_date = get_start_date params rescue
#    error_400("'#{params[:from]}' is not a valid ISO8601 duration.")
#end
#
#if params[:to].is_duration?
#  end_date = get_end_date params rescue
#    error_400("'#{params[:to]}' is not a valid ISO8601 duration.")
#end
#
#invalid = []
#
#invalid << "'#{params[:from]}' is not a valid ISO8601 date/time." if start_date.nil? && params[:from] != "*"
#invalid << "'#{params[:to]}' is not a valid ISO8601 date/time." if end_date.nil? && params[:to] != "*"
#
#error_400(invalid.join(" ")) unless invalid.blank?
#
#if start_date != nil && end_date != nil
#  error_400("'from' date must be before 'to' date.") if start_date > end_date
#end

class DateWrangler
  attr_reader :from, :to

  def initialize left, right
    @left = left
    @right = right
  end

  def finish
    @finish ||= ISO8601::Duration.new(@right).to_seconds.seconds
  end

  def start
    @start ||= ISO8601::Duration.new(@left).to_seconds.seconds
  end

  def to
    if DateWrangler.is_duration? @right
      @to = from + finish
    else
      @to = DateTime.parse @right
    end

    @to
  end

  def from
    if DateWrangler.is_duration? @left
      @from = DateTime.parse(@right) - start
    else
      @from = DateTime.parse @left
    end

    @from
  end

  def self.is_duration? thing
    return true if thing =~ /^P/
    false
  end
end
