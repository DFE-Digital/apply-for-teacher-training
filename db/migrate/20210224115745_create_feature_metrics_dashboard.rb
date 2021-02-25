class CreateFeatureMetricsDashboard < ActiveRecord::Migration[6.0]
  def change
    create_table :feature_metrics_dashboards do |t|
      t.timestamps
      t.jsonb :metrics
    end
  end
end
