module SupportInterface
  class EditSingleProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :provider_user, :provider_id
    attr_reader :provider_permissions

    validates :provider_permissions, presence: true

    def persisted?
      @provider_user&.persisted?
    end

    def forms_for_possible_permissions
      all_possible_permissions.map do |permission|
        ProviderPermissionsForm.new(active: permission.persisted?, provider_permission: permission)
      end
    end

    def all_possible_permissions
      if provider_user
        ProviderPermissions.includes(:provider, :provider_user)
          .where(provider_user_id: provider_user.id)
          .order('providers.name')
      else
        []
      end
    end

    def provider_permissions=(attributes)
      forms = attributes.map { |_, attrs| ProviderPermissionsForm.new(attrs) }
      @provider_permissions = forms.map do |form|
        permission = ProviderPermissions.find_or_initialize_by(
          provider_id: form.provider_permission[:provider_id],
          provider_user_id: provider_user.try(:id),
        )

        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          permission.send("#{permission_name}=", form.provider_permission.fetch(permission_name, false))
        end

        permission
      end
    end
  end
end
