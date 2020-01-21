class AddSignUpEmailBouncedToCandidate < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :sign_up_email_bounced, :boolean, default: false, null: false
  end
end
