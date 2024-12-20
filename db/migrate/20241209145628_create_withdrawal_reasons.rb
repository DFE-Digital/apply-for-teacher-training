class CreateWithdrawalReasons < ActiveRecord::Migration[8.0]
  def change
    create_table :withdrawal_reasons do |t|
      t.string :reason, index: true
      t.text :comment
      t.string :status, default: 'draft'
      t.references :application_choice, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
