class AddOneLoginUidToCandidates < ActiveRecord::Migration[7.1]
  def change
    add_column :candidates, :one_login_uid, :string
  end
end
