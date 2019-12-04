class AddApplicationChoicesDeclinedByDefault < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :declined_at, :datetime
    add_column :application_choices, :declined_by_default, :boolean, null: false, default: false
  end
end
