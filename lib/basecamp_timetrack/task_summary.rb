require_relative "time_log"

class TaskSummary
  attr_reader :title, :time_logs

  def initialize(title:, time_logs:)
    @title = title
    @time_logs = time_logs
  end

  def total_hours
    total_time_logs.hours
  end

  def hours_in_float
    total_time_logs.hours_in_float
  end

  def +(other)
    (total_time_logs + other.total_time_logs).hours
  end

  def to_s
    "#{title}: #{total_hours}"
  end

  def total_time_logs
    time_logs.sum(TimeLog.new(0))
  end
end
