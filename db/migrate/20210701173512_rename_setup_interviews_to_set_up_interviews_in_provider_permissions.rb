class RenameSetupInterviewsToSetUpInterviewsInProviderPermissions < ActiveRecord::Migration[6.1]
  def change
    safety_assured {
      change_table :provider_users_providers do |t|
        t.rename :setup_interviews, :set_up_interviews
      end
    }
  end
end
