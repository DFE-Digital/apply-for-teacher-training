class TimeLimitConfig
  DAYS_BEFORE_WE_ASK_FOR_A_NEW_REFEREE = 10

  Rule = Struct.new(:from_date, :to_date, :limit)

  RULES = {
    reject_by_default: [
      Rule.new(nil, nil, 40),
    ],
    decline_by_default: [
      Rule.new(nil, nil, 10),
    ],
    edit_by: [
      Rule.new(nil, nil, 5),
    ],
    chase_provider_before_rbd: [
      Rule.new(nil, nil, 20),
    ],
    chase_referee_by: [
      Rule.new(nil, nil, 5),
    ],
    replace_referee_by: [
      Rule.new(nil, nil, 10),
    ],
  }.freeze

  def self.limits_for(rule)
    RULES[rule.to_sym]
  end
end
