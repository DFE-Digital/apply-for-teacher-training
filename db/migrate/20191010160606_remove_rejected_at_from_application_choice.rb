class RemoveRejectedAtFromApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :rejected_at, :datetime
  end
end
