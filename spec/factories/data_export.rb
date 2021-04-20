FactoryBot.define do
  factory :data_export do
    name { 'Active provider user permissions' }
    export_type { :active_provider_user_permissions }
  end
end
