class AddAcceptedAtToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :accepted_at, :datetime
  end
end
