class RemovePublicUpdateColumnFromApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :last_public_update_at, :datetime
  end
end
