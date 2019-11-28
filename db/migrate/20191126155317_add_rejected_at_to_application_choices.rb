class AddRejectedAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :rejected_at, :datetime
  end
end
