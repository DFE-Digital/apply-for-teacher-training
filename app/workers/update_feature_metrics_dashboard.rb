class UpdateFeatureMetricsDashboard
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    dashboard = FeatureMetricsDashboard.new
    dashboard.load_updated_metrics
    dashboard.save!
  end
end
