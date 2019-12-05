class AddWithdrawnAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :withdrawn_at, :datetime
  end
end
