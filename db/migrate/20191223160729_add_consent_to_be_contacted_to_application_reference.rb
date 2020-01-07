class AddConsentToBeContactedToApplicationReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :consent_to_be_contacted, :boolean
  end
end
