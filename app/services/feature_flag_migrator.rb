class FeatureFlagMigrator
  def call
    FeatureFlag::FEATURES.each_key do |feature_name|
      set_in_postgres(feature_name, active_in_redis?(feature_name))
    end
  end

private

  def set_in_postgres(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end

  def active_in_redis?(feature_name)
    rollout.active?(feature_name)
  end

  def rollout
    @rollout ||= Rollout.new(Redis.current)
  end
end
