class DropApplicationChoicesEnrolledAt < ActiveRecord::Migration[6.0]
  def up
    remove_column :application_choices, :enrolled_at
  end

  def down
    add_column :application_choices, :enrolled_at, :datetime
  end
end
