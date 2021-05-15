class AddSelectedBooleanToApplicationReference < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :selected, :boolean, default: false
  end
end
