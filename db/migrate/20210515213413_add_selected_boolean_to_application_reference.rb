class AddSelectedBooleanToApplicationReference < ActiveRecord::Migration[6.1]
  def up
    add_column :references, :selected, :boolean
    change_column_default :references, :selected, false
  end

  def down
    remove_column :references, :selected, :boolean
  end
end
