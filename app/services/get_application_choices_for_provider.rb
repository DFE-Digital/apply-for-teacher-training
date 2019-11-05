class GetApplicationChoicesForProvider
  def self.call(provider:)
    ApplicationChoice
    .for_provider(provider.code)
    .visible_to_provider
  end
end
