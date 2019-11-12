class AddApplicationChoicesEditBy < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :edit_by, :datetime
  end
end
