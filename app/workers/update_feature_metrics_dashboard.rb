class UpdateFeatureMetricsDashboard
  include Sidekiq::Worker
  include SafePerformAsync

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    dashboard = FeatureMetricsDashboard.new
    dashboard.load_updated_metrics
    dashboard.save!
  end
end
