class CacheKey
  def self.generate(identifier)
    sha = CODE_REVISION_FOR_CACHE
    feature_flags_last_changed = Digest::SHA1.hexdigest(Feature.maximum(:updated_at).to_s).slice(0, 7)

    "#{identifier}-#{sha}-#{feature_flags_last_changed}"
  end
end
