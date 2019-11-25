class AddDeclineByDefaultToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :decline_by_default_at, :datetime
    add_column :application_choices, :decline_by_default_days, :integer
  end
end
