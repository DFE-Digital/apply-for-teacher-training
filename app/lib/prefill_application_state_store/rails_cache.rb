module PrefillApplicationStateStore
  class RailsCache
    def initialize(current_candidate_id)
      @current_candidate_id = current_candidate_id
    end

    def write(data)
      Rails.cache.write(key, data, expires_in: 5.minutes.to_i)
    end

    def read
      Rails.cache.read(key)
    end

    def clear
      Rails.cache.clear(key)
    end

  private

    def key
      "prefill_application_#{@current_candidate_id}"
    end
  end
end
