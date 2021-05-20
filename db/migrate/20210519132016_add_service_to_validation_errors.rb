class AddServiceToValidationErrors < ActiveRecord::Migration[6.1]
  def change
    add_column :validation_errors, :service, :string
  end
end
