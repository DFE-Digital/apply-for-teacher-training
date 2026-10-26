class AddRoleEnumToSupportUsers < ActiveRecord::Migration[8.1]
  create_enum :support_user_roles, %w[user_support technical_management service_administration research_and_design]

  def change
    add_column :support_users, :role, :enum, enum_type: 'support_user_roles', null: true
  end
end
