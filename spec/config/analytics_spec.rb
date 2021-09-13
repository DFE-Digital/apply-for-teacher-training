require 'rails_helper'

RSpec.describe 'analytics.yml and analytics_pii.yml' do
  it 'are valid' do
    # When model has a plural name or a custom table name,
    # we can't map from symbol to class, though it works in the other direction
    # (which is how the production code uses it).
    #
    # e.g.
    #
    # ProviderRelationshipPermissions.first.class.table_name.to_sym
    # => :provider_relationship_permissions
    #
    # :provider_relationship_permissions.to_s_classify.constantize
    # => unitialized constant ProviderRelationshipPermission
    irregular_table_names = {
      provider_relationship_permissions: ProviderRelationshipPermissions,
      provider_user_notifications: ProviderUserNotificationPreferences,
      provider_users_providers: ProviderPermissions,
      references: ApplicationReference,
    }

    Rails.configuration.analytics.deep_merge(Rails.configuration.analytics_pii).each do |table_name, fields|
      model = irregular_table_names[table_name.to_sym] || table_name.to_s.classify.constantize
      expect(fields & model.column_names).to match_array(fields)
    end
  end
end
