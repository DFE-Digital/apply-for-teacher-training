class MigrateFeatureFlagsFromRedisToPg < ActiveRecord::Migration[6.0]
  def up
    FeatureFlagMigrator.new.call
  end

  def down; end
end
