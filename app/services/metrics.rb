module Metrics
  class Tracker
    attr_reader :model, :key, :user

    def initialize(model, key, user)
      @model = model
      @key = key
      @user = user
    end

    def track(event)
      create(event: event)
    end

  private

    def create(changes)
      PublicActivity::Activity.create(trackable: model,
                                      key: key,
                                      owner: user,
                                      parameters: changes)
    end
  end

  class Data
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def for(key = nil, event = nil)
      activity_params = { owner: user }
      activity_params.merge!(key: key) if key.present?
      activity_params.merge!(parameters: { event: event }) if event.present?
      PublicActivity::Activity.where(activity_params)
    end
  end
end
