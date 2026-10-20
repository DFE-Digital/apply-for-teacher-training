class AddRoleEnumToSupportUsers < ActiveRecord::Migration[8.1]
  create_enum :support_user_roles, %w[support technical business researcher]

  def change
    add_column :support_users, :role, :enum, enum_type: 'support_user_roles', null: false, default: 'support'
  end
end
