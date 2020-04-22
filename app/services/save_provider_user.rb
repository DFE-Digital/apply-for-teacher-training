class SaveProviderUser
  def initialize(provider_user:, permissions: {})
    @provider_user = provider_user
    @permissions = sanitized_permissions(permissions)
  end

  def call!
    @provider_user.save!
    update_permissions!
    @provider_user.reload
  end

private

  def update_permissions!
    unselected_permissions = ProviderPermissions
      .where(provider_user: @provider_user)
      .where.not(provider_id: @permissions.values.flatten)

    ActiveRecord::Base.transaction do
      ProviderPermissionsOptions::VALID_PERMISSIONS.each do |permission_name|
        unselected_permissions.where(permission_name => true).each do |permission|
          permission.update!(permission_name => false)
        end
      end

      @permissions.each do |permission_name, provider_ids|
        ProviderPermissions
          .where(provider_user: @provider_user, provider_id: provider_ids, permission_name => false)
          .each { |permission| permission.update!(permission_name => true) }
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
