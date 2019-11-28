class TimeLimitConfig
  Rule = Struct.new(:from_date, :to_date, :limit)

  RULES = {
    reject_by_default: [
      Rule.new(nil, nil, 40),
    ],
    decline_by_default: [
      Rule.new(nil, nil, 10),
    ],
  }.freeze

  def self.limits_for(rule)
    RULES[rule.to_sym]
  end
end
