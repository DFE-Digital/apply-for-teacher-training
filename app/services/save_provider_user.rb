class SaveProviderUser
  VALID_PERMISSIONS = %i[manage_users].freeze

  def initialize(provider_user:, permissions: {})
    @provider_user = provider_user
    @permissions = sanitized_permissions(permissions)
  end

  def call!
    @provider_user.save!
    update_permissions
    @provider_user.reload
  end

  def update_permissions
    ActiveRecord::Base.transaction do
      ProviderPermissions
        .where(provider_user: @provider_user)
        .update_all(reset_permissions_attrs)

      @permissions.each do |permission, provider_ids|
        ProviderPermissions
          .where(provider_user: @provider_user, provider_id: provider_ids)
          .update_all(permission => true)
      end
    end
  end

  def sanitized_permissions(permissions)
    return {} unless @provider_user

    permissions.select do |permission_name, provider_ids|
      provider_ids.map!(&:to_i)
      VALID_PERMISSIONS.include?(permission_name.to_sym) &&
        (provider_ids & @provider_user.provider_ids) == provider_ids
    end
  end

  def reset_permissions_attrs
    {}.tap do |hash|
      VALID_PERMISSIONS.each { |p| hash[p] = false }
    end
  end
end
