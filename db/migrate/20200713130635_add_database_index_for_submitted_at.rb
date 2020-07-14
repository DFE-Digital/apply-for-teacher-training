class AddDatabaseIndexForSubmittedAt < ActiveRecord::Migration[6.0]
  def change
    add_index :application_forms, :submitted_at
  end
end
