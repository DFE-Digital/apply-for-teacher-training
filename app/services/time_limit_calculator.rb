class TimeLimitCalculator
  attr_accessor :rule, :effective_date

  def initialize(rule:, effective_date:)
    self.rule = rule
    self.effective_date = effective_date
  end

  def call
    time_limits_for_rule = TimeLimit.where(rule: rule)
    time_limits_for_rule.each do |time_limit|
      if time_limit.from_date &&
          time_limit.to_date &&
          effective_date <= time_limit.to_date &&
          effective_date >= time_limit.from_date
        return time_limit.limit
      end
    end
    time_limits_for_rule.each do |time_limit|
      if time_limit.from_date &&
          effective_date >= time_limit.from_date
        return time_limit.limit
      end
    end
    time_limits_for_rule.each do |time_limit|
      if time_limit.to_date &&
          effective_date <= time_limit.to_date
        return time_limit.limit
      end
    end
    time_limits_for_rule.find { |time_limit| time_limit.from_date.nil? && time_limit.to_date.nil? }&.limit
  end
end
