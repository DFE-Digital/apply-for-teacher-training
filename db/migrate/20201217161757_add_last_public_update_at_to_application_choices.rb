class AddLastPublicUpdateAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :last_public_update_at, :datetime
  end
end
