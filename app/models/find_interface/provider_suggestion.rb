class FindInterface::ProviderSuggestion < FindInterface::Base
  def self.suggest(query)
    requestor.__send__(
      :request, :get, "/api/v3/provider-suggestions?query=#{query}"
    )
  end
end
