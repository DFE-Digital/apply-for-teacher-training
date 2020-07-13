module ProviderInterface
  class ProviderUserPermissionsForm
    include ActiveModel::Model

    attr_accessor :model,
                  :manage_organisations,
                  :manage_users,
                  :make_decisions,
                  :view_safeguarding_information

    delegate :provider, to: :model
    delegate :provider_user, to: :model
    delegate :id, to: :provider, prefix: true

    validates :model, presence: true

    def self.from(permissions_model)
      return unless permissions_model

      new_form = new(model: permissions_model)
      ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
        new_form.send("#{permission_name}=", permissions_model.send(permission_name))
      end
      new_form
    end

    def update_from_params(hash)
      ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
        send("#{permission_name}=", hash[permission_name] || false)
      end
    end

    def save
      if valid?
        ProviderPermissions::VALID_PERMISSIONS.each do |permission_name|
          @model.send("#{permission_name}=", send(permission_name))
        end

        @model.save
      end
    end
  end
end
