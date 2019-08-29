class AddMagicLinkTokenToCandidate < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :magic_link_token, :string, unique: true
    add_column :candidates, :magic_link_token_sent_at, :datetime

    add_index :candidates, :magic_link_token, unique: true
  end
end
