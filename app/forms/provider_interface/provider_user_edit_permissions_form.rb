module ProviderInterface
  class ProviderUserEditPermissionsForm
    include ActiveModel::Model

    attr_accessor :provider_permissions, :model

    delegate :provider, to: :model
    delegate :provider_user, to: :model

    validates :model, presence: true
    validate :permission_form_is_valid, if: -> { model.present? }

    def self.build_from_model(permissions_model)
      return unless permissions_model

      new_form = new(model: permissions_model)

      new_form.provider_permissions = {
        permissions_model.provider.id.to_s => {
          'permissions' => ProviderPermissions::VALID_PERMISSIONS.select { |p| permissions_model.send(p) }.map(&:to_s),
          'view_applications_only' => permissions_model.view_applications_only?.to_s,
          'provider_id' => permissions_model.provider.id.to_s,
        },
      }

      new_form
    end

    def update_from_params(params)
      assign_attributes(params)
    end

    def permissions_form
      @_permissions_form ||= FieldsForProviderUserPermissionsForm.new(permissions_hash)
    end

    def save
      if valid?
        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          permission_enabled = permissions_hash['permissions'].include?(permission_name.to_s)
          model.send("#{permission_name}=", permission_enabled)
        end

        model.save
      end
    end

  private

    def permission_form_is_valid
      return if permissions_form.valid?

      permissions_form.errors.map do |key, message|
        errors.add("provider_permissions[#{permissions_form.id}][#{key}]", message)
      end
    end

    def permissions_hash
      provider_permissions.fetch(provider.id.to_s, {})
    end
  end
end
