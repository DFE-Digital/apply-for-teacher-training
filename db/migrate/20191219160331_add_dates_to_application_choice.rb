class AddDatesToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    change_table :application_choices, bulk: true do |t|
      t.datetime :recruited_at
      t.datetime :conditions_not_met_at
      t.datetime :enrolled_at
    end
  end
end
