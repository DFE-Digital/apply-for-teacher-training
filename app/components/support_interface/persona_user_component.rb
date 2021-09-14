module SupportInterface
  class PersonaUserComponent < ViewComponent::Base
    def initialize(persona_type)
      @persona_type = persona_type
    end

    def render?
      persona_user.present?
    end

  private

    attr_reader :persona_type

    def persona_user
      @persona_user ||= begin
        uid = t("personas.users.#{persona_type}.uid")
        ProviderUser.find_by(dfe_sign_in_uid: uid)
      end
    end

    def persona_providers_description
      t("personas.users.#{persona_type}.providers")
    end

    def persona_permissions_description
      t("personas.users.#{persona_type}.permissions")
    end
  end
end
