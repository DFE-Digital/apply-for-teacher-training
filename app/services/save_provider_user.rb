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
    unselected_permissions = ProviderPermissions
      .where(provider_user: @provider_user)
      .where.not(provider_id: @permissions.values.flatten)

    ActiveRecord::Base.transaction do
      ProviderPermissionsOptions::VALID_PERMISSIONS.each do |permission|
        unselected_permissions.where(permission => true).each { |perm| perm.update(permission => false) }
      end

      @permissions.each do |permission, provider_ids|
        provider_ids.each do |provider_id|
          ProviderPermissions
            .where(provider_user: @provider_user, provider_id: provider_id, permission => false)
            .update(permission => true)
        end
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
