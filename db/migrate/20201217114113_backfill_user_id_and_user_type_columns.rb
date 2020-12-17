class BackfillUserIdAndUserTypeColumns < ActiveRecord::Migration[6.0]
  def change
    AuthenticationToken.all.each do |token|
      token.update!(
        user_id: token.authenticable_id,
        uder_type: token.authenticable_type,
      )
    end
  end
end
