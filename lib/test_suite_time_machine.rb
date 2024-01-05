class TestSuiteTimeMachine
  def self.pretend_it_is(datetime)
    if baseline
      raise TimeTravelError, "TestSuiteTimeMachine.pretend_it_is cannot be called more than once per test run (currently set to `#{baseline}`, use `travel_temporarily_to` instead)."
    end

    datetime = 'real_world' if datetime.blank?

    self.baseline = Timecop.baseline = case datetime
                                       when 'real_world'
                                         Time.zone.now
                                       when /\A(\d+).days.from_now\z/
                                         ::Regexp.last_match(1).to_i.days.from_now
                                       else
                                         Time.zone.parse(datetime)
                                       end

    Timecop.safe_mode = false
    Timecop.freeze
  end

  def self.travel_temporarily_to(*datetime, freeze: true, &block)
    raise TimeTravelError, 'TestSuiteTimeMachine.travel_temporarily_to requires a block' unless block_given?

    if freeze
      Timecop.freeze(*datetime, &block)
    else
      Timecop.travel(*datetime, &block)
    end
  end

  def self.advance_time_to(datetime, **)
    if datetime < Time.zone.now
      raise TimeTravelError, "TestSuiteTimeMachine.advance_time_to cannot be called with a date in the past (#{datetime})"
    end

    travel_permanently_to(datetime, **)
  end

  def self.advance_time_by(duration, **)
    advance_time_to(Time.zone.now + duration, **)
  end

  def self.advance
    advance_time_by(1.second)
  end

  def self.travel_permanently_to(*datetime, freeze: true)
    if freeze
      Timecop.freeze(*datetime)
    else
      Timecop.travel(*datetime)
    end
  end

  def self.reset
    unless baseline
      raise TimeTravelError, "a baseline time must be set first (#{baseline})"
    end

    Timecop.return_to_baseline
    Timecop.freeze(baseline)

    if Time.zone.now.to_i != baseline.to_i
      raise TimeTravelError, "Time leak! Expected '#{Time.zone.now}' to be at baseline '#{baseline}' after a reset"
    end
  end

  def self.revert_to_real_world_time
    Timecop.return.tap do
      Timecop.safe_mode = true
      self.baseline = nil
    end
  end

  def self.unfreeze!
    Timecop.travel(Time.zone.now)
  end

  def self.baseline
    Thread.current[:tstm_baseline_set]
  end

  def self.baseline=(datetime)
    Thread.current[:tstm_baseline_set] = datetime
  end

  module RSpecHelpers
    def set_time(...)
      TestSuiteTimeMachine.travel_permanently_to(...)
    end

    def advance_time
      TestSuiteTimeMachine.advance
    end

    def advance_time_by(...)
      TestSuiteTimeMachine.advance_time_by(...)
    end

    def advance_time_to(...)
      TestSuiteTimeMachine.advance_time_to(...)
    end

    def travel_temporarily_to(...)
      TestSuiteTimeMachine.travel_temporarily_to(...)
    end
  end

  class TimeTravelError < StandardError; end
end
