revision = ENV.fetch('SHA') do
  if HostingEnvironment.production?
    raise 'Missing SHA environment value in production containing current git revision, required to support Rails caching'
  else
    Rails.logger.info('Falling back to app startup timestamp for cache keys in lieu of git revision')
    Digest::SHA1.hexdigest(Time.zone.now.to_s)
  end
end

CODE_REVISION_FOR_CACHE = revision.slice(0, 7).freeze
