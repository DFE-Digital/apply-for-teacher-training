class LocationSuggestions
  attr_reader :query, :cache_expiration

  def initialize(query, cache_expiration: 7.days)
    @query = query
    @cache_expiration = cache_expiration
  end

  def call
    return [] if query.blank?

    Rails.cache.fetch(cache_key, expires_in: cache_expiration) do
      fetch_suggestions
    end
  end

  def cache_key
    "location:suggestions:#{query.parameterize}"
  end

  def fetch_suggestions_and_cache
    suggestions = fetch_suggestions
    return [] if suggestions.blank?

    suggestions
  end

  def fetch_suggestions
    GoogleMapsAPI::Client.new.autocomplete(query)
  rescue StandardError => e
    capture_error(e)
    []
  end

  def capture_error(error)
    message = "Location suggestion failed for #{self.class} - #{query}, suggestions ignored (user experience unaffected)"

    Sentry.capture_exception(error, message:)
  end
end
