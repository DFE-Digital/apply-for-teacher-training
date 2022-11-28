class TestSuiteTimeMachine
  def self.pretend_it_is(datetime)
    if @baseline_set
      raise TimeTravelError, 'TestSuiteTimeMachine.pretend_it_is cannot be called more than once per test run'
    end

    datetime = 'real_world' if datetime.blank?

    Timecop.baseline =  case datetime
                        when 'real_world'
                          Time.zone.now
                        when /\A(\d+).days.from_now\z/
                          ::Regexp.last_match(1).to_i.days.from_now
                        else
                          Time.zone.parse(datetime)
                        end

    @baseline_set = Timecop.baseline

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

  def self.advance_time_to(datetime, **kwargs)
    if datetime < Time.zone.now
      raise TimeTravelError, "TestSuiteTimeMachine.advance_time_to cannot be called with a date in the past (#{datetime})"
    end

    travel_permanently_to(datetime, **kwargs)
  end

  def self.advance_time_by(duration, **kwargs)
    advance_time_to(Time.zone.now + duration, **kwargs)
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
    unless @baseline_set
      raise TimeTravelError, "a baseline time must be set first (#{@baseline_set})"
    end

    Timecop.return_to_baseline
    Timecop.freeze(@baseline_set)

    if Time.zone.now.to_i != @baseline_set.to_i
      raise TimeTravelError, "Time leak! Expected '#{Time.zone.now}' to be at baseline '#{@baseline_set}' after a reset"
    end
  end

  def self.revert_to_real_world_time
    Timecop.return.tap do
      Timecop.safe_mode = true
      @baseline_set = false
    end
  end

  def self.unfreeze!
    Timecop.travel(Time.zone.now)
  end

  module RSpecHelpers
    def set_time(...)
      TestSuiteTimeMachine.travel_permanently_to(...)
    end

    def advance_time
      TestSuiteTimeMachine.advance
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
