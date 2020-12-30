module Metrics
  class Tracker
    attr_reader :model, :key, :user

    def initialize(model, key, user)
      @model = model
      @key = key
      @user = user
    end

    def track(event, completion_time = nil)
      completion_time = formatted_interval(completion_time) if completion_time
      create(changes: { event: event }, completion_time: completion_time)
    end

  private

    def create(changes: {}, completion_time: nil)
      PublicActivity::Activity.create(trackable: model,
                                      key: key,
                                      owner: user,
                                      parameters: changes,
                                      completion_time: completion_time)
    end

    def formatted_interval(seconds)
      total_seconds = seconds.round
      hours = total_seconds / (60 * 60)
      minutes = (total_seconds / 60) % 60
      seconds = total_seconds % 60
      [hours, minutes, seconds].map { |t| t.round.to_s.rjust(2, '0') }.join(':')
    end
  end

  class Data
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def for(key = nil, event = nil, trackable: nil)
      activity_params = { owner: user, trackable: trackable, key: key }.delete_if { |_, v| v.nil? }
      activity_params.merge!(parameters: { event: event }) if event.present?
      PublicActivity::Activity.where(activity_params)
    end
  end

  class IntervalToSeconds
    attr_reader :interval

    def initialize(interval)
      @interval = interval
    end

    def call
      interval.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }
    end
  end
end
