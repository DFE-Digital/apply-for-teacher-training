module SupportInterface
  class PersonaUserComponent < ApplicationComponent
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

    def persona_organisation_membership
      @organisation_membership ||= t("personas.users.#{persona_type}.organisation_membership")
    end

    def persona_providers_description
      t("personas.organisation_membership_explanation.#{persona_organisation_membership}")
    end

    def persona_user_type
      @user_type ||= t("personas.users.#{persona_type}.user_type")
    end

    def persona_permissions_description
      t("personas.permissions.#{persona_user_type}")
    end
  end
end
