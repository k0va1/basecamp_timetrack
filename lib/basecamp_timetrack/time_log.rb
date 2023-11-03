class TimeLog
  LOG_REGEX = %r{((?<h>\d+(\.\d+)?)h)?((?<m>\d+)m?)?}

  attr_reader :seconds

  def initialize(input)
    @seconds = parse(input)
  end

  def +(other)
    TimeLog.new(seconds + other.seconds)
  end

  def ==(other)
    seconds == other.seconds
  end

  def to_i
    seconds
  end

  def hours
    "#{(seconds / 3600.0).ceil(3)}h"
  end

  def hours_in_float
    (seconds / 3600.0).ceil(3)
  end

  private

  def parse(input)
    return input if input.is_a?(Integer)
    return 0 if input.nil? || input == ""

    h, m = input.match(LOG_REGEX).captures
    (h.to_f * 3600 + m.to_f * 60).to_i
  end
end
