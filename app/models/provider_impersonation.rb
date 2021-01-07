class ProviderImpersonation
  attr_reader :support_user, :provider_user

  def initialize(support_user:, provider_user:)
    @support_user = support_user
    @provider_user = provider_user
  end

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    support_user = SupportUser.load_from_session(session)
    if (impersonated_user = support_user&.impersonated_provider_user)
      impersonated_user.impersonator = support_user
      new(support_user: support_user, provider_user: impersonated_user)
    end
  end
end
