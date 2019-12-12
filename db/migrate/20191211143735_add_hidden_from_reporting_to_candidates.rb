class AddHiddenFromReportingToCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :hide_in_reporting, :boolean, default: false, null: false
  end
end
