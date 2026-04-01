class AddVisaExpiryToApplicationForm < ActiveRecord::Migration[8.0]
  def change
    add_column :application_forms, :visa_expired_at, :datetime
  end
end
