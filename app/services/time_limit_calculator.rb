class TimeLimitCalculator
  attr_accessor :rule, :effective_date

  def initialize(rule:, effective_date:)
    self.rule = rule
    self.effective_date = effective_date
  end

  def call
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

private

  def time_limits_for_rule
    @time_limits_for_rule ||= TimeLimit.where(rule: rule)
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
