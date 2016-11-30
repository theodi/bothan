$:.unshift File.dirname(__FILE__)
require 'date_wrangler'

class String
  def titleise
    self.split(' ').map { |w| "#{w[0].upcase}#{w[1..-1]}" }.join ' '
  end

  def to_seconds
    ISO8601::Duration.new(self).to_seconds.seconds
  end

  def to_datetime
    return nil if self == '*'
    DateTime.parse self
  end

  def is_duration?
    !self.match(/^P/).nil?
  end

end
