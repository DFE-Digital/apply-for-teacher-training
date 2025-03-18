class CreateWithdrawalRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :withdrawal_requests do |t|
      t.string :reason, null: false
      t.text :comment
      t.references :application_choice, null: false, foreign_key: { on_delete: :cascade }
      t.references :provider_user, null: false, foreign_key: true
      t.string :status, default: 'draft'

      t.timestamps
    end
  end
end
