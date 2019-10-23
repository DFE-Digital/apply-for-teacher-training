class AddSubmittedAtToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :submitted_at, :datetime
  end
end
