class LocationSuggestions
  attr_reader :query, :cache, :cache_expiration

  def initialize(query, cache: Rails.cache, cache_expiration: 7.days)
    @query = query
    @cache = cache
    @cache_expiration = cache_expiration
  end

  def call
    return [] if query.blank?

    cached_suggestions || fetch_suggestions_and_cache
  end

  def cached_suggestions
    cache.read(cache_key)
  end

  def cache_key
    "location:suggestions:#{query.parameterize}"
  end

  def fetch_suggestions_and_cache
    suggestions = fetch_suggestions
    return [] if suggestions.blank?

    cache_suggestions(suggestions)

    suggestions
  end

  def cache_suggestions(response)
    cache.write(cache_key, response, expires_in: cache_expiration)
  end

  def fetch_suggestions
    GoogleMapsAPI::Client.new.autocomplete(query)
  rescue StandardError => e
    capture_error(e)
    nil
  end

  def capture_error(error)
    message = "Location suggestion failed for #{self.class} - #{query}, suggestions ignored (user experience unaffected)"

    Sentry.capture_exception(error, message:)
  end
end
