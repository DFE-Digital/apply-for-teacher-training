class InitialiseApplicationResponseCacheAndLastPublicUpdateAt
  def self.call
    ApplicationChoice.where(last_public_update_at: nil)
      .update_all('last_public_update_at = updated_at')

    ApplicationChoice.all.each do |ac|
      cache = ac.application_response_cache.presence || ac.build_application_response_cache
      cache.refresh!
    end
  end
end
