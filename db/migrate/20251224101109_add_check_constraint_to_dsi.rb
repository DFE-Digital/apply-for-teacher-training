class AddCheckConstraintToDsi < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      add_check_constraint(
        :dsi_sessions,
        "NOT (user_type = 'ProviderUser' AND impersonated_provider_user_id IS NOT NULL)",
        name: 'provider_not_impersonating_provider',
      )
    end
  end
end
