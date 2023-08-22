class AddInactiveAtToApplicationChoices < ActiveRecord::Migration[7.0]
  def change
    add_column :application_choices, :inactive_at, :datetime
  end
end
