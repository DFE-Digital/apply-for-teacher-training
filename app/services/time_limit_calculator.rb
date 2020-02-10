class TimeLimitCalculator
  attr_accessor :rule, :effective_date

  def initialize(rule:, effective_date:)
    self.rule = rule
    self.effective_date = effective_date
  end

  def call
    days = calculate_days
    [days, calculate_time_in_future(days), calculate_time_in_past(days)]
  end

private

  def calculate_time_in_future(days)
    return nil unless days

    days.business_days.after(effective_date).end_of_day
  end

  def calculate_time_in_past(days)
    return nil unless days

    days.business_days.before(effective_date).end_of_day
  end

  def calculate_days
    to_and_from_time_limits.each do |time_limit|
      return time_limit.limit if effective_date <= time_limit.to_date && effective_date >= time_limit.from_date
    end
    from_time_limits.each do |time_limit|
      return time_limit.limit if effective_date >= time_limit.from_date
    end
    to_time_limits.each do |time_limit|
      return time_limit.limit if effective_date <= time_limit.to_date
    end
    default_time_limit&.limit
  end

  def time_limits_for_rule
    @time_limits_for_rule ||= TimeLimitConfig.limits_for(rule)
  end

  def to_and_from_time_limits
    time_limits_for_rule.select { |time_limit| time_limit.to_date && time_limit.from_date }
  end

  def from_time_limits
    time_limits_for_rule.select { |time_limit| time_limit.to_date.nil? && time_limit.from_date }
  end

  def to_time_limits
    time_limits_for_rule.select { |time_limit| time_limit.to_date && time_limit.from_date.nil? }
  end

  def default_time_limit
    time_limits_for_rule.find { |time_limit| time_limit.to_date.nil? && time_limit.from_date.nil? }
  end
end
