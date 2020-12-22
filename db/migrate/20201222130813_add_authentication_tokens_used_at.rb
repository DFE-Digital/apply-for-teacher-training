class AddAuthenticationTokensUsedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :authentication_tokens, :used_at, :datetime
  end
end
