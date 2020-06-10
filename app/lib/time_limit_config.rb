class TimeLimitConfig
  class Days
    attr_reader :count, :type

    def initialize(count:, type:)
      raise ArgumentError, 'Argument is not an integer' unless count.is_a?(Integer)
      raise ArgumentError, 'Argument is not :calendar or :working' unless (type == :calendar) || (type == :working)

      @count = count
      @type = type
    end

    def to_days
      type == :calendar ? count.days : count.business_days
    end

    def to_s
      "#{@count} #{@type} #{'day'.pluralize(@count)}"
    end
  end

  Rule = Struct.new(:from_date, :to_date, :limit)

  def self.edit_by
    Days.new(count: 5, type: :working)
  end

  def self.chase_referee_by
    7
  end

  def self.replace_referee_by
    14
  end

  def self.additional_reference_chase_calendar_days
    28
  end

  RULES = {
    reject_by_default: [
      Rule.new(nil, nil, 40),
      Rule.new(Time.zone.local(2020, 6, 9), nil, 20),
    ],
    decline_by_default: [
      Rule.new(nil, nil, 10),
    ],
    chase_provider_before_rbd: [
      Rule.new(nil, nil, 20),
      Rule.new(Time.zone.local(2020, 6, 9), nil, 10),
    ],
    chase_candidate_before_dbd: [
      Rule.new(nil, nil, 5),
    ],
  }.freeze

  def self.limits_for(rule)
    RULES[rule.to_sym]
  end
end
