class CreateProviderAgreements < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_agreements do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :provider_user, null: false, foreign_key: true
      t.string :agreement_type
      t.datetime :accepted_at
      t.timestamps
    end
  end
end
