class CreateInviteDeclineReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :invite_decline_reasons do |t|
      t.string :reason
      t.text :comment
      t.string :status, default: 'draft'
      t.references :invite, null: false, foreign_key: { to_table: :pool_invites }

      t.timestamps
    end

    add_index :invite_decline_reasons, :reason, name: 'index_decline_reasons_on_reason'
  end
end
