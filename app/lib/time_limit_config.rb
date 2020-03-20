class TimeLimitConfig
  Rule = Struct.new(:from_date, :to_date, :limit, :use_business_days)

  RULES = {
    reject_by_default: [
      Rule.new(nil, nil, 40, true),
    ],
    decline_by_default: [
      Rule.new(nil, nil, 10, true),
    ],
    edit_by: [
      Rule.new(nil, nil, 7, false),
    ],
    chase_provider_before_rbd: [
      Rule.new(nil, nil, 20, true),
    ],
    chase_referee_by: [
      Rule.new(nil, nil, 5, true),
    ],
    replace_referee_by: [
      Rule.new(nil, nil, 10, true),
    ],
    chase_candidate_before_dbd: [
      Rule.new(nil, nil, 5, true),
    ],
  }.freeze

  def self.limits_for(rule)
    RULES[rule.to_sym]
  end
end
