class TimeLimitConfig
  def self.limits_for(rule)
    rules[rule.to_sym]
  end

  def self.minimum_hours_between_chaser_emails
    48
  end

  def self.chase_referee_by
    7
  end

  def self.replace_referee_by
    14
  end

  def self.second_chase_referee_by
    21
  end

  def self.additional_reference_chase_calendar_days
    28
  end

  Rule = Struct.new(:from_date, :to_date, :limit)

  def self.new_rule(...)
    Rule.new(...)
  end

  def self.stale_application_rules
    working_days = 30

    [
      Rule.new(nil, nil, working_days),
      Rule.new(Time.zone.local(RecruitmentCycleTimetable.current_year, 6, 30, 23, 59, 59), nil, 20),
    ]
  end

  def self.rules
    { reject_by_default: stale_application_rules }
  end

  private_constant 'Rule'
  private_class_method :rules, :stale_application_rules
end
