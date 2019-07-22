class AddPhoneNumberToPersonalDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :personal_details, :phone_number, :string
  end
end
