class CreateContactDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_details do |t|
      t.string :phone_number
      t.string :email_address
      t.string :address

      t.timestamps
    end

    remove_column :personal_details, :phone_number, :string
    remove_column :personal_details, :email_address, :string
    remove_column :personal_details, :address, :string
  end
end
