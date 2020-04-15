class SaveProviderUser
  def initialize(provider_user:, permissions: {})
    @provider_user = provider_user
    @permissions = sanitized_permissions(permissions)
  end

  def call!
    @provider_user.save!
    update_permissions
    @provider_user.reload
  end

private

  def update_permissions
    ActiveRecord::Base.transaction do
      ProviderPermissions
        .where(provider_user: @provider_user)
        .update_all(ProviderPermissionsOptions.reset_attributes)

      @permissions.each do |permission, provider_ids|
        ProviderPermissions
          .where(provider_user: @provider_user, provider_id: provider_ids)
          .update_all(permission => true)
      end
    end
  end

  def sanitized_permissions(permissions)
    result = {}
    return result unless @provider_user

    permissions.each do |permission_name, provider_ids|
      if ProviderPermissionsOptions.valid?(permission_name)
        result[permission_name] = provider_ids.map(&:to_i) & @provider_user.provider_ids
      end
    end

    result
  end
end
