class AddPhoneAndEmailToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :email_address, :string
    add_column :providers, :phone_number, :string
  end
end
