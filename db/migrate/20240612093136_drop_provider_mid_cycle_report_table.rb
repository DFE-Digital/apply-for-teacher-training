class DropProviderMidCycleReportTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :provider_mid_cycle_reports
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
