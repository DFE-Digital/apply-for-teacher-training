class AddApplicationChoicesRejectedByDefault < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :rejected_by_default, :boolean, null: false, default: false
  end
end
