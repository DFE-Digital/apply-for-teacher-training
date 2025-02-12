class CreatePoolInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :pool_invites do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :provider_users }
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
