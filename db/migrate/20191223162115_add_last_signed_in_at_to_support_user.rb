class AddLastSignedInAtToSupportUser < ActiveRecord::Migration[6.0]
  def change
    add_column :support_users, :last_signed_in_at, :datetime
  end
end
