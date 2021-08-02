class BackfillAuthenticationTokens < ActiveRecord::Migration[6.0]
  def up
    Candidate.where.not(magic_link_token: nil).find_each do |candidate|
      candidate.authentication_tokens.create!(
        hashed_token: candidate.magic_link_token,
        created_at: candidate.magic_link_token_sent_at,
      )
    end
  end

  def down; end
end
