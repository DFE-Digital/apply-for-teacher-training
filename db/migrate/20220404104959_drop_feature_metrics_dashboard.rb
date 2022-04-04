class DropFeatureMetricsDashboard < ActiveRecord::Migration[7.0]
  def up
    drop_table :feature_metrics_dashboards
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
