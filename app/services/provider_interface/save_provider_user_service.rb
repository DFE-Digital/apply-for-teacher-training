module ProviderInterface
  class SaveProviderUserService
    attr_accessor :wizard

    def initialize(wizard)
      self.wizard = wizard
    end

    def call!
      if email_exists?
        update_user
      else
        create_user
      end
    end

  private

    def email_exists?
      ProviderUser.find_by(email_address: wizard.email_address).present?
    end

    def update_user
      existing_user = ProviderUser.find_by(email_address: wizard.email_address)
      existing_user.update(
        email_address: wizard.email_address,
        first_name: wizard.first_name,
        last_name: wizard.last_name,
      )
      update_provider_permissions(existing_user)
    end

    def create_user
      user = ProviderUser.create(
        email_address: wizard.email_address,
        first_name: wizard.first_name,
        last_name: wizard.last_name,
      )
      create_provider_permissions(user)
      user
    end

    def create_provider_permissions(user)
      wizard.provider_permissions.each do |provider_id, permission|
        provider_permission = ProviderPermissions.new(
          provider_id: provider_id,
          provider_user_id: user.id,
        )
        permission['permissions'].reject(&:blank?).each do |permission_name|
          provider_permission.send("#{permission_name}=".to_sym, true)
        end
        provider_permission.save!
      end
    end

    def update_provider_permissions(user)
      wizard.provider_permissions.each do |provider_id, permission|
        provider_permission = ProviderPermissions.find_or_initialize_by(
          provider_id: provider_id,
          provider_user_id: user.id,
        )
        ProviderPermissions::VALID_PERMISSIONS.each do |permission_type|
          provider_permission.send(
            "#{permission_type}=",
            permission['permissions'].include?(permission_type.to_s),
          )
        end
        provider_permission.save!
      end
    end
  end
end
