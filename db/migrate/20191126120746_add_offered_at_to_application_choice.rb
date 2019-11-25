class AddOfferedAtToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :offered_at, :datetime
  end
end
