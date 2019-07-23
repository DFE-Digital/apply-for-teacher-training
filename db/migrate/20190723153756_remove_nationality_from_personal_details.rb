class RemoveNationalityFromPersonalDetails < ActiveRecord::Migration[5.2]
  def change
    remove_column :personal_details, :nationality, :string
  end
end
